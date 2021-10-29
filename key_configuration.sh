#!/usr/bin/env bash 

echo "Grab Public Key (id_ed25519.pub) and Private Key (id_ed25519)"
echo "Store The Keys in ${HOME}/.ssh"

echo "Check SSH Agent is Running : $(ssh-agent -s) "
echo "Add Key to the SSH Agent   : ssh-add ~/.ssh/id_ed25519 "
