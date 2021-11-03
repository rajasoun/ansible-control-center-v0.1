#!/usr/bin/env bash

# Displays Time in misn and seconds
function display_time {
    local T=$1
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    (( D > 0 )) && printf '%d days ' $D
    (( H > 0 )) && printf '%d hours ' $H
    (( M > 0 )) && printf '%d minutes ' $M
    (( D > 0 || H > 0 || M > 0 )) && printf 'and '
    printf '%d seconds\n' $S
}

start=$(date +%s)
export VM_NAME=control-center && provision/multipass/setup.sh
export VM_NAME=mmonit && provision/multipass/setup.sh
export VM_NAME=observability && provision/multipass/setup.sh
export VM_NAME=dashboard && provision/multipass/setup.sh
export VM_NAME=reverse-proxy && provision/multipass/setup.sh
end=$(date +%s)
runtime=$((end-start))
echo -e "Full Setup Done In $(display_time $runtime)"