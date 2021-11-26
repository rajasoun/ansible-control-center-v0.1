#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
# shellcheck source=src/lib/os.bash
source "$SCRIPT_DIR/provision/lib/os.bash"

function provision_vms(){
    # declare -a vm_list=$(cat config/observability.vm.list)
    while read -r vm
    do
        if [[ ! -z $vm ]]
        then
            echo "${BOLD}$vm${NC}"
            export VM_NAME=${vm}  && provision/multipass/setup.sh
        fi
    done <  "$SCRIPT_DIR/provision/multipass/multipass_vm.list"
    #export VM_NAME=control-center && provision/multipass/setup.sh
}

start=$(date +%s)
provision_vms

ANSIBLE_RUNNER=provision/ansible/run.sh
$ANSIBLE_RUNNER "ansible-playbook playbooks/createusers.yml"
echo "${GREEN}User Mgmt for All Nodes Done!${NC}"

end=$(date +%s)
runtime=$((end-start))
echo -e "${GREEN}${BOLD}Full Setup Done In $(display_time $runtime)${NC}"
