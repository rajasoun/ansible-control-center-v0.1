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
    local ANSIBLE_INVENTORY_TEMPLATE="$config/inventory"
    local ANSIBLE_INVENTORY_FILE="$config/inventory"
    cp "$ANSIBLE_INVENTORY_TEMPLATE" "$ANSIBLE_INVENTORY_FILE"

    IP=$(multipass info "$VM_NAME" | grep IPv4 | awk '{print $2}')
    #@ToDo: Optimize Edits
    file_replace_text "_sshkey_"    "/keys/${SSH_KEY}"        "$ANSIBLE_INVENTORY_FILE"
    file_replace_text "_vm_name_"   "${VM_NAME}"              "$ANSIBLE_INVENTORY_FILE"
    file_replace_text "_ip_"        "${IP}"                   "$ANSIBLE_INVENTORY_FILE"

    echo "Ansibel Inventory -> ${ANSIBLE_INVENTORY_FILE} generated for ${VM_NAME} that is Provisioned with ${IP}"
}

provision_vm
multipass mount ${PWD}  ${VM_NAME}:${VM_HOME}/ansible-control-center
multipass exec control-center -- $VM_HOME/ansible-control-center/provision/install.sh
multipass exec control-center -- ansible-galaxy install -r $VM_HOME/ansible-control-center/requirements.yml

ansible-vault decrypt \
    ~/.ansible/roles/rajasoun.ansible_role_mmonit/files/license.yml \
    --vault-password-file ./keys/.vault_pass

ansible-playbook \
    -i ~/.ansible/roles/rajasoun.ansible_role_mmonit/inventory \
    ~/.ansible/roles/rajasoun.ansible_role_mmonit/local.yml

MULTIPASS_VM_IP=$(multipass info $VM_NAME | grep 'IPv4' | awk '{print $2}')
echo "$VM_NAME with IP : $MULTIPASS_VM_IP | READY"
