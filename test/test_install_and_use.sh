#!/usr/bin/env bash
set -uo pipefail;

####################################
# Ensure we can execute standalone #
####################################

function early_death() {
  echo "[FATAL] ${0}: ${1}" >&2;
  exit 1;
};

if [ -z "${GMENV_ROOT:-""}" ]; then
  # http://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac
  readlink_f() {
    local target_file="${1}";
    local file_name;

    while [ "${target_file}" != "" ]; do
      cd "$(dirname ${target_file})" || early_death "Failed to 'cd \$(dirname ${target_file})' while trying to determine GMENV_ROOT";
      file_name="$(basename "${target_file}")" || early_death "Failed to 'basename \"${target_file}\"' while trying to determine GMENV_ROOT";
      target_file="$(readlink "${file_name}")";
    done;

    echo "$(pwd -P)/${file_name}";
  };

  GMENV_ROOT="$(cd "$(dirname "$(readlink_f "${0}")")/.." && pwd)";
  [ -n ${GMENV_ROOT} ] || early_death "Failed to 'cd \"\$(dirname \"\$(readlink_f \"${0}\")\")/..\" && pwd' while trying to determine GMENV_ROOT";
else
  GMENV_ROOT="${GMENV_ROOT%/}";
fi;
export GMENV_ROOT;

if [ -n "${GMENV_HELPERS:-""}" ]; then
  log 'debug' 'GMENV_HELPERS is set, not sourcing helpers again';
else
  [ "${GMENV_DEBUG:-0}" -gt 0 ] && echo "[DEBUG] Sourcing helpers from ${GMENV_ROOT}/lib/helpers.sh";
  if source "${GMENV_ROOT}/lib/helpers.sh"; then
    log 'debug' 'Helpers sourced successfully';
  else
    early_death "Failed to source helpers from ${GMENV_ROOT}/lib/helpers.sh";
  fi;
fi;

#####################
# Begin Script Body #
#####################

test_install_and_use() {
  # Takes a static version and the optional keyword to install it with
  local k="${2-""}";
  local v="${1}";
  gmenv install "${k}" || return 1;
  check_installed_version "${v}" || return 1;
  gmenv use "${k}" || return 1;
  check_active_version "${v}" || return 1;
  return 0;
};

test_install_and_use_overridden() {
  # Takes a static version and the optional keyword to install it with
  local k="${2-""}";
  local v="${1}";
  gmenv install "${k}" || return 1;
  check_installed_version "${v}" || return 1;
  gmenv use "${k}" || return 1;
  check_default_version "${v}" || return 1;
  return 0;
}

declare -a errors=();

log 'info' '### Test Suite: Install and Use'

tests__desc=(
  'latest version'
  'latest possibly-unstable version'
  'latest version matching regex'
  'specific version'
);

tests__kv=(
  "$(gmenv list-remote | grep -e "^[0-9]\+\.[0-9]\+\.[0-9]\+$" | head -n 1),latest"
  "$(gmenv list-remote | head -n 1),latest:"
  '1.3.0,latest:^1.3'
  "1.2.0,1.2.0"
)

tests_count=${#tests__desc[@]}

declare desc kv k v;

for ((test_num=0; test_num<${tests_count}; ++test_num )) ; do
  cleanup || log 'error' 'Cleanup failed?!';
  desc=${tests__desc[${test_num}]}
  kv="${tests__kv[${test_num}]}";
  v="${kv%,*}";
  k="${kv##*,}";
  log 'info' "## Param Test ${test_num}/${tests_count}: ${desc} ( ${k} / ${v} )";
  test_install_and_use "${v}" "${k}" \
    && log info "## Param Test ${test_num}/${tests_count}: ${desc} ( ${k} / ${v} ) succeeded" \
    || error_and_proceed "## Param Test ${test_num}/${tests_count}: ${desc} ( ${k} / ${v} ) failed";
  test_num+=1;
done;

for ((test_num=0; test_num<${tests_count}; ++test_num )) ; do
  cleanup || log 'error' 'Cleanup failed?!';
  desc=${tests__desc[${test_num}]}
  kv="${tests__kv[${test_num}]}";
  v="${kv%,*}";
  k="${kv##*,}";
  log 'info' "## ./.greymatter-version Test ${test_num}/${tests_count}: ${desc} ( ${k} / ${v} )";
  log 'info' "Writing ${k} to ./.greymatter-version";
  echo "${k}" > ./.greymatter-version;
  test_install_and_use "${v}" \
    && log info "## ./.greymatter-version Test ${test_num}/${tests_count}: ${desc} ( ${k} / ${v} ) succeeded" \
    || error_and_proceed "## ./.greymatter-version Test ${test_num}/${tests_count}: ${desc} ( ${k} / ${v} ) failed";
  test_num+=1;
done;

cleanup || log 'error' 'Cleanup failed?!';
log 'info' '## ${HOME}/.greymatter-version Test Preparation';

# 0.12.22 reports itself as 0.12.21 and breaks testing
declare v1="$(gmenv list-remote | grep -e "^[0-9]\+\.[0-9]\+\.[0-9]\+$" | grep -v '0.12.22' | head -n 2 | tail -n 1)";
declare v2="$(gmenv list-remote | grep -e "^[0-9]\+\.[0-9]\+\.[0-9]\+$" | grep -v '0.12.22' | head -n 1)";

if [ -f "${HOME}/.greymatter-version" ]; then
  log 'info' "Backing up ${HOME}/.greymatter-version to ${HOME}/.greymatter-version.bup";
  mv "${HOME}/.greymatter-version" "${HOME}/.greymatter-version.bup";
fi;
log 'info' "Writing ${v1} to ${HOME}/.greymatter-version";
echo "${v1}" > "${HOME}/.greymatter-version";

log 'info' "## \${HOME}/.greymatter-version Test 1/3: Install and Use ( ${v1} )";
test_install_and_use "${v1}" \
  && log info "## \${HOME}/.greymatter-version Test 1/1: ( ${v1} ) succeeded" \
  || error_and_proceed "## \${HOME}/.greymatter-version Test 1/1: ( ${v1} ) failed";

log 'info' "## \${HOME}/.greymatter-version Test 2/3: Override Install with Parameter ( ${v2} )";
test_install_and_use_overridden "${v2}" "${v2}" \
  && log info "## \${HOME}/.greymatter-version Test 2/3: ( ${v2} ) succeeded" \
  || error_and_proceed "## \${HOME}/.greymatter-version Test 2/3: ( ${v2} ) failed";

log 'info' "## \${HOME}/.greymatter-version Test 3/3: Override Use with Parameter ( ${v2} )";
(
  gmenv use "${v2}" || exit 1;
  check_default_version "${v2}" || exit 1;
) && log info "## \${HOME}/.greymatter-version Test 3/3: ( ${v2} ) succeeded" \
  || error_and_proceed "## \${HOME}/.greymatter-version Test 3/3: ( ${v2} ) failed";

log 'info' '## \${HOME}/.greymatter-version Test Cleanup';
log 'info' "Deleting ${HOME}/.greymatter-version";
rm "${HOME}/.greymatter-version";
if [ -f "${HOME}/.greymatter-version.bup" ]; then
  log 'info' "Restoring backup from ${HOME}/.greymatter-version.bup to ${HOME}/.greymatter-version";
  mv "${HOME}/.greymatter-version.bup" "${HOME}/.greymatter-version";
fi;

log 'info' 'Install invalid specific version';
cleanup || log 'error' 'Cleanup failed?!';


neg_tests__desc=(
  'specific version'
  'latest:word'
);
neg_tests__kv=(
  '9.9.9'
  "latest:word"
);
neg_tests_count=${#neg_tests__desc[@]}

for ((test_num=0; test_num<${neg_tests_count}; ++test_num )) ; do
  cleanup || log 'error' 'Cleanup failed?!';
  desc=${neg_tests__desc[${test_num}]}
  k="${neg_tests__kv[${test_num}]}";
  expected_error_message="No versions matching '${k}' found in remote";
  log 'info' "##  Invalid Version Test ${test_num}/${neg_tests_count}: ${desc} ( ${k} )";
  [ -z "$(gmenv install "${k}" 2>&1 | grep "${expected_error_message}")" ] \
    && error_and_proceed "Installing invalid version ${k}";
done;

if [ "${#errors[@]}" -gt 0 ]; then
  log 'warn' '===== The following install_and_use tests failed =====';
  for error in "${errors[@]}"; do
    log 'warn' "\t${error}";
  done
  log 'error' 'Test failure(s): install_and_use';
else
  log 'info' 'All install_and_use tests passed';
fi;

cleanup || log 'error' 'Cleanup failed?!';

exit 0;