# ADR 0002: App Intents as Adapters

- Date: 2026-03-23
- Status: Accepted

## Context

App Intents can expose future Liet operations to Siri and Shortcuts. They can
easily become a second place where fetching, branching, and mutation rules are
reimplemented, which creates parity gaps with the main app UI.

## Decision

Treat `AppIntent` types as adapter code. They may validate parameters, convert
entities, call shared services, and optionally open routes in the app. They do
not become the source of truth for business rules.

## Consequences

- Shared operations should have intent adapters that call library APIs rather
  than reconstructing the behavior directly.
- If an intent needs custom business branching or raw fetching, that is a sign
  that the shared library API is incomplete.
- UI and App Intents should stay aligned by depending on the same canonical
  services.
