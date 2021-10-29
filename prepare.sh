#!/usr/env/bin bash 

sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

ansible-galaxy install git+https://wwwin-github.cisco.com/sto-ccc/ansible-users.git
cd ~/.ansible/roles/ansible-users
ansible-galaxy install -r requirements.yml

