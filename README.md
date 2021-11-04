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
```

2. Install Ansible and Ansible Role in control-center 

```
multipass shell control-center
cd ansible-control-center
provision/multipass/install_to_cc.sh
ansible -m ping all
```

3. Install MMonit. 
```
export MMONIT_LICENSE="~/.ansible/roles/rajasoun.ansible_role_mmonit/files/license.yml"
ansible-vault decrypt $MMONIT_LICENSE

ansible-playbook monitoring/mmonit.yml
```

4. Install Monit, Node Exporter in all Nodes 
```
ansible-playbook monitoring/monit.yml
```

5. Install Dcoker and Docker-Compose in observability, dashboard and reverse-proxy

```
ansible-playbook monitoring/docker.yml
```


ansible-playbook -i inventory createusers.yml