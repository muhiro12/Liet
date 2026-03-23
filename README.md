# Liet

## Overview

Liet is an Apple-platform app scaffold aligned with the repository and
architecture conventions used by `../Incomes`.
It currently provides a thin iOS app target, a shared local package, app
smoke tests, and repo-managed verification entrypoints so future feature work
can start from a stable baseline.

## Targets

- **Liet** - the iOS app target that owns SwiftUI presentation and future
  Apple-framework adapters.
- **LietTests** - a lightweight app smoke-test target.
- **LietLibrary** - the shared library target intended to become the source of
  truth for reusable domain logic.

## Architecture and technologies

- **Shared-library-first** - reusable business rules belong in `LietLibrary`
  before they spread across app surfaces.
- **App-side adapters** - Apple-only integrations stay in `Liet`.
- **Platform package posture** - `Liet` adopts the `MHPlatform` umbrella,
  while `LietLibrary` adopts `MHPlatformCore`.
- **Utility package posture** - both the app target and shared library adopt
  `SwiftUtilities` through the repository-managed 1.x semver range.
- **Future extension readiness** - `AppGroup.id` and
  `Liet/Configurations/Liet.entitlements` already reserve the shared app group
  needed for future widgets or companion targets.

## Requirements

- Xcode 26.3 or later with the iOS 18 SDK installed.
- A local environment where `xcodebuild` and `xcrun` are available.

## Setup

1. Clone the repository and open the project directory.
2. Update bundle identifiers, `AppGroup.id`, and
   `Liet/Configurations/Liet.entitlements` if you are not using the default
   `com.muhiro12.Liet` identifiers.
3. Review `Liet/Configurations/Secret.swift`.
   The file contains compile-safe placeholder values and should be replaced
   before shipping real capabilities.
4. Open `Liet.xcodeproj` in Xcode and run the **Liet** scheme on an iOS 18
   simulator or device.

## Build and Test

Use the helper scripts in `ci_scripts/` as needed. The repository contract is:
Direct entrypoints live in `ci_scripts/tasks/`, shared shell helpers live in
`ci_scripts/lib/`, and `ci_scripts/ci_post_clone.sh` is reserved for external
post-clone CI setup.

- `bash ci_scripts/tasks/check_environment.sh --profile <format|build|verify>`
  diagnoses missing local prerequisites before you start a tool-dependent flow.
- `bash ci_scripts/tasks/format_swift.sh` is the explicit SwiftLint autofix
  step to run after Swift edits and before the final verification gate.
- `bash ci_scripts/tasks/verify_task_completion.sh` is the non-destructive
  verification gate for Codex task completion.
- `bash ci_scripts/tasks/verify_pre_commit.sh` reruns the same non-destructive
  verification gate for Git `pre-commit` and manual final rechecks.
- `bash ci_scripts/tasks/verify_repository_state.sh` checks the current
  repository state and still writes CI run artifacts.

SwiftLint is resolved from the `SimplyDanny/SwiftLintPlugins` package declared
in `Liet.xcodeproj`. The repository scripts do not require a separately
installed `swiftlint` binary on your `PATH`.

Before running the full verify gate, diagnose the local prerequisites:

```sh
bash ci_scripts/tasks/check_environment.sh --profile verify
```

After Swift edits, run the explicit autofix step:

```sh
bash ci_scripts/tasks/format_swift.sh
```

Then run the non-destructive full recheck:

```sh
bash ci_scripts/tasks/verify_task_completion.sh
```

If you only need library tests:

```sh
bash ci_scripts/tasks/test_shared_library.sh
```

If you only need app tests:

```sh
bash ci_scripts/tasks/test_app.sh
```

## CI artifact layout

CI helper scripts write all generated artifacts under `.build/ci/`.
Run-scoped outputs are stored in `.build/ci/runs/<RUN_ID>/` (summary, commands,
meta, logs, results, work), while shared caches and build state live in
`.build/ci/shared/` (`cache/`, `DerivedData/`, `tmp/`, `home/`).
