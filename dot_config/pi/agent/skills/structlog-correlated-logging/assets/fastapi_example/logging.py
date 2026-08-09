# Adapted from:
# https://gist.github.com/nymous/f138c7f06062b7c43c060bf03759c29e

import logging
from collections.abc import Awaitable, Callable, Mapping
from time import perf_counter
from typing import TYPE_CHECKING, Any

import structlog
from asgi_correlation_id import correlation_id
from fastapi import FastAPI, Request, Response

if TYPE_CHECKING:
    from structlog.types import EventDict, Processor, WrappedLogger


def setup_logging(app: FastAPI, *, debug: bool) -> None:
    if not structlog.is_configured():
        _configure_structlog(debug=debug)

    logger = structlog.stdlib.get_logger("api.request")

    @app.middleware("http")
    async def logging_middleware(
        request: Request,
        call_next: Callable[[Request], Awaitable[Response]],
    ) -> Response:
        structlog.contextvars.clear_contextvars()
        if request_id := correlation_id.get():
            structlog.contextvars.bind_contextvars(request_id=request_id)

        started_at = perf_counter()
        request_fields = _request_fields(request)

        try:
            response = await call_next(request)
        except Exception:
            logger.exception(
                "http.request",
                **request_fields,
                outcome="error",
                status_code=500,
                duration_ms=round((perf_counter() - started_at) * 1_000, 2),
            )
            raise
        else:
            route = request.scope.get("route")
            outcome = (
                "success"
                if response.status_code < 400
                else "client_error"
                if response.status_code < 500
                else "error"
            )
            log = logger.error if response.status_code >= 500 else logger.info
            log(
                "http.request",
                **request_fields,
                outcome=outcome,
                status_code=response.status_code,
                duration_ms=round((perf_counter() - started_at) * 1_000, 2),
                route=getattr(route, "path", request.url.path),
            )
            return response
        finally:
            structlog.contextvars.clear_contextvars()


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


def _request_fields(request: Request) -> dict[str, Any]:
    safe_headers: Mapping[str, str | None] = {
        "user_agent": request.headers.get("user-agent"),
        "content_type": request.headers.get("content-type"),
        "content_length": request.headers.get("content-length"),
    }
    fields: dict[str, Any] = {
        "method": request.method,
        "path": request.url.path,
        "client_ip": request.client.host if request.client else None,
        **{key: value for key, value in safe_headers.items() if value},
    }
    return {key: value for key, value in fields.items() if value is not None}


def _drop_uvicorn_color_message(
    _: "WrappedLogger",
    __: str,
    event_dict: "EventDict",
) -> "EventDict":
    event_dict.pop("color_message", None)
    return event_dict
