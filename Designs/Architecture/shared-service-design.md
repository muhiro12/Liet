# Shared Service Design

## Purpose

This document describes the intended boundary for shared business logic in
Liet. It explains where new code should live when the same operation must work
across the iOS app and any future companion surfaces.

## Core Principles

- `LietLibrary` is the source of truth for shared business logic.
- Delivery surfaces enter reusable business use cases through public
  `*Operations` facades.
- `Liet` owns SwiftUI presentation and adapters for Apple frameworks.
- Future `AppIntent` types are adapters, not a second domain layer.
- Views keep presentation state and navigation, but reusable business
  decisions and mutations belong in shared library APIs.
- `LietLibrary` remains a single module unless there is a stronger reason than
  file organization alone.

## Responsibility Boundaries

### Shared Domain Logic

Lives in `LietLibrary`.

Examples include public `*Operations` facades, reusable settings, shared
identifiers, future models, predicates, and internal planners, preference
stores, naming helpers, import policies, and archive builders.

### Apple-Framework Adapters

Live in `Liet`.

Examples include App Intents, notifications, widget reloads, deep links, and
review flows.

### App-Side Platform Support

Lives in `Liet/Sources/Common/Platform`.

Examples include future runtime assembly, route pipeline setup, environment
injection, and `MHPlatform` bootstrap wiring.

### Presentation Orchestration

Lives in `Liet`.

Examples include SwiftUI views, navigation state, screen coordinators, and
presentation models.

## MHPlatform Adoption

- `Liet` is the intentional `MHPlatform` umbrella adopter.
- `LietLibrary` adopts `MHPlatformCore` and must not depend on the full
  `MHPlatform` umbrella.
- This repository intentionally uses the MHPlatform 1.x semver range
  `1.0.0..<2.0.0`.

## Operations Migration

Liet adopts the Incomes/Cookle Operations direction as the app-to-library
business boundary, not a domain-copying campaign.

- Add or extend `*Operations` when a delivery surface needs a public batch
  business use case from `LietLibrary`.
- Keep lower-level planners, preference stores, naming helpers, import
  policies, and archive builders internal to `LietLibrary`.
- If a view, future App Intent, widget, shortcut, or companion target starts
  recreating reusable parsing, validation, naming, preference, or processing
  planning rules, treat that as a missing Operations boundary.
- Keep Apple-only image import, rendering, background removal, Photos saving,
  file export, runtime assembly, and TipKit behavior in `Liet` adapters.

## Canonical Shared APIs

The current shared entry points and contracts are:

- `BatchImagePreferencesState`
- `BatchBackgroundRemovalPreferencesState`
- `BatchImageProcessingOperations`
- `BatchBackgroundRemovalOperations`
- `BatchImageFilenameOperations`
- `BatchImageImportOperations`
- `BatchImageArchiveOperations`
- `BatchImagePreferencesOperations`
- `BackgroundRemovalPreferencesOperations`
- `LietPreferenceDescriptors`
- `AppGroup`

Future delivery surfaces should continue through `*Operations` facades when a
shared API becomes a surface-facing business use case.

## Placement Rules

1. If an operation is reusable across more than one surface, add or extend a
   library `*Operations` facade first when that facade clarifies the business
   use case.
2. If an operation depends on Apple-only frameworks, keep it in `Liet` and
   make it call library APIs.
3. If a view or intent starts recreating parsing, validation, or mutation
   rules, treat that as a missing library API or Operations facade.
4. Keep platform-specific types out of `LietLibrary`. Convert them at the
   boundary into library models or value types.
5. If glue code is app-only but reused by multiple app entry points, factor it
   into `Liet/Sources/Common/Platform` instead of moving it into
   `LietLibrary`.

## Refactoring Heuristic

When a business rule is duplicated, the default fix is to move the rule into
`LietLibrary` and expose it through a `*Operations` facade when the rule is a
surface-facing business use case. When duplicated code is still Apple-framework
glue, the default fix is to extract it into `Liet/Sources/Common/Platform`.
