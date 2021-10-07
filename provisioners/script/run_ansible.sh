#!/bin/bash

###############################################################################
# Cleanup after puppet run
# Globals:
#   None
# Arguments:
#   $@
# Returns:
#   None
###############################################################################
cleanup() {
  if ! rm -f /opt/puppetlabs/puppet/Puppetfile; then
    abort 'Failed to clean Puppetfile'
  fi

  if ! rm -fr /opt/puppetlabs/puppet/modules/*; then
    abort 'Failed to clean modules'
  fi
}

###############################################################################
# Configure puppet with our manifests and setting for the puppet run
# Globals:
#   None
# Arguments:
#   $@
# Returns:
#   None
###############################################################################
configure_puppet() {
  echo 'Removing /opt/puppetlabs/puppet/Puppetfile.lock'
  if ! rm -f /opt/puppetlabs/puppet/Puppetfile.lock; then
    abort 'Failed to remove Puppetfile.lock'
  fi

  echo 'Copying Puppetfile to /opt/puppetlabs/puppet/'
  cp -f ../puppet/environment/all/Puppetfile /opt/puppetlabs/puppet/
  if [[ $? -ne 0 ]]; then
    abort 'Failed to copy Puppet configuration'
  fi

  if [[ -d '../puppet/modules' ]]; then
    if [[ -n "$(ls -A ../puppet/modules)" ]]; then
      echo 'Copying modules to /opt/puppetlabs/puppet/modules'
      cp -fr ../puppet/modules/* /opt/puppetlabs/puppet/modules
      if [[ $? -ne 0 ]]; then
        abort 'Failed to copy modules'
      fi
    fi
  fi
}

###############################################################################
# Install modules from the web using librarian-puppet
# Globals:
#   None
# Arguments:
#   $@
# Returns:
#   None
###############################################################################
install_modules() {
  echo 'Updating puppet modules'
  pushd /opt/puppetlabs/puppet > /dev/null 2>&1
  scl enable rh-ruby27 '/opt/rh/rh-ruby27/root/usr/local/bin/librarian-puppet install'
  if [[ $? -ne 0 ]]; then
    abort 'Failed to update puppet modules'
  fi
  popd > /dev/null 2>&1
}

###############################################################################
# Install puppet and associated tools for server provisioning
# Globals:
#   None
# Arguments:
#   $@
# Returns:
#   None
###############################################################################
install_puppet() {
  # Determine the relevant parameters in order to obtain the correct version of puppet
  RELEASE=$(rpm -E %{rhel})

  # Get the puppet repo definition
  echo "Installing https://yum.puppetlabs.com/puppet-release-el-$RELEASE.noarch.rpm"
  rpm -i --force https://yum.puppetlabs.com/puppet-release-el-$RELEASE.noarch.rpm

  # Install Puppet and Facter
  echo "Installing Puppet"
  yum -y install puppet-agent

  echo "Installing ruby"
  yum -y install centos-release-scl
  yum -y install rh-ruby27

  echo "Enabling ruby and installing librarian-puppet"
  yum -y install git
  scl enable rh-ruby27 'gem install librarian-puppet -v 3.0.1'

  . /etc/profile.d/puppet-agent.sh
}

###############################################################################
# Run puppet for ${HOSTNAME}
# Globals:
#   None
# Arguments:
#   $@
# Returns:
#   None
###############################################################################
run_puppet() {
  echo 'Executing puppet'
  pushd ../puppet/environment/all/manifests > /dev/null 2>&1
  puppet apply --detailed-exitcodes default.pp
  exitcode=$?
  if [[ $exitcode -eq 1 || $exitcode -eq 4 || $exitcode -eq 6 ]]; then
    abort 'Failed to execute puppet'
  fi
  popd > /dev/null 2>&1
}

###############################################################################
# Parse script input for validity and configure global variables for use
# throughout the script
# Globals:
#   None
# Arguments:
#   $@
# Returns:
#   None
###############################################################################
setup_vars() {
  # Process script options
  while getopts ':h' option; do
    case "${option}" in
      h) usage ;;
      :)
        echo "Option -${OPTARG} requires an argument"
        usage
        ;;
      ?)
        echo "Option -${OPTARG} is invalid"
        usage
        ;;
    esac
  done
}

###############################################################################
# Output usage information for the script to the terminal
# Globals:
#   $0
# Arguments:
#   None
# Returns:
#   None
###############################################################################
usage() {
  local script_name
  script_name="$(basename "$0")"

  echo "usage: ${script_name} options"
  echo
  echo 'Execute puppet apply'
  echo
  echo 'OPTIONS:'
  echo "  -h show help information about ${script_name}"

  exit 1
}

main() {
  pushd "${MY_PATH}" > /dev/null 2>&1

  setup_vars "$@"
  check_user
  use_system_ruby
  install_puppet
  configure_puppet
  install_modules
  run_puppet
  cleanup

  popd > /dev/null 2>&1
}

echo '**** run_puppet ****'

MY_PATH="$(dirname "$0")"
MY_PATH="$(cd "${MY_PATH}" && pwd)"
readonly MY_PATH

source "${MY_PATH}/common_properties.sh"
source "${MY_PATH}/common_functions.sh"

main "$@"

echo '**** run_puppet - done ****'

exit 0
