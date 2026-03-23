# Liet Current Product and Architecture Overview

Current as of March 23, 2026.

## Purpose

Liet is currently an iPhone batch image pre-processing product.
The implementation keeps reusable batch-image settings and format rules in
`LietLibrary`, while Apple-framework adapters and UI remain in the app target.

## Product Surface Summary

| Surface | Current role | Key responsibilities |
| --- | --- | --- |
| `Liet` | Primary product surface | Two-screen SwiftUI flow, photo import, image processing, Files export, Photos saving |
| `LietTests` | App verification surface | Verify the processing pipeline, success and failure handling, and root wiring |
| `LietLibrary` | Shared domain layer | Batch settings, compression levels, supported output formats, processed file naming |

## Current Platform Package Posture

- `Liet` intentionally adopts the full `MHPlatform` umbrella.
- `LietLibrary` intentionally adopts `MHPlatformCore`.
- This repository intentionally tracks MHPlatform with the 1.x semver range
  `1.0.0..<2.0.0`.
- This repository intentionally tracks SwiftUtilities with the 1.x semver range
  `1.0.0..<2.0.0`.

## Current End-User Features

- Select multiple images from the photo library.
- Review imported image thumbnails before processing.
- Resize all selected images with one long-edge pixel setting while preserving
  aspect ratio and avoiding upscaling.
- Compress all selected images with one shared quality setting.
- Preserve JPEG, PNG, and HEIC output when possible.
- Fall back to JPEG for unsupported formats and for HEIC when the current
  runtime cannot encode HEIC output.
- Save processed images either to the Files app or to the Photos app as new
  files.

## Current Engineering Features

- Local-package-based shared library integration through `LietLibrary`.
- App-side adapter isolation for `PhotosUI`, `PhotoKit`, `ImageIO`, and file
  export APIs.
- Partial-success batch processing so one failed image does not block the
  successful outputs.
- Repo-managed verification shells under `ci_scripts/tasks`.
- Project-managed SwiftLint resolution through `SwiftLintPlugins`.
- ADR and architecture documents aligned to the shared-library-first design.
