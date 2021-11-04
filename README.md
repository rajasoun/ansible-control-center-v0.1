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
alias mcmd='multipass exec control-center --'
mcmd ansible-control-center/provision/install.sh
mcmd ansible -m ping all
```

3. Install MMonit. 
```
export MMONIT_LICENSE="~/.ansible/roles/rajasoun.ansible_role_mmonit/files/license.yml"
mcmd ansible-vault decrypt $MMONIT_LICENSE
mcmd ansible-playbook monitoring/mmonit.yml
```

4. Install Monit, Node Exporter in all Nodes 
```
mcmd ansible-playbook monitoring/monit.yml
```

5. Install Dcoker and Docker-Compose in observability, dashboard and reverse-proxy

```
mcmd ansible-playbook monitoring/docker.yml
```


ansible-playbook -i inventory createusers.yml