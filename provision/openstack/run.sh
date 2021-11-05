#!/usr/bin/env bash 

docker run --rm -it --name="openstack-client" \
    -v "${PWD}:/workspace" \
    rajasoun/openstack-client:latest 
