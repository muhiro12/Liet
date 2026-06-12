# AGENTS.md

Repository-specific agent contract for Liet.

## Repository Rules

- Use English for branch names, code comments, documentation, and identifiers
  unless UI localization or legal content requires otherwise.
- Follow existing architecture and source style; keep changes small and
  repository-local.
- Markdown must follow
  <https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md>.
- Swift code must comply with the repository SwiftLint configuration.

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

When Swift files are edited, agents should run:

``` sh
bash ci_scripts/tasks/format_swift.sh
```

Agents should also run the retained repository rule checks:

``` sh
bash ci_scripts/tasks/check_repository_rules.sh
```

`check_repository_rules.sh` runs SwiftLint plus repository-specific static
architecture checks that are not naturally covered by XcodeBuildMCP.
SwiftLint is resolved from the `SimplyDanny/SwiftLintPlugins` package declared
in `Liet.xcodeproj`, not from a separately installed `swiftlint` binary.
Xcode Cloud owns formal CI builds, tests, and archives.

Compatibility scripts such as `verify_task_completion.sh`,
`verify_repository_state.sh`, `build_app.sh`, and `test_shared_library.sh`
remain available when MCP coverage is unavailable or a retained aggregate shell
gate is explicitly needed. They may write disposable CI artifacts under
`.build/ci/runs/<RUN_ID>/` and shared data under `.build/ci/shared/`. Only the
newest 5 run directories are retained.

## Release UI Smoke Audit

Release UI smoke auditing is separate from the standard verification entrypoint.
Keep it non-destructive by default: do not erase simulator data, reset
containers, or add UI test targets solely for the audit unless explicitly
requested.
