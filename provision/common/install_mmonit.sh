#!/usr/bin/env bash

ansible-galaxy install -r dependencies/monitoring/requirements.yml

export MMONIT_LICENSE="$HOME/.ansible/roles/rajasoun.ansible_role_mmonit/files/license.yml"
ansible-vault decrypt $MMONIT_LICENSE --vault-password-file $HOME/ansible-managed/.vault_password
ansible-playbook playbooks/mmonit.yml
ansible-vault encrypt $MMONIT_LICENSE --vault-password-file $HOME/ansible-managed/.vault_password

echo "MMonit Installation Done"
