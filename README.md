# asnible-control-center
Ansible Control Center


## Getting Started:

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