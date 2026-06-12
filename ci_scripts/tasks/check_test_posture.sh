#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

project_file="$repository_root/Liet.xcodeproj/project.pbxproj"
schemes_directory="$repository_root/Liet.xcodeproj/xcshareddata/xcschemes"
tests_directory="$repository_root/LietTests"
legacy_test_script="$repository_root/ci_scripts/tasks/test_app.sh"

failures=()

record_failure() {
  failures+=("$1")
}

if [[ -d "$tests_directory" ]]; then
  record_failure "Repository-owned app test directory must not exist at LietTests."
fi

if [[ -e "$legacy_test_script" ]]; then
  record_failure "Legacy app test entrypoint must not exist at ci_scripts/tasks/test_app.sh."
fi

if rg \
  --line-number \
  'LietTests|com\.apple\.product-type\.bundle\.unit-test|LietTests\.xctest' \
  "$project_file" >/dev/null; then
  record_failure "Liet.xcodeproj must not define a LietTests unit test target."
fi

if [[ -d "$schemes_directory" ]] &&
  rg --line-number 'LietTests|LietTests\.xctest' "$schemes_directory" >/dev/null; then
  record_failure "Shared Xcode schemes must not reference LietTests."
fi

if [[ ${#failures[@]} -ne 0 ]]; then
  echo "Liet test posture check failed." >&2

  for failure in "${failures[@]}"; do
    printf -- '- %s\n' "$failure" >&2
  done

  exit 1
fi

echo "Liet test posture check passed."
