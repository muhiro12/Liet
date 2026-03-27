# Liet Current Product and Architecture Overview

Current as of March 28, 2026.

## Purpose

Liet is currently an iPhone batch image pre-processing product with separate
resize and background-removal feature flows.
The implementation keeps reusable batch-image state, naming rules, and
processing planners in `LietLibrary`, while Apple-framework adapters and UI
remain in the app target.

## Product Surface Summary

- `Liet`
  Primary product surface for the two-screen SwiftUI flow, photo import,
  image processing, Files export, and Photos saving.
- `LietLibrary`
  Shared domain layer for batch settings, persisted preferences state, import
  filename policy, processing planners, and processed file naming.
- `LietLibraryTests`
  Primary logic verification surface for platform-neutral batch-image
  mutations, planning rules, persistence values, and naming behavior.

## Current Platform Package Posture

- `Liet` intentionally adopts the full `MHPlatform` umbrella.
- `LietLibrary` intentionally adopts `MHPlatformCore`.
- This repository intentionally tracks MHPlatform with the 1.x semver range
  `1.0.0..<2.0.0`.
- This repository intentionally tracks SwiftUtilities with the 1.x semver range
  `1.0.0..<2.0.0`.

## Current End-User Features

- Choose either a resize flow or a background-removal flow from the app entry
  screen.
- Select multiple images from the photo library.
- Review imported image thumbnails before processing.
- Resize all selected images with one long-edge pixel setting while preserving
  aspect ratio and avoiding upscaling.
- Compress all selected images with one shared quality setting.
- Remove backgrounds from all selected images with one shared tuning setup and
  export transparent PNG copies at the original size.
- Preserve JPEG, PNG, and HEIC output when possible.
- Fall back to JPEG for unsupported formats and for HEIC when the current
  runtime cannot encode HEIC output.
- Save processed images either to the Files app or to the Photos app as new
  files.

## Current Engineering Features

- Local-package-based shared library integration through `LietLibrary`.
- Shared-library-owned pure state and planners for batch-image preferences,
  filename resolution, import filename selection, and processing decisions.
- App-side adapter isolation for `PhotosUI`, `PhotoKit`, `ImageIO`, `TipKit`,
  `AppStorage`, and file export APIs.
- Logic verification concentrated in `LietLibraryTests`, while the app target
  is validated by build-only CI checks.
- Partial-success batch processing so one failed image does not block the
  successful outputs.
- Repo-managed verification shells under `ci_scripts/tasks`.
- Project-managed SwiftLint resolution through `SwiftLintPlugins`.
- ADR and architecture documents aligned to the shared-library-first design.
