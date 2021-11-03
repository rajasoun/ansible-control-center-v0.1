# asnible-control-center
Ansible Control Center


## Pre Requisite 

* Ansible Control Center 
* Monitor VM
* Private, Public Key for Ansible User

```
Grab Public Key (id_ed25519.pub) and Private Key (id_ed25519)
Store The Keys in ${HOME}/.ssh"

Check SSH Agent is Running : $(ssh-agent -s) "
Add Key to the SSH Agent   : ssh-add ~/.ssh/id_ed25519 "
```

## Getting Started (Testing)


```
git clone https://github.com/rajasoun/ansible-control-center
cd ansible-control-center
provision/multipass/setup.sh
provision/install.sh
```

Update Inventory with IP Address for Monitor and Agents

```
ansible -i inventory -m ping all
ansible-playbook -i inventory createusers.yml
```

Install MMonit. Place SSL certs in monitoring/certs

```
ansible-vault decrypt ~/.ansible/roles/rajasoun.ansible_role_mmonit/files/license.yml
ansible-playbook -i inventory monitoring/mmonit.yml
```

