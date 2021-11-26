#!/usr/bin/env bash

ansible-galaxy install -r dependencies/monitoring/requirements.yml

export MMONIT_LICENSE="$HOME/.ansible/roles/rajasoun.ansible_role_mmonit/files/license.yml"
ansible-vault decrypt $MMONIT_LICENSE --vault-password-file $HOME/ansible-managed/.vault_password
echo "MMonit License Decrypt Done"

# Install & Configure MMonit
ansible-playbook  playbooks/mmonit.yml
echo "${GREEN}MMonit Installation & Configuration Done!${NC}"

# Install & Configure Monit
ansible-playbook playbooks/monit.yml
echo "${GREEN}Monit Installation & Configuration Done!${NC}"

ansible-vault encrypt $MMONIT_LICENSE --vault-password-file $HOME/ansible-managed/.vault_password
echo "MMonit License Encryption Done"
