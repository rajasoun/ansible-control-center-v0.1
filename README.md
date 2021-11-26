# asnible-control-center

Ansible Control Center in provisioning infrastructure vms
locally, or in Openstack

## Pre Requisites

-   [multipass](https://multipass.run/) for local setup
-   [docker](https://www.docker.com/) for cloud setup

## Getting Started

1. Create Infrastructure VMs locally or in cloud
    - control-center
    - mmonit
    - observability
    - reverse-proxy

```
./assist.bash {multipass | openstack}
```

Multipass Specific (Local)

```
./assist.bash multipass
multipass shell control-center
```

Open Stack (On Prem Cloud)

```
provision/openstack/shell/run.sh
source config/{stage|production}/<openrc.sh>
cd /workspace
```

2. Install MMonit. Add `.vault_password` to `keys` directory with the vault password

3. Configure MMonit, Node Exporter in all Nodes

```
provision/common/install_mmonit.sh
```

5. Install Dcoker and Docker-Compose in observability, dashboard and reverse-proxy

```
ansible-playbook playbooks/observability.yml
ansible-playbook playbooks/reverse-proxy.yml
```

> As and when new nodes are being added, do the following

1. Add the node to the `inventory` file
2. Execute `ansible-playbook playbooks/control_center.yml` to update /etc/hosts and SSH Config to control center
