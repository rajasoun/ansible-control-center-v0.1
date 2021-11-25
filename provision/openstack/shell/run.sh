#!/usr/bin/env bash

BASE_DIR="$(git rev-parse --show-toplevel)"

docker run --rm -it --name="openstack-client" \
    -v "${BASE_DIR}:/workspace" \
    -v "${BASE_DIR}/provision/openstack/.ansible:/home/ci-shell/.ansible" \
    rajasoun/openstack-client:latest
