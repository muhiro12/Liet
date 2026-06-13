#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

if ! ci_task_should_skip_environment_check; then
  bash "$repository_root/ci_scripts/tasks/check_environment.sh" --profile rules
fi

CI_SKIP_ENV_CHECK=1 bash "$repository_root/ci_scripts/tasks/lint_swift.sh"
bash "$repository_root/ci_scripts/tasks/check_mhplatform_boundaries.sh"
bash "$repository_root/ci_scripts/tasks/check_liet_architecture_boundaries.sh"
bash "$repository_root/ci_scripts/tasks/check_operations_boundaries.sh"
bash "$repository_root/ci_scripts/tasks/check_test_posture.sh"
bash "$repository_root/ci_scripts/tasks/check_models_directory_consistency.sh"

echo "Repository rules check passed."
