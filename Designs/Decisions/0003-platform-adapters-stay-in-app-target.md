# ADR 0003: Platform Adapters Stay in App Target

- Date: 2026-03-23
- Status: Accepted

## Context

Some capabilities in Liet will depend directly on Apple frameworks, such as
notifications, widgets, deep-link handling, or App Intents. These dependencies
do not belong in the shared business layer.

## Decision

Keep platform-specific integrations in the `Liet` target. Do not add platform
behavior to library domain services through app-target extensions. Instead, use
dedicated adapter services in the app target.

## Consequences

- App-target adapters should return or consume library models and value types
  wherever possible.
- `LietLibrary` stays focused on platform-neutral business logic.
- When a new feature needs Apple-only APIs, the default design is an app-side
  adapter over shared services, not a new responsibility inside the library.
