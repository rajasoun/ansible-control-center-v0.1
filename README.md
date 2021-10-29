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

## Getting Started


```

git clone https://github.com/rajasoun/ansible-control-center
cd ansible-control-center
./prepare.sh
```

Update Inventory with IP Address for Monitor and Agents
update createusers.yml with public ssh key

```
ansible -i inventory -m ping all
ansible-playbook -i inventory createusers.yml
```

