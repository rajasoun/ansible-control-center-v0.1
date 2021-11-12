#!/usr/bin/env bash

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
source "$SCRIPT_DIR/provision/openstack/env.vars"

while read -r vm
do
    if [[ ! -z $vm ]]
    then
        OLIST=$(openstack server list | grep $vm | wc -l )
        case "$OLIST" in
            "0" ) 
                echo "Open Stack - All Clean";;
            * ) 
                echo "Cleaning"
                openstack server delete $vm
            ;;
        esac
    fi
done < "$SCRIPT_DIR/provision/openstack/openstack_vm.list"

rm -fr config/cloud-init.yaml \
       inventory \
       keys/id_rsa \
       keys/id_rsa.pub \
       playbooks/monit.yml \
       playbooks/config/ssh-config \
       playbooks/createusers.yml

