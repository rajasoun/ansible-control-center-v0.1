#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
# shellcheck source=src/lib/install.bash
source "$SCRIPT_DIR/provision/lib/install.bash"

VM_NAME=${VM_NAME:-"control-center"}
VM_HOME=${VM_HOME:-"/home/ubuntu"}

install_ansible
install_ansible_roles

sudo snap install semaphore
sudo snap stop semaphore
sudo semaphore user add --admin \
                --login admin \
                --name=admin \
                --email=devsecops@gmail.com \
                --password=admin
sudo snap start semaphore