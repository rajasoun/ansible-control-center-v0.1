#!/usr/bin/env bash 

docker run --rm -it --name="openstack-client" \
    -v "${PWD}:/workspace" \
    -v "${PWD}/.ansible:$HOME/.ansible" \
    rajasoun/openstack-client:latest 
