# AGENTS.md

This document defines the repository-specific agent behavior contract for
Liet.

Keep this file self-contained enough for agents working from a fresh clone.
Repeat portable rules here when they are required to work safely in this
repository; keep local-machine-only routing, broad development philosophy, and
cross-repository principles outside the repository.

## Agent Philosophy

- Follow existing repository conventions as the source of truth.
- Do not invent architecture or workflows.
- When uncertain, prefer leaving TODO comments rather than guessing.
- Prefer **minimal, safe changes** over large refactors.

## Naming and Language Rules

Use English for:

- Branch names
- Code comments
- Documentation
- Identifiers

Avoid non-English text unless required for UI localization or legal content.

## Markdown Guidelines

All Markdown files must follow:

https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md

## Swift Code Guidelines

### Follow SwiftLint rules

All Swift code must comply with the project's SwiftLint configuration.

### Avoid abbreviated variable names

#### Preferred

- `result`
- `image`
- `button`

#### Not preferred

- `res`
- `img`
- `btn`

### Use `.init(...)` when return type is explicit

#### Preferred

```swift
var user: User {
    .init(name: "Alice")
}
```

#### Not preferred

```swift
var user: User {
    User(name: "Alice")
}
```

### Multiline control-flow formatting

Do NOT use single-line bodies for control-flow statements or trailing closures.

#### Preferred

```swift
guard let currentUser else {
    return
}

if isDebugMode {
    logger.debug("Entering debug state")
}

tasks.filter { task in
    task.isCompleted
}
```

#### Not preferred

```swift
guard let currentUser else { return }
if isDebugMode { logger.debug("Entering debug state") }
tasks.filter { $0.isCompleted }
```

## Build and Test Entry Point

Agents MUST prefer XcodeBuildMCP for Apple build, test, run, Simulator,
runtime log, screenshot, and UI snapshot verification.

Before the first XcodeBuildMCP build, test, or run call in a session, run
XcodeBuildMCP `session_show_defaults`. If defaults do not point at this
repository, set them for the current session before continuing.

For app compile checks, use XcodeBuildMCP `build_sim` with the `Liet` scheme.
For shared-library tests, use XcodeBuildMCP `test_sim` with the `LietLibrary`
scheme. For runtime or UI-sensitive checks, use XcodeBuildMCP `build_run_sim`,
`launch_app_sim`, `snapshot_ui`, and `screenshot` as appropriate.

Agents may run `bash ci_scripts/tasks/check_environment.sh --profile verify`
first to diagnose missing local prerequisites.
When Swift files are edited, agents should run
`bash ci_scripts/tasks/format_swift.sh` before the final verification gate.
Use `bash ci_scripts/tasks/verify_task_completion.sh` when the task needs the
retained aggregate shell gate or when MCP coverage is unavailable.
Use `bash ci_scripts/tasks/verify_repository_state.sh` when only change-based
repository-state checks are needed.
`bash ci_scripts/tasks/verify_pre_push.sh` reruns the same non-destructive
verification shell for optional Git `pre-push` hooks and manual final checks.
SwiftLint is resolved from the `SimplyDanny/SwiftLintPlugins` package declared
in `Liet.xcodeproj`, not from a separately installed `swiftlint` binary.

CI run artifacts are written under `.build/ci/runs/<RUN_ID>/`.
Each run stores `summary.md`, `commands.txt`, `meta.json`, `logs/`, `results/`, and `work/`.
Shared CI directories are under `.build/ci/shared/` (`cache/`, `DerivedData/`, `tmp/`, `home/`).
Only the newest 5 run directories are retained.
The entire `.build/ci` directory is disposable.
