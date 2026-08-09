---
name: structlog-wide-events
description: Adds or reviews Python logging with structlog using wide events/canonical log lines, request-scoped context propagation, high-cardinality business context, and correlated service events. Use for Python logging work, especially FastAPI services.
disable-model-invocation: true
---

# Structlog Wide Events

Implement logging as a structured record of what happened, not a diary of what the code did.

Before reading, editing, or running Python code, load the `python` skill. For FastAPI work, also read [references/fastapi.md](references/fastapi.md). Copyable FastAPI examples are in [assets/fastapi_example](assets/fastapi_example).

## Target model

- Emit one context-rich wide event per request or independently meaningful operation per service.
- Give every service its own event; propagate the same `request_id` across service boundaries.
- Add high-cardinality identifiers and high-dimensional business context needed to investigate unknown unknowns.
- Build the event throughout execution with `structlog.contextvars.bind_contextvars()`.
- Bind a value where it becomes known so deeper and later functions inherit it.
- Put completion-only values directly on the final log call. Do not bind `status_code`, `outcome`, `duration_ms`, or similar fields immediately before emitting.
- Emit JSON in production and send it to stdout.

Read [references/principles.md](references/principles.md) before designing or changing the event schema.

## Workflow

1. Inspect the package manager, Python version, framework, existing logging configuration, middleware, service boundaries, outbound clients, background jobs, and deployment metadata.
2. Understand why existing logs exist before replacing them. Preserve audit, security, compliance, lifecycle, and independently meaningful operational events. Ask if a log's purpose is unclear.
3. Define a stable schema. Reuse field names across services, especially `request_id`, `service`, `event`, `outcome`, `duration_ms`, and business identifiers.
4. Install dependencies with uv rather than editing `pyproject.toml` manually:

   ```bash
   uv add structlog
   # FastAPI correlation support, when appropriate:
   uv add asgi-correlation-id
   ```

5. Configure structlog once at application startup:
   - Put `structlog.contextvars.merge_contextvars` first.
   - Use `structlog.stdlib.ProcessorFormatter` when stdlib and third-party logs must share formatting.
   - Use `JSONRenderer` in production; a console renderer is acceptable locally.
   - Disable duplicate framework access logs once the request wide event replaces them.
6. At the execution boundary, clear stale context and bind stable initial context such as request ID, service, method, deployment, and safe request metadata.
7. In business functions, bind newly discovered context immediately:

   ```python
   from structlog.contextvars import bind_contextvars

   async def load_customer(customer_id: str) -> Customer:
       customer = await repository.get_customer(customer_id)
       bind_contextvars(
           customer={
               "id": customer.id,
               "plan": customer.plan,
               "account_age_days": customer.account_age_days,
           }
       )
       return customer
   ```

8. Emit once at completion. Pass final values directly:

   ```python
   logger.info(
       "checkout.request",
       outcome="success",
       status_code=201,
       duration_ms=duration_ms,
   )
   ```

9. Propagate `request_id` on outbound calls, normally with `X-Request-ID`. The downstream service clears its own context, binds the received ID, enriches its own event, and emits its own wide event.
10. Remove superseded diary-style logs only after confirming they do not represent separate events or requirements.
11. Format and verify changes:

    ```bash
    uv run ruff format
    uv run ruff check --fix
    uv run mypy .
    ```

## Binding rules

Bind values that should be available to later code or included if execution fails after that point:

- authenticated actor and tenant
- order, cart, payment, or job identifiers
- subscription tier and account characteristics
- feature flags and experiment variants
- external provider and operation details
- safe deployment and runtime dimensions

Pass values directly to the final log call when they only exist to describe completion:

- `outcome`
- `status_code`
- `duration_ms`
- response size
- final error classification

Use nested domain objects such as `customer={...}` and `payment={...}` where they improve consistency and avoid collisions. Keep commonly queried correlation and HTTP fields top-level.

## Separate events and services

A helper function is not automatically a separate event. Usually it enriches the current request event.

Emit another wide event when work has an independently meaningful lifecycle, such as:

- a downstream service handling the propagated request
- a queue consumer processing a message
- a scheduled/background job
- a payment attempt that must be independently audited or queried
- a long-running operation with its own outcome

Each event must still be wide. Do not create a three-field side log. Preserve `request_id` across all events caused by the same request, and add an `event_id`, job ID, message ID, or trace/span IDs when useful.

## Validation checklist

- Exactly one canonical request event is emitted per service hop on success and failure.
- Separate meaningful events share the originating `request_id`.
- Concurrent requests do not leak context into one another.
- Business functions enrich context where facts are discovered.
- Completion fields are passed on the final call rather than bound immediately beforehand.
- Events contain business, deployment, and correlation context—not only technical fields.
- Secrets, credentials, tokens, cookies, and sensitive bodies are absent or explicitly redacted.
- Incoming request IDs are validated by trusted middleware or replaced.
- Outbound calls propagate the request ID.
- Duplicate access and diary logs are removed only when safe.
- Error and slow-request events are retained if sampling is used.

## Sources

- [Observability Wide Events 101](https://boristane.com/blog/observability-wide-events-101/)
- [Logging Sucks](https://loggingsucks.com/)
- [structlog context variables](https://www.structlog.org/en/stable/contextvars.html)
- [structlog standard-library integration](https://www.structlog.org/en/stable/standard-library.html)
