#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
# shellcheck source=src/lib/os.bash
source "$SCRIPT_DIR/provision/lib/os.bash"

DOMAIN=${DOMAIN:-"secops-dev"}
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_KEY_PATH="keys"
SSH_KEY="id_rsa"

CPU=${CPU:-"2"}
MEMORY=${MEMORY:-"2G"}
DISK=${DISK:-"4G"}
VM_NAME=${VM_NAME:-"control-center"}
VM_HOME=${VM_HOME:-"/home/ubuntu"}

function provision_vm(){
    local CLOUD_INIT_FILE="config/cloud-init.yaml"
    if [ ! -f "$CLOUD_INIT_FILE" ]; then
        echo "Initiating Preparation..."
        check_pre_conditions
        generate_ssh_key 
        create_config_from_template 
    fi
    echo "Provisioning $VM_NAME..."
    multipass launch --name $VM_NAME \
                        --cpus $CPU --mem $MEMORY --disk $DISK \
                        --cloud-init $CLOUD_INIT_FILE
    echo "Provisioning for $VM_NAME Done !!!"
}

function create_ansible_inventory_from_template(){
    local SSH_KEY="id_rsa"
    local ANSIBLE_INVENTORY_FILE_TEMPLATE="config/templates/inventory.hosts"
    local ANSIBLE_INVENTORY_FILE="inventory"
    if [ ! -f $ANSIBLE_INVENTORY_FILE ];then 
        cp  $ANSIBLE_INVENTORY_FILE_TEMPLATE $ANSIBLE_INVENTORY_FILE
    fi 

    IP=$(multipass info "$VM_NAME" | grep IPv4 | awk '{print $2}')
    #@ToDo: Optimize Edits

    echo "$VM_NAME  ansible_ssh_host=$IP  ansible_ssh_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_rsa" >> $ANSIBLE_INVENTORY_FILE
    echo "${ANSIBLE_INVENTORY_FILE} generated for ${VM_NAME}"
}

function create_ssh_config_from_template() {
    local SSH_TEMPLATE_FILE="config/templates/ssh/config"
    local SSH_CONFIG_FILE="playbooks/config/ssh-config"

    if [ -f "$SSH_CONFIG_FILE" ]; then
        echo "Reusing Existing SSH Config Files"
        return 0
    fi
    echo "Generating Config Files..."
    cp "$SSH_TEMPLATE_FILE" "$SSH_CONFIG_FILE"
    IP=$(multipass info "$VM_NAME" | grep IPv4 | awk '{print $2}')
    OCTET=$(echo $IP | awk -F '.' '{ print $1}')
    file_replace_text "_GATEWAY_IP_.*$" "$OCTET" "$SSH_CONFIG_FILE.*"

    echo "$SSH_CONFIG_FILE Generated for $VM_NAME"
}

echo "Provisioning $VM_NAME "
echo "++++++++++++++++++++++"
provision_vm
create_ansible_inventory_from_template
create_ssh_config_from_template
#multipass mount ${PWD}  ${VM_NAME}:${VM_HOME}/ansible-control-center

MULTIPASS_VM_IP=$(multipass info $VM_NAME | grep 'IPv4' | awk '{print $2}')
echo "$VM_NAME with IP : $MULTIPASS_VM_IP | READY"
