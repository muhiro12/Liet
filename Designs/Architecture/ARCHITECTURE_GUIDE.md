# Liet Architecture Guide

## Scope

This guide defines the strict `domain-in-library, UI-as-adapter` policy for
this repository.

Related document:
[shared-service-design.md](./shared-service-design.md)

Related decisions:

- `Designs/Decisions/0005-adapter-failure-surfacing-contract.md`
- `Designs/Decisions/0006-stage-mcp-first-and-operations-boundaries.md`

## Public Business Boundary

Delivery surfaces call reusable business use cases through public
`*Operations` facades in `LietLibrary`.

Liet currently has one app delivery surface. Lower-level batch planners,
preference stores, naming helpers, import policies, and archive builders remain
internal library collaborators behind the Operations boundary.

## Responsibility Boundaries

### Domain (`LietLibrary`)

Owns reusable business logic, public `*Operations` facades, future shared
models, predicates, internal planners, pure helpers, shared App Group
constants, and shared preference persistence.

Must not own Apple-framework side effects, app lifecycle wiring, or SwiftUI
presentation.

### Adapter (`Liet`, Future Widgets, Future App Intents)

Owns parameter parsing, platform API calls, `MHPlatform` runtime/bootstrap
wiring, and follow-up orchestration based on library outcomes.

Must not own duplicated domain branching or long-lived business rules.

### View (SwiftUI)

Owns focus state, sheets, navigation state, screen-scoped `@Observable`
presentation models, and display-only formatting.

Must not own domain validation branching, persistence rules, or reusable
calculations.

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

```text
View -> Workflow/Adapter (Liet target)
    -> LietLibrary Operations
    -> internal library collaborator
    -> persistence write
    -> Observation updates
```

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

- `LietLibrary` owns shared App Group constants plus MHPlatformCore-backed
  batch preference persistence exposed through public Operations.
- `Liet` now boots through an app-owned `LietAppAssembly` that keeps
  `MHAppRuntimeBootstrap(configuration:)` at the root boundary while
  Apple-framework adapters remain in the app target.
- New features should expand the shared library first when the logic is likely
  to be reused by more than one surface.
- New public `*Operations` facades should be added when a future delivery
  surface needs another stable shared business entry point.
