# FastAPI correlated logging

The files in [`../assets/fastapi_example`](../assets/fastapi_example) are closely modeled on the supplied `outsider.shop` integration, without SQLAlchemy-specific logger configuration.

## Dependencies

```bash
uv add structlog asgi-correlation-id
```

## Setup

Copy and adapt:

- [`logging.py`](../assets/fastapi_example/logging.py)
- [`main.py`](../assets/fastapi_example/main.py)
- [`service.py`](../assets/fastapi_example/service.py)
- [`outbound.py`](../assets/fastapi_example/outbound.py)

The logging setup:

- merges structlog contextvars first
- formats structlog and stdlib/third-party events consistently
- uses a console renderer in development and logfmt in production
- routes Uvicorn process events through the root handler
- disables Uvicorn's duplicate access event
- clears context and binds `request_id` at request ingress
- emits one structured `http.request` access/completion event

## Middleware order

Starlette's last-added middleware is outermost. Register request logging before adding `CorrelationIdMiddleware`:

```python
setup_logging(app, debug=DEBUG)
app.add_middleware(CorrelationIdMiddleware, header_name="X-Request-ID")
```

That causes correlation middleware to run first and establish the ID before logging middleware reads it.

Test missing, valid, and invalid incoming request IDs. Assert that the response header and all application events carry the same accepted/generated value.

## Service events

Use a module-level logger, then bind operation-specific context:

```python
logger = structlog.stdlib.get_logger(__name__)

async def set_order_status(order_id: int, new_status: str) -> Order:
    log = logger.bind(order_id=order_id, requested_status=new_status)
    order = await repository.get(order_id)

    if order is None:
        log.warning("order.not_found")
        raise OrderNotFound(order_id)

    previous_status = order.status
    order = await repository.set_status(order, new_status)
    log.info(
        "order.status_changed",
        previous_status=previous_status,
        new_status=order.status,
    )
    return order
```

`request_id` is added by `merge_contextvars`; local fields come from the bound logger and final call.

Do not bind an entire input model if it contains customer contact details, credentials, addresses, or unconstrained user input. Select safe fields.

## Middleware context limitations

The example follows FastAPI's `@app.middleware("http")` approach, which Starlette implements using `BaseHTTPMiddleware`. Context changes made downstream may not propagate back to the middleware task. That is acceptable for this model because endpoint/service fields belong to their own events; the final HTTP access event only requires request-level fields.

Contextvars can also be isolated between synchronous dependencies and asynchronous execution. Test any context bound outside the async request context before relying on it elsewhere.

## Exceptions

The request middleware emits an error access event when an exception escapes and re-raises it. Operation layers may also emit a separate failure event when it represents useful domain/dependency information:

```text
request_id=abc order_id=42 event=order.persistence_failed
request_id=abc method=POST route=/orders status_code=500 event=http.request
```

Those are not necessarily duplicates: one describes the failed operation and the other the HTTP outcome. However, avoid recording the same traceback in both. Usually the operation event should carry the domain classification, while one owning boundary records the traceback.

Handled `HTTPException`s normally become responses and are represented by the access event's status. Add a separate domain event only when it is independently useful.

## Request fields

Use a header allowlist. Do not log `dict(request.headers)` because it may include authorization, cookies, or application secrets. Avoid full URLs when query parameters can contain sensitive values.

Prefer the route template for aggregation and optionally retain the safe raw path for individual investigation.

`request.client.host` represents the direct peer. Trust forwarded IP headers only after trusted proxy middleware validates them.

## Outbound propagation

Contextvars do not cross a network boundary. Read the current request ID and forward it explicitly:

```python
request_id = get_contextvars().get("request_id")
headers = {"X-Request-ID": str(request_id)} if request_id else {}
await client.get(url, headers=headers)
```

Use an HTTP client hook or wrapper when many call sites need this behavior. Preserve existing headers rather than replacing them.

## Background jobs

Pass correlation fields explicitly into background or queued work. At worker ingress:

1. clear contextvars
2. bind the originating request ID and job/message ID
3. emit operation events
4. clear context in teardown

A worker has a separate lifecycle even when its work originated from an HTTP request.