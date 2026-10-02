#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

if ! command -v rg >/dev/null 2>&1; then
  echo "Source boundary check could not run: ripgrep is unavailable." >&2
  exit 2
fi

surface_sources=(
  "$repository_root/Liet/Sources"
)

library_sources=(
  "$repository_root/LietLibrary/Sources"
)

internal_collaborators=(
  BatchImageProcessingPlanner
  BatchBackgroundRemovalPlanner
  BatchImageFilenamePlanner
  BatchImageImportFilenamePolicy
  BatchImageArchiveBuilder
  ProcessedImageNaming
  BatchImagePreferencesStore
  BatchBackgroundRemovalPreferencesStore
)

failures=()

record_failure() {
  failures+=("$1")
}

collaborator_pattern=$(
  IFS='|'
  printf '%s' "${internal_collaborators[*]}"
)

set +e
collaborator_matches=$(
  rg \
    --line-number \
    "\\b(${collaborator_pattern})\\b" \
    "${surface_sources[@]}" \
    -g '*.swift'
)
search_status=$?
set -e
if (( search_status > 1 )); then
  echo "Source boundary check could not run: ripgrep exited $search_status." >&2
  exit 2
fi

if [[ -n "$collaborator_matches" ]]; then
  record_failure "Delivery surfaces must call public *Operations facades instead of internal library collaborators:
$collaborator_matches"
fi

set +e
public_collaborator_declarations=$(
  rg \
    --line-number \
    "^[[:space:]]*(public|open)[[:space:]]+(final[[:space:]]+class|class|struct|enum|actor)[[:space:]]+(${collaborator_pattern})\\b" \
    "${library_sources[@]}" \
    -g '*.swift'
)
search_status=$?
set -e
if (( search_status > 1 )); then
  echo "Source boundary check could not run: ripgrep exited $search_status." >&2
  exit 2
fi

if [[ -n "$public_collaborator_declarations" ]]; then
  record_failure "Internal batch collaborators must not be public library API:
$public_collaborator_declarations"
fi

if [[ ${#failures[@]} -ne 0 ]]; then
  echo "Operations boundary check failed." >&2

  for failure in "${failures[@]}"; do
    printf -- '- %s\n' "$failure" >&2
  done

  exit 1
fi

echo "Operations boundary check passed."
