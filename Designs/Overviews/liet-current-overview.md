# Liet Current Product and Architecture Overview

Current as of March 23, 2026.

## Purpose

Liet is currently a repository scaffold for a future Apple-platform product.
The implementation is intentionally biased toward a single source of truth for
shared business logic in `LietLibrary`, with platform adapters and UI living in
the app target.

## Product Surface Summary

| Surface | Current role | Key responsibilities |
| --- | --- | --- |
| `Liet` | Primary product surface | SwiftUI composition root, future Apple-framework adapters, future presentation flows |
| `LietTests` | App smoke-test surface | Keep app target wiring and package integration verifiable |
| `LietLibrary` | Shared domain layer | Shared constants today, reusable domain logic and models in future |

## Current Platform Package Posture

- `Liet` intentionally adopts the full `MHPlatform` umbrella.
- `LietLibrary` intentionally adopts `MHPlatformCore`.
- This repository intentionally tracks MHPlatform with the 1.x semver range
  `1.0.0..<2.0.0`.
- This repository intentionally tracks SwiftUtilities with the 1.x semver range
  `1.0.0..<2.0.0`.

## Current End-User Features

- Launch the iOS app into a placeholder screen.
- Confirm that the shared library boundary is active.
- Confirm that the app group identifier is already reserved for future
  widgets or companion targets.

## Current Engineering Features

- Local-package-based shared library integration through `LietLibrary`.
- Repo-managed verification shells under `ci_scripts/tasks`.
- Project-managed SwiftLint resolution through `SwiftLintPlugins`.
- ADR and architecture documents aligned to the shared-library-first design.
