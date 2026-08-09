# FastAPI implementation guide

Use this guide together with the main skill and [principles.md](principles.md). The copyable files in [`../assets/fastapi_example`](../assets/fastapi_example) are adapted from the supplied `outsider.shop` integration, with SQLAlchemy-specific configuration removed and request-wide event behavior added.

## Dependencies

Use uv:

```bash
uv add structlog asgi-correlation-id
```

`asgi-correlation-id` validates or generates request IDs and exposes them through a context variable. A custom pure-ASGI implementation is also valid if the project already has one.

## Files

Copy and adapt:

- [`logging.py`](../assets/fastapi_example/logging.py): combined structlog setup and canonical request middleware
- [`main.py`](../assets/fastapi_example/main.py): setup and middleware registration order
- [`usage.py`](../assets/fastapi_example/usage.py): business-context binding and outbound propagation

Do not copy mechanically. Match the project's settings, service metadata, error handlers, proxy trust model, response conventions, and existing logging requirements.

## Middleware order

Starlette's last-added middleware is outermost. In the example, `CorrelationIdMiddleware` is added after `setup_logging(app)`, so it establishes `correlation_id` before the logging middleware reads it.

Test this behavior if middleware registration is refactored. Confirm that:

- every response includes `X-Request-ID`
- the event's `request_id` matches that header
- an accepted incoming ID is preserved
- invalid/missing IDs are safely replaced

## Request lifecycle

The middleware:

1. clears structlog contextvars
2. binds the request ID
3. calls the route
4. emits one `http.request` event with status, outcome, and duration
5. emits an error event and re-raises unexpected exceptions
6. clears context during teardown

Because `merge_contextvars` is the first processor, route functions, dependencies, and async business functions can call `bind_contextvars()` without receiving a logger or event dictionary. Those values propagate to deeper calls and logs in the same execution context.

Do not bind final status and duration just before logging. Supply them as keyword arguments to `logger.info()`/`logger.error()`.

## Business enrichment

Bind context at the point a fact becomes known:

```python
from structlog.contextvars import bind_contextvars

async def authenticate(token: str) -> User:
    user = await decode_and_load_user(token)
    bind_contextvars(
        user={"id": str(user.id), "plan": user.plan},
        tenant_id=str(user.tenant_id),
    )
    return user
```

Later calls inherit these values. Avoid logging another line merely to record authentication success.

FastAPI/Starlette combines async and sync execution contexts. structlog documents that context variables can be isolated across concurrency methods. Prefer async middleware/dependencies for request-wide binding and test any context bound in synchronous dependencies before relying on it in async code.

The example uses pure ASGI middleware rather than FastAPI's `@app.middleware("http")` pattern. This keeps downstream execution in the same context, so values bound by endpoints and business functions are available when the middleware emits the final wide event.

## Routes and status codes

For aggregation, bind the route template once routing information is available. Depending on middleware style and failure timing, `request.scope["route"]` may be unavailable. The example falls back to the raw path.

The pure ASGI middleware observes `http.response.start` to capture the actual response status without wrapping the response body. Add integration tests for the application's streaming responses, mounted applications, exception handlers, and disconnect behavior.

## Exceptions

The example catches exceptions that escape the downstream ASGI application, emits the canonical request event with exception information, and re-raises. Handled `HTTPException`s normally become responses and are classified from their status code.

Coordinate with global exception handlers and server logging to avoid duplicate stack traces. Ensure an unexpected exception still emits exactly one application request event.

If an exception handler transforms errors before they reach the middleware, add a stable error classification to request context in that handler rather than emitting a second request log.

## Headers and client IP

Do not use `dict(request.headers)` as a default event field. It captures authorization, cookies, and arbitrary sensitive values. The example allowlists user agent and content metadata only.

`request.client.host` is the direct peer. Only trust `Forwarded` or `X-Forwarded-For` when trusted proxy middleware has validated it.

## Outbound calls

Contextvars are process-local; they do not cross HTTP automatically. Forward the canonical request ID:

```python
from structlog.contextvars import get_contextvars

request_id = get_contextvars().get("request_id")
headers = {"X-Request-ID": str(request_id)} if request_id else {}
await client.get(url, headers=headers)
```

Prefer an HTTP client hook/wrapper if the codebase has many outbound calls. Merge with existing headers rather than overwriting them.

Each receiving service initializes its own context and emits its own wide event using that request ID.

## Background tasks

Do not assume a request's context should live indefinitely in a background task. Pass the request ID and required domain identifiers explicitly, then start the task's independent event boundary by clearing and binding context. A queue message should carry the request ID in metadata, and its consumer should emit its own wide event.

## Uvicorn logs

Route `uvicorn` and `uvicorn.error` through the root handler for consistent rendering. Disable `uvicorn.access` after the canonical `http.request` event replaces it. Preserve startup/error logs because they represent separate operational events.

When starting Uvicorn programmatically or through deployment configuration, also disable its access log if needed (`access_log=False` or the equivalent CLI option) to prevent it from restoring duplicate access output.

## Production format

The example retains the supplied application's console renderer in development and logfmt renderer in production, using `logging.StreamHandler()`'s default stream. Match the target application's ingestion and stream requirements rather than changing them automatically.