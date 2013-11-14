#!/bin/bash

# Checks and installs Chef (if needed) on a system, then runs
# chef-solo.
#
# This scripts should be run as root on the server.

###
usage () { echo "$0 -r [role file]"; }
###

ROLE_FILE=""

while getopts r:h option
do
  case "${option}"
  in
    r) ROLE_FILE=${OPTARG};;
    h) usage; exit;;
  esac
done

if [ -z "$ROLE_FILE" ]; then
  usage
  exit 1
fi


if command -v chef-solo &> /dev/null
then
  chef_binary=`command -v chef-solo`
elif command -v "/opt/chef/bin/chef-solo" &> /dev/null
then
  chef_binary="/opt/chef/bin/chef-solo"
else
  chef_binary="/usr/local/bin/chef-solo"
fi

if ! test -f "$chef_binary"; then
  curl -L https://www.opscode.com/chef/install.sh | sudo bash
  chef_binary="/opt/chef/bin/chef-solo"
fi

# Get the bash script's directory
pushd `dirname "${BASH_SOURCE[0]}"` > /dev/null
current_dir=`pwd`
popd > /dev/null

$chef_binary -l debug -c "$current_dir/solo.rb" -j "$current_dir/$ROLE_FILE"
