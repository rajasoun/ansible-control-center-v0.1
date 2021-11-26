#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
# shellcheck source=src/lib/install.bash
source "$SCRIPT_DIR/provision/lib/install.bash"

VM_NAME=${VM_NAME:-"control-center"}
ANSIBLE_HOME=${ANSIBLE_HOME:-"/home/ubuntu/ansible-control-center"}


if [ ! -f "inventory" ]; then
    echo "Inventory File Not Availabe. Exiting..."
    exit 1
fi

run_from_docker "ansible-playbook playbooks/control_center.yml"
run_from_docker "ansible-playbook playbooks/pip-packages.yml"

run_from_docker "ansible -m ping all"
