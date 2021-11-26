#!/usr/bin/env bash

ansible-vault encrypt $MMONIT_LICENSE --vault-password-file $HOME/ansible-managed/.vault_password
echo "MMonit License Encryption Done"
