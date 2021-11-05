#!/usr/bin/env bash 

docker run --rm -it --name="openstack-client" \
    -v "${PWD}:/workspace" \
    -v "${PWD}/.ansible:/home/ci-shell/.ansible" \
    rajasoun/openstack-client:latest 
