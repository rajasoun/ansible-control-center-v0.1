#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
# shellcheck source=src/lib/install.bash
source "$SCRIPT_DIR/provision/lib/install.bash"

VM_NAME=${VM_NAME:-"control-center"}
ANSIBLE_HOME=${ANSIBLE_HOME:-"/home/ubuntu/ansible-control-center"}


install_ansible
install_ansible_roles
