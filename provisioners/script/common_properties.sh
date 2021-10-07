#!/bin/bash

###############################################################################
# Common global properties used for scripts
#
# Globals:
#   GVC_GROUPS - The groups that the user belongs to
#   GVC_REQUIRED_USER - The user the scripts should be run as
#   GVC_USER   - User who invoked the script
###############################################################################
readonly GVC_REQUIRED_USER='root'

GVC_USER="$(id -un)"
readonly GVC_USER

GVC_GROUPS="$(id -Gn "${GVC_USER}")"
readonly GVC_GROUPS
