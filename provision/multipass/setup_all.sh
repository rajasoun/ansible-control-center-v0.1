#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
# shellcheck source=src/lib/os.bash
source "$SCRIPT_DIR/provision/lib/os.bash"

ANSIBLE_RUNNER=provision/ansible/run.sh

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
    # Create .state File if not exists
    [  -f "provision/multipass/.state" ] || touch "provision/multipass/.state"
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

# Configure Control Center based on state file
function configure_control_center(){
    if [ $(multipass list | grep -c  "control-center" ) -eq "1" ]; then
        echo "${GREEN}control-center ${NC}"
        CONF_STATE=$(cat provision/multipass/.state | grep -c .control-center.conf=done) || echo "${RED}control-center Conf State is Empty${NC}"
        # If Not Already Configured
        if [ $CONF_STATE -eq "0" ];then
            echo "${GREEN} Configuring control-center ${NC}"
            $ANSIBLE_RUNNER "ansible-playbook playbooks/control-center/main.yml"
            $ANSIBLE_RUNNER "ansible-galaxy install -r dependencies/monitoring/requirements.yml"
            $ANSIBLE_RUNNER "ansible-galaxy install -r dependencies/user-mgmt/requirements.yml"
            echo "${GREEN}Control Center Configuration Done!${NC}"
            echo ".control-center.conf=done" >> "provision/multipass/.state"
        else
            echo "${BLUE} Skipping control-center Configuration ${NC}"
        fi
    fi
}

# Generate and Transfer monit.yml to control center
function create_transfer_monit_conf_to_control_center(){
    if [ $(multipass list | grep -c  "mmonit" ) -eq "1" ]; then
        CONF_STATE=$(cat provision/multipass/.state | grep -c .mmonit.conf=done) || echo "${RED}mmonit Conf State is Empty${NC}"
        # If Not Already Configured
        if [ $CONF_STATE -eq "0" ];then
            # Install & Configure Monit on all Nodes
            create_monit_playbook_from_template
            $ANSIBLE_RUNNER "ansible-playbook playbooks/control-center/transfer-monit-playbook.yml"
            echo "${GREEN}Monit Transfer to Control Center Done!${NC}"
            echo ".mmonit.conf=done" >> "provision/multipass/.state"
        else
            echo "${BLUE} Skipping mmonit Configuration ${NC}"
        fi
    fi
}

# Create ansible users in all Nodes
function create_user(){
    CONF_STATE=$(cat provision/multipass/.state | grep -c .users.conf=done) || echo "${RED}Users Conf State is Empty${NC}"
    if [ $CONF_STATE -eq "0" ];then
        $ANSIBLE_RUNNER "ansible-playbook playbooks/createusers.yml"
        echo ".users.conf=done" >> "provision/multipass/.state"
        echo "${GREEN}User Mgmt for All Nodes Done!${NC}"
    else
        echo "${BLUE} Skipping Users Configuration ${NC}"
    fi
}

start=$(date +%s)
provision_vms
configure_control_center
create_transfer_monit_conf_to_control_center
create_user
end=$(date +%s)
runtime=$((end-start))
echo -e "${GREEN}${BOLD}Full Setup Done In $(display_time $runtime)${NC}"
