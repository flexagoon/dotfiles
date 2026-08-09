# Structlog/stdlib configuration adapted from:
# https://gist.github.com/nymous/f138c7f06062b7c43c060bf03759c29e

import logging
from collections.abc import Mapping
from time import perf_counter
from typing import TYPE_CHECKING, Any

import structlog
from asgi_correlation_id import correlation_id
from fastapi import FastAPI
from starlette.datastructures import Headers
from starlette.types import ASGIApp, Message, Receive, Scope, Send

if TYPE_CHECKING:
    from structlog.types import EventDict, Processor, WrappedLogger


class _WideEventMiddleware:
    def __init__(self, app: ASGIApp) -> None:
        self.app = app
        self.logger = structlog.stdlib.get_logger("api.request")

    async def __call__(
        self,
        scope: Scope,
        receive: Receive,
        send: Send,
    ) -> None:
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        structlog.contextvars.clear_contextvars()
        if request_id := correlation_id.get():
            structlog.contextvars.bind_contextvars(request_id=request_id)

        started_at = perf_counter()
        request_fields = _request_fields(scope)
        status_code = 500

        async def send_with_status(message: Message) -> None:
            nonlocal status_code
            if message["type"] == "http.response.start":
                status_code = message["status"]
            await send(message)

        try:
            await self.app(scope, receive, send_with_status)
        except Exception:
            self.logger.exception(
                "http.request",
                **request_fields,
                outcome="error",
                status_code=status_code,
                duration_ms=round((perf_counter() - started_at) * 1_000, 2),
                route=_route_path(scope),
            )
            raise
        else:
            outcome = (
                "success"
                if status_code < 400
                else "client_error"
                if status_code < 500
                else "error"
            )
            log = self.logger.error if status_code >= 500 else self.logger.info
            log(
                "http.request",
                **request_fields,
                outcome=outcome,
                status_code=status_code,
                duration_ms=round((perf_counter() - started_at) * 1_000, 2),
                route=_route_path(scope),
            )
        finally:
            structlog.contextvars.clear_contextvars()


def setup_logging(app: FastAPI, *, debug: bool) -> None:
    if not structlog.is_configured():
        _configure_structlog(debug=debug)

    app.add_middleware(_WideEventMiddleware)


def _configure_structlog(*, debug: bool) -> None:
    shared_processors: list[Processor] = [
        structlog.contextvars.merge_contextvars,
        structlog.stdlib.add_logger_name,
        structlog.processors.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.stdlib.ExtraAdder(),
        _drop_uvicorn_color_message,
        structlog.processors.TimeStamper(fmt="iso", utc=True),
        structlog.processors.StackInfoRenderer(),
    ]

    if not debug:
        shared_processors.append(structlog.processors.dict_tracebacks)

    structlog.configure(
        processors=[
            *shared_processors,
            structlog.stdlib.ProcessorFormatter.wrap_for_formatter,
        ],
        logger_factory=structlog.stdlib.LoggerFactory(),
        cache_logger_on_first_use=True,
    )

    renderer: Processor = (
        structlog.dev.ConsoleRenderer()
        if debug
        else structlog.processors.LogfmtRenderer()
    )

    formatter = structlog.stdlib.ProcessorFormatter(
        foreign_pre_chain=shared_processors,
        processors=[
            structlog.stdlib.ProcessorFormatter.remove_processors_meta,
            renderer,
        ],
    )

    handler = logging.StreamHandler()
    handler.setFormatter(formatter)
    root_logger = logging.getLogger()
    root_logger.handlers.clear()
    root_logger.addHandler(handler)
    root_logger.setLevel(logging.INFO)

    for logger_name in ("uvicorn", "uvicorn.error"):
        logger = logging.getLogger(logger_name)
        logger.handlers.clear()
        logger.propagate = True

    access_logger = logging.getLogger("uvicorn.access")
    access_logger.handlers.clear()
    access_logger.propagate = False


def _request_fields(scope: Scope) -> dict[str, Any]:
    headers = Headers(scope=scope)
    client = scope.get("client")
    safe_headers: Mapping[str, str | None] = {
        "user_agent": headers.get("user-agent"),
        "content_type": headers.get("content-type"),
        "content_length": headers.get("content-length"),
    }
    fields: dict[str, Any] = {
        "method": scope["method"],
        "path": scope["path"],
        "client_ip": client[0] if client else None,
        **{key: value for key, value in safe_headers.items() if value},
    }
    return {key: value for key, value in fields.items() if value is not None}


def _route_path(scope: Scope) -> str:
    route_path = getattr(scope.get("route"), "path", None)
    return route_path if isinstance(route_path, str) else scope["path"]


def _drop_uvicorn_color_message(
    _: "WrappedLogger",
    __: str,
    event_dict: "EventDict",
) -> "EventDict":
    event_dict.pop("color_message", None)
    return event_dict
