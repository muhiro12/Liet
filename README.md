# Liet

## Overview

Liet is an iPhone batch image pre-processing app aligned with the repository
and architecture conventions used by `../Incomes`.
The current MVP focuses on one job: select multiple photos, apply one resize
and compression setting to all of them, then save the processed results as new
files to either Files or Photos.

## Targets

- **Liet** - the iOS app target that owns the SwiftUI flow and Apple-framework
  adapters for photo import, image processing, file export, and photo saving.
- **LietTests** - the app test target covering the MVP processing pipeline and
  root wiring.
- **LietLibrary** - the shared library target that owns reusable batch-image
  settings, format rules, and output naming.

## Architecture and technologies

- **Shared-library-first** - reusable batch-image value types live in
  `LietLibrary` before they spread across app surfaces.
- **App-side adapters** - `PhotosUI`, `PhotoKit`, `ImageIO`, `UIKit`, and
  `fileExporter` stay in `Liet`.
- **Platform package posture** - `Liet` adopts the `MHPlatform` umbrella,
  while `LietLibrary` adopts `MHPlatformCore`.
- **Utility package posture** - both the app target and shared library adopt
  `SwiftUtilities` through the repository-managed 1.x semver range.
- **Non-destructive processing** - source images are never overwritten.
  Processed images are always written as new files in a temporary workspace
  before the user exports or saves them.

## Current MVP behavior

- Select multiple images from the photo library with `PhotosPicker`.
- Review selected images in a thumbnail grid before processing.
- Apply one long-edge resize setting to every image while preserving aspect
  ratio and avoiding upscaling.
- Apply one compression setting to every image:
  JPEG and HEIC use quality values, while PNG keeps its format and ignores the
  quality setting.
- Preserve the original image format when possible for JPEG, PNG, and HEIC.
- Fall back to JPEG when the original format is unsupported or when HEIC
  output is unavailable on the current runtime.
- Save processed results either to the Files app or to the Photos app.
- Persist saved default settings and last used settings in App Group
  `UserDefaults`.

## Current limitations

- The MVP does not preserve detailed metadata such as EXIF payloads.
- There is no per-image customization, editing UI, background processing, or
  overwrite flow.

## Requirements

- Xcode 26.3 or later with the iOS 18 SDK installed.
- A local environment where `xcodebuild` and `xcrun` are available.

## Setup

1. Clone the repository and open the project directory.
2. Update bundle identifiers, `AppGroup.id`, and
   `Liet/Configurations/Liet.entitlements` if you are not using the default
   `com.muhiro12.Liet` identifiers.
3. Review `Liet/Configurations/Secret.swift`.
   The file contains compile-safe placeholder values inherited from the repo
   baseline and should be replaced before shipping real capabilities.
4. Open `Liet.xcodeproj` in Xcode and run the **Liet** scheme on an iOS 18
   simulator or device.
5. When saving to Photos, allow the add-only Photo Library permission when the
   app requests it.

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
