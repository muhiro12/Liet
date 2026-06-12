#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

package_manifest="$repository_root/LietLibrary/Package.swift"
library_sources="$repository_root/LietLibrary/Sources"

forbidden_source_imports=(
  AppIntents
  CoreImage
  CoreTransferable
  ImageIO
  MHDesign
  MHPlatform
  MHUI
  Photos
  PhotosUI
  SwiftUI
  TipKit
  UIKit
  UniformTypeIdentifiers
  Vision
)

forbidden_package_references=(
  AppIntents
  CoreTransferable
  MHDesign
  MHUI
  PhotosUI
  SwiftUI
  TipKit
)

failures=()

record_failure() {
  failures+=("$1")
}

source_import_pattern=$(
  IFS='|'
  printf '%s' "${forbidden_source_imports[*]}"
)

source_import_matches=$(
  rg \
    --line-number \
    "^(@preconcurrency )?import (${source_import_pattern})$" \
    "$library_sources" \
    -g '*.swift' || true
)

if [[ -n "$source_import_matches" ]]; then
  record_failure "LietLibrary/Sources must not import UI or platform-adapter frameworks:
$source_import_matches"
fi

package_reference_pattern=$(
  IFS='|'
  printf '%s' "${forbidden_package_references[*]}"
)

package_reference_matches=$(
  rg \
    --line-number \
    "(${package_reference_pattern})" \
    "$package_manifest" || true
)

if [[ -n "$package_reference_matches" ]]; then
  record_failure "LietLibrary/Package.swift must not depend on UI or presentation packages:
$package_reference_matches"
fi

if [[ ${#failures[@]} -ne 0 ]]; then
  echo "Liet architecture boundary check failed." >&2

  for failure in "${failures[@]}"; do
    printf -- '- %s\n' "$failure" >&2
  done

  exit 1
fi

echo "Liet architecture boundary check passed."
