# Liet

## Branches and release review

Use `develop` for daily development. Keep agent review and the documented
verification checks in the daily workflow. `main` tracks the released baseline.
Before shipping, review `main...develop` and record the exact candidate commit.
After publication, merge that released commit into `main`; do not include later
work added to `develop`. Preserve commit ancestry so the next release comparison
starts from the previous released candidate.

## Overview

Liet is an iPhone batch image pre-processing app shaped by the
shared-library-first architecture and Apple-platform conventions established
in Incomes, without requiring a sibling checkout.
The current MVP offers two dedicated batch jobs chosen from the app entry
screen: resize a batch with shared size and compression settings, or remove
backgrounds to create transparent PNG copies. Both flows save processed
results as new files to either Files or Photos.

## Targets

- **Liet** - the iOS app target that owns the SwiftUI flow and Apple-framework
  adapters for image import, image processing, file export, and photo saving.
- **LietLibrary** - the shared library target that owns public batch-image
  `*Operations` facades, reusable settings, persistence state, and internal
  planning, naming, import, archive, and preference collaborators.
- **LietLibraryTests** - the primary logic verification surface for
  platform-neutral batch-image behavior.

## Architecture and technologies

- **Shared-library-first** - reusable batch-image value types and pure rules
  live in `LietLibrary` before they spread across app surfaces.
- **App-side adapters** - `PhotosUI`, `PhotoKit`, `ImageIO`, `UIKit`,
  `TipKit`, `fileImporter`, and `fileExporter` stay in `Liet`.
- **Platform package posture** - `Liet` adopts the `MHPlatform` umbrella,
  while `LietLibrary` adopts `MHPlatformCore`.
- **Runtime bootstrap posture** - the app root owns a `LietAppAssembly` that
  holds `MHAppRuntimeBootstrap(configuration:)`, while shared preference
  descriptors continue using `AppGroup.preferencesDefaultsSelection`.
- **Operations boundary** - delivery surfaces enter reusable batch-image use
  cases through public `*Operations` facades. Lower-level planners, stores,
  naming helpers, archive builders, and import policies remain internal
  library collaborators.
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
  `LietLibrary` Operations backed by `MHPlatformCore` preference persistence.

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

Use Xcode and the Xcode-native integration available in the agent environment
for Apple build, test, run, Simulator, runtime-log, Preview, live UI, and
screenshot evidence. Xcode Cloud owns formal CI builds, tests, and archives.

The remaining helper scripts in `ci_scripts/` support retained repository
rules. Direct entrypoints live in `ci_scripts/tasks/`, shared shell helpers
live in `ci_scripts/lib/`, and
`ci_scripts/ci_post_clone.sh` is reserved for external post-clone CI setup.

- The available Xcode-native integration owns Apple build, test, run,
  Simulator, runtime-log, Preview, live UI, and screenshot evidence.
- `bash ci_scripts/tasks/check_environment.sh --profile <profile>` diagnoses
  missing local prerequisites before you start a tool-dependent flow. Use
  `swiftlint` or `rules`.
- `bash ci_scripts/tasks/format_swift.sh` is the explicit SwiftLint autofix
  step to run after Swift edits.
- `bash ci_scripts/tasks/check_repository_rules.sh` runs retained SwiftLint and
  static architecture checks that are not naturally covered by the available
  Xcode-native integration.
- Release UI smoke auditing is intentionally separate from the normal verify
  gate. Use the global `$xcode-ui-smoke-auditor` skill and the
  [release UI smoke audit guide](Designs/Architecture/release-ui-smoke-audit.md)
  when a release or UI-sensitive change needs live Simulator evidence.
  Keep audits non-destructive by default: do not erase Simulator data, reset
  containers, or add UI test targets solely for an audit unless explicitly
  requested.

SwiftLint is resolved from the `SimplyDanny/SwiftLintPlugins` package declared
in `Liet.xcodeproj`. The repository scripts do not require a separately
installed `swiftlint` binary on your `PATH`.

Before running retained repository rules, diagnose the local prerequisites:

```sh
bash ci_scripts/tasks/check_environment.sh --profile rules
```

After Swift edits, run the explicit autofix step:

```sh
bash ci_scripts/tasks/format_swift.sh
```

Then run retained repository rules:

```sh
bash ci_scripts/tasks/check_repository_rules.sh
```

Before changing Xcode's active selection, discover `Liet.xcodeproj`, its
schemes, and its run destinations. Record the original scheme and destination,
and switch only to discovered values. After verification, restore the original
scheme first, rediscover its valid destinations, restore the original
destination, and confirm the final selection. Report any selection that cannot
be restored.

Treat library tests, consumer builds, retained repository rules, and runtime/UI
evidence separately. Choose the smallest set that proves the changed boundary:

- For shared-library logic, model, or test changes, test the `LietLibrary`
  scheme on a discovered iOS Simulator destination.
- For public `LietLibrary` APIs, `*Operations`, shared or wire contracts,
  SwiftData schema, or adapter-facing contracts, also build the `Liet` scheme.
- For app compile changes, build `Liet.xcodeproj` with the `Liet` scheme on a
  discovered iOS Simulator destination.
- For lifecycle, runtime, or UI-sensitive changes, add a targeted run,
  runtime-log review, Preview rendering when appropriate, and live UI or
  screenshot evidence.

Follow the repository's source style and SwiftLint configuration. Markdown
should follow the
[markdownlint rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md).

## CI artifact layout

CI helper scripts write disposable shared cache and build state under
`.build/ci/shared/` (`cache/`, `DerivedData/`, `tmp/`, `home/`).
