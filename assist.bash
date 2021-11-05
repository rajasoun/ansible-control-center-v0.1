#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

opt="$1"
choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )
case $choice in
  multipass)
    echo "Local Setup using multipass..."
    provision/multipass/setup_all.sh
    multipass shell control-center
    ;;
  openstack)
    echo "Cloud Setup using openstack..."
    provision/openstack/run.sh
    ;;
  *)
    cat <<-EOF
Infrastrcute Provision
----------------------
  multipass     -> spin up environment locally 
  openstack     -> spin up the environment in openstack cloud
EOF
    ;;
  esac
