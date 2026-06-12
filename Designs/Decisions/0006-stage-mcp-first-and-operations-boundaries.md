# ADR 0006: Stage MCP-First and Operations Boundaries

- Date: 2026-06-13
- Status: Accepted

## Context

Incomes' June 2026 design cleanup clarified three reusable portfolio patterns:

- delivery surfaces should enter shared business use cases through stable
  `*Operations` library facades
- local Apple verification should be MCP-first, with retained scripts limited
  to static repository rules, SwiftLint/autofix, optional audits, or checks MCP
  does not naturally cover
- repository environment work should support the intended architecture rather
  than merely document it

Liet already has the matching base shape: `LietLibrary` owns reusable batch
settings, preference state, import naming policy, processing planners, and
output naming, while `Liet` adapts that behavior to Photos, Files, ImageIO,
UIKit, Vision, TipKit, and SwiftUI.

Liet does not currently have widgets, watchOS, App Intents, or SwiftData
surfaces. The decision is therefore how to adopt the Incomes direction without
renaming current planner and store APIs only for symmetry.

## Decision

Liet will adopt the Incomes direction in stages:

1. Make Apple build, test, run, Simulator, log, screenshot, and UI snapshot
   evidence MCP-first.
2. Keep retained shell scripts focused on SwiftLint/autofix and static
   repository rules that XcodeBuildMCP does not naturally cover.
3. Keep `LietLibrary` as the source of truth for reusable batch-image rules.
4. Introduce public `*Operations` facades only when a behavior becomes a
   delivery-surface business use case or when the facade clarifies a boundary
   that app adapters should call.
5. Keep Apple-framework image import, rendering, background removal, Photos
   saving, file export, runtime assembly, and TipKit behavior in `Liet`.

### Direct Adoption

- Keep `LietLibrary` as the behavioral source of truth for reusable batch
  settings, preference state, naming, import filename policy, and processing
  planning.
- Keep `Liet` responsibility-thin: it owns SwiftUI presentation and
  Apple-framework adapters, but not duplicated reusable batch rules.
- Keep future App Intents as adapters rather than a parallel domain layer.
- Keep repository-owned unit tests in `LietLibrary/Tests`.
- Use XcodeBuildMCP as the default local and agent evidence surface for Apple
  build, test, run, Simulator, runtime log, screenshot, and UI snapshot checks.

### Staged Adoption

- Treat current planner and store APIs as valid library collaborators while
  there is only one delivery surface and no clearer Operations facade.
- Add or migrate to `*Operations` by behavior boundary, not by mechanical
  rename. The facade should describe the business use case that delivery
  surfaces call.
- If a future view, widget, App Intent, or shortcut starts calling lower-level
  helpers for reusable business behavior, first add a shared Operations
  boundary rather than copying the helper into the surface.
- Introduce Liet-specific Operations static checks only after the boundary is
  enforceable. Do not copy Incomes' finance-domain collaborator deny-list or
  Cookle's recipe-domain deny-list.
- Keep shell aggregate build/test gates as compatibility wrappers while MCP
  build/test evidence and retained repository rules become the standard path.

### Non-Goals

- Do not introduce Incomes finance operation families, SwiftData mutation
  flows, watch sync contracts, widget contracts, or navigation helpers.
- Do not introduce Cookle recipe, diary, tag, photo, or SwiftData operation
  families.
- Do not rename batch planners or preference stores unless doing so clarifies a
  real delivery-surface business boundary.
- Do not add process-heavy public repository artifacts solely for portfolio
  symmetry.

## Consequences

- Future cross-surface behavior should prefer `*Operations` facades, but
  current planner and store names remain appropriate until an Operations
  boundary improves the API.
- XcodeBuildMCP becomes the preferred evidence surface, while shell scripts
  stay focused on retained repository rules, SwiftLint/autofix, and fallback
  compatibility.
- Further refactors should be driven by concrete Liet boundary drift rather
  than superficial parity with Incomes or Cookle.
