# Correlated structured logging principles

## Mental model

Each log event records one independently meaningful fact or operation. Events caused by the same request share a `request_id`, allowing an operator to retrieve and reconstruct the request timeline.

For example:

```text
request_id=abc order_id=42 event=order.created
request_id=abc recipient_domain=example.com event=email.sent
request_id=abc method=POST route=/orders status_code=201 event=http.request
```

This is different from a canonical wide event, where those fields would be denormalized into one request record. Correlated logging favors event locality and straightforward instrumentation; wide events favor cross-request aggregation without joins.

## Advantages

- Each operation owns and describes its event.
- Service functions do not need to mutate a request-wide event.
- Existing structured events can be adopted incrementally.
- A request timeline can be reconstructed from its request ID.
- Independent audit and business events remain natural.
- Framework middleware can remain simple.

## Tradeoffs

- Investigating one request requires retrieving multiple records.
- Cross-request questions may require joining events by `request_id`.
- Sampling events independently can leave incomplete timelines.
- Context may be duplicated across records.
- Early failures may omit fields that would only appear in later events.
- Inconsistent schemas accumulate if event names and fields are not governed.

Use the wide-event skill instead when one completion record must contain all business and technical dimensions for direct aggregation.

## Structured events

Use a stable event name plus typed fields:

```python
log.info(
    "order.status_changed",
    previous_status=previous_status,
    new_status=new_status,
)
```

Avoid embedding queryable facts only in prose:

```python
log.info("Changed order %s from %s to %s", order_id, old, new)
```

Human-readable text is acceptable for truly narrative diagnostics, but identifiers, outcomes, and classifications still belong in fields.

## Contextvars versus bound loggers

### Contextvars

`structlog.contextvars` holds execution-local context merged into every structlog event. Use it sparingly for correlation fields shared across components, especially `request_id`.

At each request or job boundary:

1. clear old context
2. bind correlation fields
3. execute the work
4. clear context during teardown

Do not expect contextvars to cross HTTP, queues, processes, or all sync/async task boundaries automatically.

### Bound loggers

A bound logger carries local context without modifying the request-global context:

```python
log = logger.bind(order_id=order_id)
log.info("order.loaded")
```

Binding is immutable. This does not enrich another logger, including the request middleware's logger:

```python
log = logger.bind(order_id=42)
log.info("order.created")
logger.info("http.request")  # no order_id from `log`
```

That separation is intentional in this logging model.

## Event design

An event should be independently understandable. Include enough local context to know:

- what happened
- which domain object or dependency was involved
- whether it succeeded or failed
- any stable error code or state transition
- the shared request/job correlation ID

Do not log every function transition. Prefer business and operational boundaries.

Use consistent names such as:

- nouns and completed actions: `order.created`, `payment.declined`
- stable snake_case fields: `order_id`, `previous_status`
- machine-queryable outcomes/codes rather than varying prose

## Errors

Log an exception once at the layer that owns the operation or has the best actionable context. Use `logger.exception(...)` inside an exception handler when a traceback is required.

Expected domain failures often need a warning or info event without a traceback. Unexpected failures generally need an error event with exception data.

Avoid this pattern at every layer:

```python
except Exception:
    logger.exception("operation.failed")
    raise
```

If every caller logs the same exception, one failure becomes several nearly identical records. Lower layers should usually enrich and re-raise; the owning boundary logs it.

## Request IDs

Accept request IDs only through trusted, validated middleware. Bound their length and allowed format or replace them to prevent malformed/unbounded values from entering every event.

Return the canonical ID to clients and propagate it to dependencies:

```python
request_id = get_contextvars().get("request_id")
headers = {"X-Request-ID": str(request_id)} if request_id else {}
```

For background work, pass the ID explicitly and initialize a new context boundary in the worker.

## Privacy and safety

Do not log complete request headers, bodies, model dumps, or environment variables by default. They can contain secrets and personal data. Prefer allowlists and purpose-built event fields.

Be especially careful with:

- authorization and cookie headers
- access/refresh tokens and API keys
- passwords and password-reset links
- payment details
- customer addresses, phone numbers, and email addresses
- presigned object-storage URLs

Opaque identifiers are usually more useful and safer than full domain objects.

## Sampling

If events are sampled independently, a reconstructed request can be incomplete. Prefer one of:

- keep all correlated events for a sampled request
- make a deterministic decision from `request_id`
- always retain errors and security/audit events
- document that request timelines may be partial

Never sample legally required audit events without an approved policy.