# asnible-control-center
Ansible Control Center


## Getting Started:

```
wget 
```
wget -O- -q https://raw.githubusercontent.com/rajasoun/ansible-control-center/main/key_configuration.sh | bash

```
git clone https://github.com/rajasoun/ansible-control-center
cd ansible-control-center
./prepare.sh
```

Update Inventory with IP Address for Monitor and Agents
update createusers.yml with public ssh key

```
ansible-playbook -i inventory createusers.yml
```