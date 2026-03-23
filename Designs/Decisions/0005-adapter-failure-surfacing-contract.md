# ADR 0005: Adapter Failure-Surfacing Contract

- Date: 2026-03-23
- Status: Accepted

## Context

Strong domain and adapter boundaries do not prevent silent failures on their
own. A future adapter can still hide operational problems unless the
repository defines what should block success, what should degrade gracefully,
and what should remain observable.

## Decision

Every adapter-owned mutation or sync path must classify failures into one of
the phases below and surface them consistently.

| Phase | Examples | Contract |
| --- | --- | --- |
| Preflight failure before mutation | Missing dependency wiring, invalid parameter conversion, unavailable local state | Block success. Keep the current UI or throw from the App Intent. |
| Primary domain mutation failure | Validation failure, persistence error, domain service throw | Block success. Surface the error to the current caller. |
| Post-commit follow-up failure | Notification refresh, widget reload, other adapter-only side effects after the domain write has already committed | Treat as degraded success, not rollback. Preserve the committed mutation result, but emit observable failure signals. |
| Sync transport or snapshot-apply failure | Unreachable peer, decode failure, snapshot apply failure | Surface an explicit sync failure state. Do not collapse the failure into a valid empty-data result. |

## Consequences

- Adapter code must make success semantics explicit instead of relying on
  assertions or empty sentinels.
- Mutation workflows should distinguish primary mutation errors from follow-up
  execution errors.
- Future sync and replication paths need explicit result models instead of
  ambiguous empty collections.
