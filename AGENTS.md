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

Compatibility scripts write disposable CI artifacts under
`.build/ci/runs/<RUN_ID>/` and shared data under `.build/ci/shared/`. Only the
newest 5 run directories are retained.
