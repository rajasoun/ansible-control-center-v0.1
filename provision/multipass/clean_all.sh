#!/usr/bin/env bash

MLIST=$(multipass ls)

case "$MLIST" in
    *No* )
        echo "Multipass - All Clean";;
    * ) echo "Cleaning"

        multipass ls  | grep Running | awk '{print $1}' | xargs multipass stop
        multipass ls  | grep Stopped | awk '{print $1}' | xargs multipass delete
    ;;
esac

multipass purge
rm -fr config/cloud-init.yaml \
       config/createusers.yml \
       config/ssh-config \
       inventory \
       keys/id_rsa \
       keys/id_rsa.pub \
       playbooks/monit.yml \
       playbooks/createusers.yml \
       playbooks/config/ssh-config \
       provision/multipass/.state
