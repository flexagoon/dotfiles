---
name: structlog-correlated-logging
description: Adds or reviews Python structured logging with structlog using request IDs, contextvars correlation, and operation-specific bound loggers. Use when a codebase prefers multiple correlated events per request rather than one canonical wide event, especially with FastAPI.
disable-model-invocation: true
---

# Structlog Correlated Logging

Implement structured, operation-oriented events that can be reconstructed by a shared request ID.

Before reading, editing, or running Python code, load the `python` skill. For FastAPI work, read [references/fastapi.md](references/fastapi.md). Copyable examples are in [assets/fastapi_example](assets/fastapi_example).

This skill deliberately does **not** implement the canonical wide-event model. If the goal is one context-rich event per request or service hop, use the `structlog-wide-events` skill instead.

## Target model

- A request may emit multiple structured events for meaningful operations and outcomes.
- Every event caused by the request carries the same `request_id`.
- Middleware owns request-level correlation and emits the HTTP access/completion event.
- Service functions use `logger.bind()` to create operation-local loggers carrying identifiers and state.
- Context shared across otherwise unrelated loggers uses `structlog.contextvars.bind_contextvars()`.
- Request IDs cross process boundaries explicitly through HTTP headers or message metadata.
- Production logs use the codebase's established structured renderer, commonly logfmt or JSON.

Read [references/principles.md](references/principles.md) before changing logging behavior.

## Workflow

1. Inspect existing logging configuration, middleware order, request-ID conventions, service functions, exception handlers, outbound clients, background jobs, and log ingestion format.
2. Understand each existing log's purpose before removing it. Preserve audit, security, lifecycle, and independently useful operational events.
3. Define stable event names and field names. Prefer `order.created` with `order_id=...` over prose containing the identifier.
4. Install dependencies with uv when absent:

   ```bash
   uv add structlog
   # For the documented FastAPI integration:
   uv add asgi-correlation-id
   ```

5. Configure structlog once at startup. Put `merge_contextvars` first so request IDs appear on structlog events emitted by any logger.
6. At request ingress, clear stale context and bind the validated/generated `request_id`.
7. Use a module-level logger and derive an operation-local logger inside the service function:

   ```python
   logger = structlog.stdlib.get_logger(__name__)

   async def cancel_order(order_id: int) -> Order:
       log = logger.bind(order_id=order_id)
       order = await repository.get(order_id)

       if order is None:
           log.warning("order.not_found")
           raise OrderNotFound(order_id)

       previous_status = order.status
       await repository.cancel(order)
       log.info(
           "order.cancelled",
           previous_status=previous_status,
           new_status=order.status,
       )
       return order
   ```

8. Log exceptions at the layer that owns the operation or can add actionable context. Re-raise unless that layer intentionally handles the failure.
9. Propagate `request_id` on outbound calls, normally through `X-Request-ID`. Downstream services bind it independently.
10. Keep logs structured and independently meaningful. Avoid start/end logs for every function.
11. Format and verify changes:

    ```bash
    uv run ruff format
    uv run ruff check --fix
    uv run mypy .
    ```

## Context choice

Use contextvars for fields that should appear across loggers throughout the request:

- `request_id`
- trace/session ID when applicable
- authenticated actor or tenant when genuinely needed by many unrelated layers

Use `logger.bind()` for operation-local context:

- `order_id`
- payment provider and attempt
- object/storage key
- requested state transition
- queue message or job ID

Pass one-off outcome details directly to the log call:

```python
log.info(
    "order.status_changed",
    previous_status=previous_status,
    new_status=new_status,
)
```

A bound logger is immutable: `log.bind(...)` returns another logger. Assign or return it when later events need the new fields.

## Event boundaries

Log an event when it is independently useful to an operator, auditor, or downstream analysis. Good examples:

- `order.created`
- `order.not_found`
- `order.status_changed`
- `payment.declined`
- `email.delivery_failed`
- `object.delete_failed`
- `http.request`

Avoid diary events such as:

- `entered_function`
- `query_started`
- `validation_finished`
- `returning_response`

unless they solve a demonstrated operational need.

## Correlation contract

Use one canonical field and transport convention across services:

- event field: `request_id`
- HTTP header: `X-Request-ID`

At ingress, validate IDs and generate one when absent or invalid. Include it in the response. Forward it to downstream HTTP services and put it in queue/message metadata. Each service emits its own events with the same ID.

Contextvars do not cross network, process, thread, or queue boundaries automatically.

## Validation checklist

- Every application event emitted during a request contains its `request_id`.
- Concurrent requests cannot leak context into one another.
- Outbound calls and queued work propagate the request ID explicitly.
- Event names and field names are stable and queryable.
- Bound logger return values are not accidentally discarded.
- Exceptions are not logged redundantly at every stack layer.
- Successful, expected-failure, and unexpected-failure paths emit useful events.
- Secrets, authorization headers, cookies, credentials, and sensitive bodies are not logged.
- Uvicorn access logs are disabled if the application emits an equivalent request event.
- The team accepts that cross-event analysis may require joining/reconstructing records by `request_id`.

## Sources

- [structlog context variables](https://www.structlog.org/en/stable/contextvars.html)
- [structlog standard-library integration](https://www.structlog.org/en/stable/standard-library.html)
- The supplied `outsider.shop` logging integration
