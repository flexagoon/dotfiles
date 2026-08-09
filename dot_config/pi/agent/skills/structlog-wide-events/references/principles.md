# Wide-event design principles

## Mental model

A wide event answers: **what happened to this unit of work in this service?**

It is not merely a JSON-formatted traditional log. Structured logging is necessary, but a five-field message without request and business context is not a wide event.

Prefer one canonical event per request per service. Build it as facts become known, then emit it once when the service's work completes. This reduces noisy, disconnected diary logs and leaves one queryable record with high dimensionality and high-cardinality identifiers.

## Event boundaries

Use the lifecycle—not the function boundary—to determine event boundaries.

Functions participating in one service request generally bind context to the current event. An operation deserves a separate event when it has its own lifecycle, outcome, ownership, retry semantics, or observability questions. Examples include a downstream service request, queue delivery, scheduled job, or independently auditable payment attempt.

If service A calls services B and C:

- A emits A's event.
- B emits B's event.
- C emits C's event.
- All three use the same `request_id`.
- Each event contains its own service name, timing, outcome, and relevant context.

A request ID provides correlation, not parent-child causality. Add trace/span IDs or operation IDs if the system needs a call hierarchy or multiple occurrences must be distinguished.

## What to capture

Capture dimensions that help answer unanticipated production questions:

- correlation: request, trace, session, job, message, and causation IDs
- request: method, route template, host, safe client characteristics
- response: status, outcome, duration, response size
- actor: opaque user/account/tenant IDs, plan, account age, risk tier
- domain: order value, item count, workflow state, provider, retry count
- rollout: feature flags and experiment variants
- deployment: service, version/commit, deployment, environment, region, instance
- failures: exception type, stable error code, retryability, dependency

Use route templates such as `/users/{user_id}` rather than raw paths as the primary aggregation field. A raw path may be retained separately if it is safe and useful.

Do not dump entire domain objects just to make an event wide. Select durable, queryable fields. Wide means context-rich, not indiscriminate.

## Context binding

`structlog.contextvars` supplies execution-local context that loggers in later functions can inherit.

At every entry boundary:

1. `clear_contextvars()` to prevent stale context.
2. Bind request/job identity and stable metadata.
3. Bind business context where each fact becomes known.
4. Emit the final event with completion-only values passed directly to the logger.
5. Clear context in teardown where execution may continue in the same task.

Use `bound_contextvars()` for a temporary override and `reset_contextvars()` with tokens when manually restoring context. Be careful in hybrid sync/async frameworks: context variables set in a sync context may not be visible in async code and vice versa. Bind request-wide context from async middleware and test sync dependencies explicitly.

Do not use a mutable global event dictionary. It leaks between concurrent requests. Do not pass an event dictionary through every function when execution-local structlog context can propagate it safely.

## Request IDs

Choose one canonical field and header across services, for example:

- event field: `request_id`
- HTTP header: `X-Request-ID`

At ingress, accept only valid IDs of bounded length from trusted sources; otherwise generate one. Return it in the response and forward it on every relevant outbound request. For messages, place it in message metadata.

A downstream service binds the incoming ID but creates and emits its own event. It must not expect the caller's contextvars to cross a network boundary.

## Exceptions

The canonical event must be emitted on both success and failure. Include a stable error classification and enough safe detail to diagnose the failure. Preserve the original exception behavior so the framework's exception handlers still produce the response.

Avoid duplicate exception logs from every stack layer. A layer should enrich and re-raise unless it owns an independent event or can add uniquely valuable operational information.

Expected client failures may be `outcome="client_error"`; unexpected exceptions should generally be `outcome="error"`. Keep the schema stable across both.

## Privacy and security

Never log secrets or unconstrained request data by default. In particular, exclude:

- authorization and cookie headers
- access/refresh tokens, API keys, and passwords
- payment card or bank details
- session secrets
- raw request/response bodies
- sensitive personal data unless explicitly approved

Prefer allowlists over redaction after collection. Hash or tokenize identifiers only when that matches the threat model and preserves required queryability. Treat logs as production data with access controls and retention limits.

## Sampling

Wide events can be large. If volume requires sampling, make the decision after completion:

- retain all errors
- retain slow requests
- retain explicitly investigated or high-priority tenants/users
- retain selected rollout cohorts
- randomly sample ordinary successful requests

Record the sampling policy/rate if the backend needs statistically valid aggregates. Sampling should be deterministic by request or trace when all correlated service events need the same decision.

## Anti-patterns

Avoid:

- `logger.info("starting step")` and `logger.info("finished step")` diary logs
- unstructured prose containing identifiers
- a different name for the same field in each service
- binding status/duration immediately before the final log call
- one shared mutable dictionary across requests
- logging every header or whole model by default
- swallowing exceptions to make logging easier
- counting each internal function as a separate service event
- random head sampling that discards rare failures

Preserve separate audit/security events, process startup/shutdown events, and signals that have independent operational meaning. Wide events are a default application-observability model, not a ban on every other event.