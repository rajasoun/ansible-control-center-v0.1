#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
# shellcheck source=src/lib/os.bash
source "$SCRIPT_DIR/provision/lib/os.bash"

VM_NAME=${VM_NAME:-"control-center"}
ANSIBLE_HOME=${ANSIBLE_HOME:-"$HOME/ansible-control-center"}

function install_upgrade_ansible(){
    if grep -q docker /proc/1/cgroup; then
        echo "Inside Docker Ansible Container. Skipping ansible upgrade"
        export ANSIBLE_HOME="/ansible"
    else
        echo "On VM. Upgrading Ansible"
            sudo apt update
            sudo apt install software-properties-common
            sudo add-apt-repository --yes --update ppa:ansible/ansible
            sudo apt install ansible -y
    fi
    IP=$(ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}')
    echo "$VM_NAME | IP -> $IP "
}

install_upgrade_ansible
