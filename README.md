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
./assist.bash {multipass | openstack}
```

Multipass Specific (Local)

```
./assist.bash multipass 
multipass shell control-center
cd ansible-control-center
```

2. Install Ansible and Ansible Role in control-center 

```
provision/common/install_to_cc.sh
```

3. Install MMonit. 
```
provision/common/install_mmonit.sh
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
