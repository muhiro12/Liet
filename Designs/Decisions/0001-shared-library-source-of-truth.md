# ADR 0001: Shared Library Source of Truth

- Date: 2026-03-23
- Status: Accepted

## Context

Liet is expected to grow beyond a single SwiftUI screen. When multiple app
surfaces or adapters each grow their own mutation or decision logic, behavior
drifts and refactoring becomes expensive.

## Decision

`LietLibrary` is the single source of truth for reusable business logic.
Shared models, predicates, calculators, planners, and mutation services belong
there. The module stays as one shared library for now.

## Consequences

- Shared operations should be expressed through library services before they
  are reused elsewhere.
- The iOS app and any future extensions should call the same shared APIs.
- Compatibility wrappers may exist during migration, but new call sites should
  target the canonical shared APIs.
