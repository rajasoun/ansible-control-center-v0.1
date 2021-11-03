#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

CPU=${CPU:-"2"}
MEMORY=${MEMORY:-"2G"}
DISK=${DISK:-"4G"}
VM_NAME=${VM_NAME:-"control-center"}
VM_HOME=${VM_HOME:-"/home/ubuntu"}

function provision_vm(){
    local CLOUD_INIT_FILE="config/cloud-init.yaml"
    if [ ! -f "$CLOUD_INIT_FILE" ]; then
        echo "Initiating Preparation..."
        ( exec "provision/prepare.sh" )
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
    cp  $ANSIBLE_INVENTORY_FILE_TEMPLATE $ANSIBLE_INVENTORY_FILE

    IP=$(multipass info "$VM_NAME" | grep IPv4 | awk '{print $2}')
    #@ToDo: Optimize Edits
    echo "$VM_NAME  ansible_ssh_host=$IP  ansible_ssh_user=ubuntu ansible_ssh_private_key_file=keys/id_rsa" >> $ANSIBLE_INVENTORY_FILE
    echo "${ANSIBLE_INVENTORY_FILE} generated for ${VM_NAME}"
}
echo "Provisioning $VM_NAME "
echo "++++++++++++++++++++++"
provision_vm
create_ansible_inventory_from_template
multipass mount ${PWD}  ${VM_NAME}:${VM_HOME}/ansible-control-center

MULTIPASS_VM_IP=$(multipass info $VM_NAME | grep 'IPv4' | awk '{print $2}')
echo "$VM_NAME with IP : $MULTIPASS_VM_IP | READY"
