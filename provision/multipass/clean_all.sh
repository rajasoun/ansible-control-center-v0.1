#!/usr/bin/env bash

MLIST=$(multipass ls)

case "$MLIST" in
    *No* ) 
        echo "Multipass - All Clean";;
    * ) echo "Cleaning"
        multipass ls | grep -v Name | awk '{print $1}' | xargs multipass stop 
        multipass ls | grep -v Name | awk '{print $1}' | xargs multipass delete 
    ;;
esac

multipass purge
rm -fr config/cloud-init.yaml config/createusers.yml inventory keys/id_rsa keys/id_rsa.pub
