# asnible-control-center

Ansible Control Center in provisioning infrastructure vms 
locally, or in Openstack  

## Pre Requisites

* [multipass](https://multipass.run/) for local setup
* [docker](https://www.docker.com/) for cloud setup 

## Getting Started 

1. Create Infrastructure VMs locally or in cloud 
    * control-center
    * mmonit
    * observability
    * reverse-proxy

```
./assist.bash 
```

2. Install Ansible and Ansible Role in control-center 

```
git clone https://github.com/rajasoun/ansible-control-center
cd ansible-control-center
provision/common/install_to_cc.sh
```

3. Install MMonit. 
```
export MMONIT_LICENSE="/home/ubuntu/.ansible/roles/rajasoun.ansible_role_mmonit/files/license.yml"
ansible-vault decrypt $MMONIT_LICENSE

ansible-playbook playbooks/mmonit.yml
```

4. Install Monit, Node Exporter in all Nodes 
```
ansible-playbook playbooks/monit.yml
```

5. Install Dcoker and Docker-Compose in observability, dashboard and reverse-proxy

```
ansible-playbook playbooks/observability.yml
ansible-playbook playbooks/reverse-proxy.yml
```
