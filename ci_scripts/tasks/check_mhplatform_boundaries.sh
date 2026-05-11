#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

expected_mhplatform_dependency_remote="https://github.com/muhiro12/MHPlatform"
expected_mhplatform_project_remote="https://github.com/muhiro12/MHPlatform"
expected_mhplatform_minimum_version="1.0.0"
expected_swiftutilities_remote="https://github.com/muhiro12/SwiftUtilities"
expected_swiftutilities_minimum_version="1.0.0"
package_manifest="LietLibrary/Package.swift"
package_resolved="LietLibrary/Package.resolved"
project_file="Liet.xcodeproj/project.pbxproj"
documentation_files=(
  README.md
  Designs/Architecture/shared-service-design.md
  Designs/Overviews/liet-current-overview.md
)
core_safe_modules=(
  MHDeepLinking
  MHLogging
  MHNotificationPayloads
  MHNotificationPlans
  MHRouteExecution
  MHPersistenceMaintenance
  MHPreferences
)

failures=()

record_failure() {
  failures+=("$1")
}

extract_project_block() {
  local block_name=$1

  awk -v block_name="$block_name" '
    index($0, "/* " block_name " */ = {") && $0 ~ /\{$/ { capture = 1 }
    capture { print }
    capture && $0 == "\t\t};" { exit }
  ' "$project_file"
}

extract_native_target_block() {
  local target_name=$1

  awk -v target_name="$target_name" '
    $0 == "/* Begin PBXNativeTarget section */" { in_native_targets = 1; next }
    $0 == "/* End PBXNativeTarget section */" { in_native_targets = 0 }
    in_native_targets && index($0, "/* " target_name " */ = {") && $0 ~ /\{$/ { capture = 1 }
    capture { print }
    capture && $0 == "\t\t};" { exit }
  ' "$project_file"
}

extract_manifest_dependency_block() {
  local remote_url=$1

  awk -v remote_url="$remote_url" '
    index($0, "url: \"" remote_url "\"") { capture = 1 }
    capture { print }
    capture && $0 ~ /^[[:space:]]*\),?$/ { exit }
  ' "$package_manifest"
}

extract_resolved_pin_block() {
  local remote_url=$1

  awk -v remote_url="$remote_url" '
    index($0, "\"location\" : \"" remote_url "\"") { capture = 1 }
    capture { print }
    capture && $0 ~ /^    },?$/ { exit }
  ' "$package_resolved"
}

check_semver_dependency() {
  local label=$1
  local dependency_remote_url=$2
  local project_remote_url=$3
  local expected_range=$4
  local minimum_version=$5
  local manifest_block
  local resolved_block
  local project_block

  manifest_block=$(extract_manifest_dependency_block "$dependency_remote_url")
  if [[ -z "$manifest_block" ]]; then
    record_failure "$package_manifest must reference the canonical $label remote."
  else
    if ! grep -q --fixed-strings "$expected_range" <<<"$manifest_block"; then
      record_failure "$package_manifest must declare the $label semver range $expected_range."
    fi

    if grep -q --fixed-strings 'branch:' <<<"$manifest_block"; then
      record_failure "$package_manifest must not track $label by branch."
    fi

    if grep -q --fixed-strings 'revision:' <<<"$manifest_block"; then
      record_failure "$package_manifest must not pin $label by exact revision."
    fi
  fi

  resolved_block=$(extract_resolved_pin_block "$dependency_remote_url")
  if [[ -z "$resolved_block" ]]; then
    record_failure "$package_resolved must resolve $label from the canonical remote."
  else
    if ! grep -Eq '"version" : "1\.[^"]+"' <<<"$resolved_block"; then
      record_failure "$package_resolved must resolve $label to a tagged 1.x release."
    fi
  fi

  project_block=$(extract_project_block "XCRemoteSwiftPackageReference \"$label\"")
  if [[ -z "$project_block" ]]; then
    record_failure "$project_file must define a $label remote package reference."
  else
    if ! grep -q --fixed-strings "repositoryURL = \"$project_remote_url\";" <<<"$project_block"; then
      record_failure "$project_file must reference the canonical $label remote."
    fi

    if ! grep -q --fixed-strings 'kind = upToNextMajorVersion;' <<<"$project_block"; then
      record_failure "$project_file must use a $label 1.x semver requirement."
    fi

    if ! grep -q --fixed-strings "minimumVersion = $minimum_version;" <<<"$project_block"; then
      record_failure "$project_file must set the $label minimum version to $minimum_version."
    fi
  fi
}

if rg -q '\.package\(\s*path:\s*"[^"]*MHPlatform' "$package_manifest"; then
  record_failure "$package_manifest must not use a local path dependency for MHPlatform."
fi

if rg -q '\.package\(\s*path:\s*"[^"]*SwiftUtilities' "$package_manifest"; then
  record_failure "$package_manifest must not use a local path dependency for SwiftUtilities."
fi

check_semver_dependency "MHPlatform" "$expected_mhplatform_dependency_remote" "$expected_mhplatform_project_remote" "\"1.0.0\"..<\"2.0.0\"" "$expected_mhplatform_minimum_version"
check_semver_dependency "SwiftUtilities" "$expected_swiftutilities_remote" "$expected_swiftutilities_remote" "\"1.0.0\"..<\"2.0.0\"" "$expected_swiftutilities_minimum_version"

if rg -q 'name:\s*"MHPlatform"' "$package_manifest"; then
  record_failure "LietLibrary must not depend on the umbrella MHPlatform product."
fi

if ! rg -q 'name:\s*"MHPlatformCore"' "$package_manifest"; then
  record_failure "LietLibrary must depend on the MHPlatformCore product."
fi

if ! rg -q 'name:\s*"SwiftUtilities"' "$package_manifest"; then
  record_failure "LietLibrary must depend on the SwiftUtilities product."
fi

for module_name in "${core_safe_modules[@]}"; do
  if rg -q "name:\\s*\"$module_name\"" "$package_manifest"; then
    record_failure "LietLibrary must not declare direct MHPlatform core-safe module dependency $module_name."
  fi
done

if rg -q --fixed-strings 'XCLocalSwiftPackageReference "MHPlatform"' "$project_file"; then
  record_failure "Liet.xcodeproj must not use a local MHPlatform package reference."
fi

if rg -q --fixed-strings 'XCLocalSwiftPackageReference "SwiftUtilities"' "$project_file"; then
  record_failure "Liet.xcodeproj must not use a local SwiftUtilities package reference."
fi

liet_target_block=$(extract_native_target_block 'Liet')
if [[ -z "$liet_target_block" ]] || ! grep -q --fixed-strings 'MHPlatform' <<<"$liet_target_block"; then
  record_failure "Liet must remain the MHPlatform umbrella adopter."
fi

if [[ -z "$liet_target_block" ]] || ! grep -q --fixed-strings 'SwiftUtilities' <<<"$liet_target_block"; then
  record_failure "Liet must keep the SwiftUtilities package dependency."
fi

if rg -q --fixed-strings 'PBXNativeTarget "LietTests"' "$project_file"; then
  record_failure "Liet.xcodeproj must not declare the removed LietTests target."
fi

umbrella_import_matches=$(
  rg \
    --line-number \
    '^(@preconcurrency )?import MHPlatform$' \
    LietLibrary \
    -g '*.swift' || true
)

if [[ -n "$umbrella_import_matches" ]]; then
  record_failure "Umbrella import MHPlatform is not allowed in LietLibrary:
$umbrella_import_matches"
fi

direct_core_module_imports=$(
  rg \
    --line-number \
    '^(@preconcurrency )?import (MHDeepLinking|MHLogging|MHNotificationPayloads|MHNotificationPlans|MHRouteExecution|MHPersistenceMaintenance|MHPreferences)$' \
    LietLibrary/Sources \
    -g '*.swift' || true
)

if [[ -n "$direct_core_module_imports" ]]; then
  record_failure "LietLibrary/Sources must import MHPlatformCore instead of direct core-safe MHPlatform modules:
$direct_core_module_imports"
fi

app_direct_module_imports=$(
  rg \
    --line-number \
    '^(@preconcurrency )?import (MHAppRuntime|MHPlatformCore|MHDeepLinking|MHLogging|MHNotificationPayloads|MHNotificationPlans|MHRouteExecution|MHPersistenceMaintenance|MHPreferences|MHMutationFlow|MHReviewPolicy)$' \
    Liet/Sources \
    -g '*.swift' || true
)

if [[ -n "$app_direct_module_imports" ]]; then
  record_failure "Liet/Sources must import MHPlatform instead of direct MHPlatform modules:
$app_direct_module_imports"
fi

app_umbrella_imports=$(
  rg \
    --line-number \
    '^(@preconcurrency )?import MHPlatform$|^@_exported import MHPlatform$' \
    Liet/Sources \
    -g '*.swift' || true
)

if [[ -z "$app_umbrella_imports" ]]; then
  record_failure "Liet/Sources must use the MHPlatform umbrella import."
fi

legacy_runtime_core_references=$(
  rg \
    --line-number \
    'MHAppRuntimeCore' \
    Liet \
    LietLibrary \
    README.md \
    Designs \
    -g '*.swift' \
    -g '*.md' \
    || true
)

if [[ -n "$legacy_runtime_core_references" ]]; then
  record_failure "Legacy MHAppRuntimeCore references must be removed:
$legacy_runtime_core_references"
fi

legacy_pinning_language=$(
  rg \
    --line-number \
    'exact tag|exact revision' \
    "${documentation_files[@]}" || true
)

if [[ -n "$legacy_pinning_language" ]]; then
  record_failure "Documentation must not describe semver adoption as an exact-tag or exact-revision exception:
$legacy_pinning_language"
fi

if [[ ${#failures[@]} -ne 0 ]]; then
  echo "MHPlatform boundary check failed." >&2

  for failure in "${failures[@]}"; do
    printf -- '- %s\n' "$failure" >&2
  done

  exit 1
fi

echo "MHPlatform boundary check passed."
