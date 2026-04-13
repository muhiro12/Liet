# Liet Architecture Guide

## Scope

This guide defines the strict `domain-in-library, UI-as-adapter` policy for
this repository.

Related document:
[shared-service-design.md](./shared-service-design.md)

Related decision:
[0005-adapter-failure-surfacing-contract.md](../Decisions/0005-adapter-failure-surfacing-contract.md)

## Responsibility Boundaries

| Layer | Owns | Must not own |
| --- | --- | --- |
| Domain (`LietLibrary`) | Reusable business logic, future shared models, predicates, planners, pure helpers, shared app-group constants, shared preference persistence | Apple-framework side effects, app lifecycle wiring, SwiftUI presentation |
| Adapter (`Liet`, future widgets, future App Intents) | Parameter parsing, platform API calls, `MHPlatform` runtime/bootstrap wiring, follow-up orchestration based on domain outcomes | Duplicated domain branching or long-lived business rules |
| View (SwiftUI) | Focus state, sheets, navigation state, screen-scoped `@Observable` presentation models, display-only formatting | Domain validation branching, persistence rules, reusable calculations |

## View Rules

Allowed in views:

- Focus and keyboard behavior
- Sheet and dialog routing
- Navigation and transient UI state
- Small screen-scoped `@Observable` models owned by the root view
- Display-only formatting

Not allowed in views:

- Domain validation branching
- Shared calculations
- Mutation rules
- Extension-specific orchestration that should be reusable later

## Canonical Mutation Flow

`View -> Workflow/Adapter (Liet target) -> LietLibrary service/store -> persistence write -> Observation updates`

Adapters may orchestrate platform side effects after mutation completion, but
mutation rules and changed-entity decisions should come from `LietLibrary`.

## SwiftData Boundary

Keep in `LietLibrary`:

- future `@Model` types
- predicates and descriptor builders
- domain mutation and query logic

Keep in `Liet`:

- `ModelContainer` construction
- app and scene lifecycle wiring
- Apple-framework adapters
- review, notification, widget, or shortcut orchestration

## Current Scaffold Status

- `LietLibrary` now owns shared App Group constants plus MHPlatformCore-backed
  batch preference persistence through caller-owned descriptors.
- `Liet` now boots through an app-owned `LietAppAssembly` that keeps
  `MHAppRuntimeBootstrap(configuration:)` at the root boundary while
  Apple-framework adapters remain in the app target.
- New features should expand the shared library first when the logic is likely
  to be reused by more than one surface.
