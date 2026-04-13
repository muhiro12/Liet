# Liet

## Overview

Liet is an iPhone batch image pre-processing app aligned with the repository
and architecture conventions used by `../Incomes`.
The current MVP offers two dedicated batch jobs chosen from the app entry
screen: resize a batch with shared size and compression settings, or remove
backgrounds to create transparent PNG copies. Both flows save processed
results as new files to either Files or Photos.

## Targets

- **Liet** - the iOS app target that owns the SwiftUI flow and Apple-framework
  adapters for image import, image processing, file export, and photo saving.
- **LietLibrary** - the shared library target that owns reusable batch-image
  settings, persistence state, import naming policy, processing planners, and
  output naming.
- **LietLibraryTests** - the primary logic verification surface for
  platform-neutral batch-image behavior.

## Architecture and technologies

- **Shared-library-first** - reusable batch-image value types and pure rules
  live in `LietLibrary` before they spread across app surfaces.
- **App-side adapters** - `PhotosUI`, `PhotoKit`, `ImageIO`, `UIKit`,
  `TipKit`, `fileImporter`, and `fileExporter` stay in `Liet`.
- **Platform package posture** - `Liet` adopts the `MHPlatform` umbrella,
  while `LietLibrary` adopts `MHPlatformCore`.
- **Runtime bootstrap posture** - the app root uses
  `MHAppRuntimeBootstrap(configuration:)` with `AppGroup.id` as the shared
  preferences suite.
- **Utility package posture** - both the app target and shared library adopt
  `SwiftUtilities` through the repository-managed 1.x semver range.
- **Non-destructive processing** - source images are never overwritten.
  Processed images are always written as new files in a temporary workspace
  before the user exports or saves them.

## Current MVP behavior

- Choose either the resize flow or the background-removal flow from the entry
  screen.
- Select multiple images from the Photos library or the Files app.
- Review selected images in a thumbnail grid before processing.
- Apply one long-edge resize setting to every image while preserving aspect
  ratio and avoiding upscaling.
- Apply one compression setting to every image:
  JPEG and HEIC use quality values, while PNG keeps its format and ignores the
  quality setting.
- Remove backgrounds for all selected images with one shared tuning setup and
  transparent PNG output at the original size.
- Preserve the original image format when possible for JPEG, PNG, and HEIC.
- Fall back to JPEG when the original format is unsupported or when HEIC
  output is unavailable on the current runtime.
- Save processed results either to the Files app or to the Photos app.
- Persist last used settings plus one manually saved user preset through
  `LietLibrary` stores backed by `MHPlatformCore` preference persistence.

## Current limitations

- The MVP does not preserve detailed metadata such as EXIF payloads.
- There is no per-image customization, editing UI, background processing, or
  overwrite flow.
- The current app target does not yet include regional consent flows such as
  UMP or ATT for advertising.

## Requirements

- Xcode 26.3 or later with the iOS 18 SDK installed.
- A local environment where `xcodebuild` and `xcrun` are available.

## Setup

1. Clone the repository and open the project directory.
2. The app's native AdMob placements are wired through `MHPlatform`.
   `Liet/Configurations/Info.plist` already carries the live AdMob app ID, and
   Debug builds use Google's standard native test ad unit.
3. Open `Liet.xcodeproj` in Xcode and run the **Liet** scheme on an iOS 18
   simulator or device.
4. When saving to Photos, allow the add-only Photo Library permission when the
   app requests it.
5. Before shipping an update with ads, review App Store Connect privacy
   disclosures and any regional consent requirements because this repository
   currently does not include UMP or ATT flows.

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
- `bash ci_scripts/tasks/verify_pre_push.sh` reruns the same non-destructive
  verification gate for optional Git `pre-push` hooks and manual final
  rechecks.
- `bash ci_scripts/tasks/verify_repository_state.sh` checks the current
  repository state and still writes CI run artifacts.
- `bash ci_scripts/tasks/test_shared_library.sh` runs the primary logic test
  surface in `LietLibraryTests`.
- `bash ci_scripts/tasks/build_app.sh` builds the app target when app-side
  changes need a compile check.

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

If you only need an app compile check:

```sh
bash ci_scripts/tasks/build_app.sh
```

## CI artifact layout

CI helper scripts write all generated artifacts under `.build/ci/`.
Run-scoped outputs are stored in `.build/ci/runs/<RUN_ID>/` (summary, commands,
meta, logs, results, work), while shared caches and build state live in
`.build/ci/shared/` (`cache/`, `DerivedData/`, `tmp/`, `home/`).
