#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
# shellcheck source=src/lib/os.bash
source "$SCRIPT_DIR/provision/lib/os.bash"

function create_monit_playbook_from_template(){
    local MONIT_TEMPLATE_FILE="config/templates/monit.yml"
    local MONIT_CONFIG_FILE="playbooks/monit.yml"

    cp "$MONIT_TEMPLATE_FILE" "$MONIT_CONFIG_FILE"
    file_replace_text "sda1.*$" "vda1\'"  "$MONIT_CONFIG_FILE"
    IP=$(multipass info "mmonit" | grep IPv4 | awk '{print $2}')
    if [ -n $IP ];then
        file_replace_text "_MMONIT_SERVER_IP_.*$" "$IP"  "$MONIT_CONFIG_FILE"
    else
        echo "${ORANGE}mmonit VM Not Available ... Exiting${NC}"
        exit 1
    fi
    echo "${GREEN}$MONIT_CONFIG_FILE Generated for $VM_NAME${NC}"
}

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
if [ $(multipass list | grep -c  "control-center" ) -eq "1" ]; then
    $ANSIBLE_RUNNER "ansible-playbook playbooks/control-center/main.yml"
    $ANSIBLE_RUNNER "ansible-galaxy install -r dependencies/monitoring/requirements.yml"
    $ANSIBLE_RUNNER "ansible-galaxy install -r dependencies/user-mgmt/requirements.yml"
    echo "${GREEN}Control Center Configuration Done!${NC}"
fi

if [ $(multipass list | grep -c  "mmonit" ) -eq "1" ]; then
    # Install & Configure Monit on all Nodes
    create_monit_playbook_from_template
    $ANSIBLE_RUNNER "ansible-playbook playbooks/control-center/transfer-monit-playbook.yml"
    echo "${GREEN}Monit Transfer to Control Center Done!${NC}"

    # Configure all VMs with monit
    $ANSIBLE_RUNNER "ansible-playbook playbooks/monit.yml"
    echo "${GREEN}Monit for All Nodes Done!${NC}"
fi

# Create ansible users in all Nodes
$ANSIBLE_RUNNER "ansible-playbook playbooks/createusers.yml"
echo "${GREEN}User Mgmt for All Nodes Done!${NC}"

end=$(date +%s)
runtime=$((end-start))
echo -e "${GREEN}${BOLD}Full Setup Done In $(display_time $runtime)${NC}"
