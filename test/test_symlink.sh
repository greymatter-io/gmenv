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

declare version="1.4.1"

log 'info' '### Testing symlink functionality';

GMENV_BIN_DIR='/tmp/gmenv-test';
log 'info' "## Creating/clearing ${GMENV_BIN_DIR}"
rm -rf "${GMENV_BIN_DIR}" && mkdir "${GMENV_BIN_DIR}";
log 'info' "## Symlinking ${PWD}/bin/* into ${GMENV_BIN_DIR}";
ln -s "${PWD}"/bin/* "${GMENV_BIN_DIR}";

cleanup || log 'error' 'Cleanup failed?!';

log 'info' "## Installing ${version}"
${GMENV_BIN_DIR}/gmenv install ${version} || error_and_proceed 'Install failed';

log 'info' "## Using ${version}";
${GMENV_BIN_DIR}/gmenv use ${version} || error_and_proceed 'Use failed';

log 'info' "## Check-Version for ${version}";
check_active_version ${version} || error_and_proceed 'Version check failed';

if [ "${#errors[@]}" -gt 0 ]; then
  log 'warn' '===== The following symlink tests failed =====';
  for error in "${errors[@]}"; do
    log 'warn' "\t${error}";
  done;
  log 'error' 'Symlink test failure(s)';
  exit 1;
else
  log 'info' 'All symlink tests passed.';
fi;

exit 0;