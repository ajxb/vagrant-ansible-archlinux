#!/bin/bash

###############################################################################
# Common functions
###############################################################################

###############################################################################
# Abort the execution of the script outputting an appropriate error message
# Globals:
#   None
# Arguments:
#   error_message
# Returns:
#   None
###############################################################################
abort() {
  local error_message
  error_message="$1"

  echo "[FATAL] ${error_message}" >&2
  exit 1
}

###############################################################################
# Check the script is running under the required user group, abort if this is
# not the case
# Globals:
#   GVC_REQUIRED_GROUP
#   GVC_GROUPS
# Arguments:
#   None
# Returns:
#   None
###############################################################################
check_group() {
  if [[ ! ${GVC_GROUPS} =~ ${GVC_REQUIRED_GROUP} ]]; then
    abort "This script has to be run as ${GVC_REQUIRED_GROUP} group"
  fi
}

###############################################################################
# Check the script is running under the required user, abort if this is not the
# case
# Globals:
#   GVC_REQUIRED_USER
#   GVC_USER
# Arguments:
#   None
# Returns:
#   None
###############################################################################
check_user() {
  if [[ ${GVC_USER} != ${GVC_REQUIRED_USER} ]]; then
    abort "This script has to be run as ${GVC_REQUIRED_USER} user"
  fi
}

###############################################################################
# Check to see if rvm exists and if it does, set the system ruby to be default
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
###############################################################################
use_system_ruby() {
  if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
    source "$HOME/.rvm/scripts/rvm"
    rvm use system
  elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
    source "/usr/local/rvm/scripts/rvm"
    rvm use system
  fi
}
