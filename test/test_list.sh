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

declare -a errors=();

log 'info' '### List local versions';
cleanup || log 'error' "Cleanup failed?!";

for v in 1.1.0 1.2.1 1.4.1 1.4.2; do
  log 'info' "## Installing version ${v} to construct list";
  gmenv install "${v}" \
    && log 'debug' "Install of version ${v} succeeded" \
    || error_and_proceed "Install of version ${v} failed";
done;

gmenv use 1.4.2

log 'info' '## Comparing "gmenv list" to expectations';
result="$(gmenv list)";
expected="$(cat << EOS
* 1.4.2 (set by $(gmenv version-file))
  1.4.1
  1.2.1
  1.1.0
EOS
)";

if [ "${expected}" != "${result}" ]; then
  error_and_proceed "List mismatch.\nExpected:\n${expected}\nGot:\n${result}";
fi;

if [ "${#errors[@]}" -gt 0 ]; then
  log 'warn' "===== The following list tests failed =====";
  for error in "${errors[@]}"; do
    log 'warn' "\t${error}";
  done;
  log 'error' 'List test failure(s)';
else
  log 'info' 'All list tests passed.';
fi;

cleanup || log 'error' 'Cleanup failed?!';

exit 0;