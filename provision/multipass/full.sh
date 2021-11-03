#!/usr/bin/env bash

export VM_NAME=control-center && provision/multipass/setup.sh
export VM_NAME=mmonit && provision/multipass/setup.sh
export VM_NAME=observability && provision/multipass/setup.sh
export VM_NAME=dashboard && provision/multipass/setup.sh
export VM_NAME=reverse-proxy && provision/multipass/setup.sh