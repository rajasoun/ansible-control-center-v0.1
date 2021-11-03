#!/usr/bin/env bash 

sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y 



ansible-galaxy install -r $VM_HOME/ansible-control-center/monitoring/requirements.yml

IP=$(ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}')

case "$IP" in
    *192* ) 
        echo "Multipass VM.Skipping User Mgmt";;
    * ) echo "User Mgmt"
        ansible-galaxy install -r $VM_HOME/ansible-control-center/user-mgmt/requirements.yml
    ;;
esac

