#!/usr/bin/env bash

export MMONIT_LICENSE="$HOME/.ansible/roles/rajasoun.ansible_role_mmonit/files/license.yml"
ansible-vault decrypt $MMONIT_LICENSE --vault-password-file keys/.vault_password
ansible-playbook playbooks/mmonit.yml
ansible-vault encrypt $MMONIT_LICENSE --vault-password-file keys/.vault_password

echo "MMonit Installation Done"
