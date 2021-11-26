#!/usr/bin/env bash

# Install & Configure MMonit
ansible-playbook  playbooks/mmonit.yml
echo "${GREEN}MMonit Installation & Configuration Done!${NC}"

# Install & Configure Monit
ansible-playbook playbooks/monit.yml
echo "${GREEN}Monit Installation & Configuration Done!${NC}"
