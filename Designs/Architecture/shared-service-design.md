# Shared Service Design

## Purpose

This document describes the intended boundary for shared business logic in
Liet. It explains where new code should live when the same operation must work
across the iOS app and any future companion surfaces.

## Core Principles

- `LietLibrary` is the source of truth for shared business logic.
- `Liet` owns SwiftUI presentation and adapters for Apple frameworks.
- Future `AppIntent` types are adapters, not a second domain layer.
- Views keep presentation state and navigation, but reusable business
  decisions and mutations belong in shared services.
- `LietLibrary` remains a single module unless there is a stronger reason than
  file organization alone.

## Responsibility Boundaries

| Concern | Lives in | Examples |
| --- | --- | --- |
| Shared domain logic | `LietLibrary` | future models, predicates, calculators, planners, mutation services, shared identifiers, shared preference stores |
| Apple-framework adapters | `Liet` | App Intents, notifications, widget reloads, deep links, review flows |
| App-side platform support | `Liet/Sources/Common/Platform` | future runtime assembly, route pipeline setup, environment injection, `MHPlatform` bootstrap wiring |
| Presentation orchestration | `Liet` | SwiftUI views, navigation state, screen coordinators, presentation models |

## MHPlatform Adoption

- `Liet` is the intentional `MHPlatform` umbrella adopter.
- `LietLibrary` adopts `MHPlatformCore` and must not depend on the full
  `MHPlatform` umbrella.
- This repository intentionally uses the MHPlatform 1.x semver range
  `1.0.0..<2.0.0`.
- This repository intentionally uses the SwiftUtilities 1.x semver range
  `1.0.0..<2.0.0`.

## Placement Rules

1. If an operation is reusable across more than one surface, add or extend a
   library service first.
2. If an operation depends on Apple-only frameworks, keep it in `Liet` and
   make it call library APIs.
3. If a view or intent starts recreating parsing, validation, or mutation
   rules, treat that as a missing library API.
4. Keep platform-specific types out of `LietLibrary`. Convert them at the
   boundary into library models or value types.
5. If glue code is app-only but reused by multiple app entry points, factor it
   into `Liet/Sources/Common/Platform` instead of moving it into
   `LietLibrary`.

## Refactoring Heuristic

When a business rule is duplicated, the default fix is to move the rule into
`LietLibrary` rather than duplicating it in another view, intent, or target.
When duplicated code is still Apple-framework glue, the default fix is to
extract it into `Liet/Sources/Common/Platform`.
