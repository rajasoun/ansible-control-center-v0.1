# asnible-control-center
Ansible Control Center

## Getting Started Local Testing using Multipass

1. Create Five VMs 
    * control-center
    * mmonit
    * observability
    * dashboard
    * reverse-proxy

```
git clone https://github.com/rajasoun/ansible-control-center
cd ansible-control-center
provision/multipass/full.sh
provision/install.sh
ansible -m ping all
```

2. Install MMonit. 
```
ansible-vault decrypt ~/.ansible/roles/rajasoun.ansible_role_mmonit/files/license.yml
ansible-playbook monitoring/mmonit.yml
```

3. Install Monit, Node Exporter in all Nodes 
```
ansible-playbook monitoring/monit.yml
```

4. Install Dcoker and Docker-Compose in observability, dashboard and reverse-proxy

```
ansible-playbook monitoring/docker.yml
```


ansible-playbook -i inventory createusers.yml