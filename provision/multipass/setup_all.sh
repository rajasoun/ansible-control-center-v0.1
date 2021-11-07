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
    file_replace_text "sda1.*$" "vda1\""  "$MONIT_CONFIG_FILE"
    IP=$(multipass info "mmonit" | grep IPv4 | awk '{print $2}')
    if [ -n $IP ];then
        file_replace_text "_MMONIT_SERVER_IP_.*$" "$IP"  "$MONIT_CONFIG_FILE"
    else 
        "mmonit VM Not Available ... Exiting"
        exit 1
    fi
    
}

function provision_vms(){
    # declare -a vm_list=$(cat config/observability.vm.list)
    while read -r vm
    do
        if [[ ! -z $vm ]]
        then
            echo "export VM_NAME=${vm}  && provision/multipass/setup.sh"
        fi
    done < config/swarm.vm.list
    #export VM_NAME=control-center && provision/multipass/setup.sh
}

start=$(date +%s)
provision_vms
create_monit_playbook_from_template
end=$(date +%s)
runtime=$((end-start))
echo -e "Full Setup Done In $(display_time $runtime)"