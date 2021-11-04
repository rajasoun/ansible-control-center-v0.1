#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/lib/os.bash
source "$SCRIPT_DIR/lib/os.bash"

DOMAIN=${DOMAIN:-"secops-dev"}

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_KEY_PATH="keys"
SSH_KEY="id_rsa"

function check_pre_conditions(){
    if ! [ -x "$(command -v multipass)" ]; then
        echo 'Error: multipass is not installed.' >&2
        echo 'Goto https://multipass.run/'
        exit 1
    fi
    echo "Pre Condition Checks Passed"
}

function generate_ssh_key() {
    if [ -f "$SSH_KEY_PATH/${SSH_KEY}" ]; then
        echo "Reusing Existing SSH Keys"
        return 0
    fi
    echo "Generating SSH Keys..."
    echo -e 'y\n' | ssh-keygen -q -t rsa -C \
                            "$(id -un)@$DOMAIN" -N "" \
                            -f "$SSH_KEY_PATH/${SSH_KEY}" 2>&1 > /dev/null 2>&1
    # Fix Permission For Private Key
    chmod 400 "$SSH_KEY_PATH"/"${SSH_KEY}"
    echo "${SSH_KEY} & ${SSH_KEY}.pub keys generated successfully"
}

function create_config_from_template() {
    local USER_TEMPLATE_FILE="config/templates/createusers.yml"
    local USER_CONFIG_FILE="config/createusers.yml"
    local CLOUD_INIT_TEMPLATE_FILE="config/templates/cloud-init.yaml"
    local CLOUD_INIT_CONFIG_FILE="config/cloud-init.yaml"
    if [ -f "$USER_CONFIG_FILE" ]; then
        echo "Reusing Existing Config Files"
        return 0
    fi
    echo "Generating Config Files..."
    cp "$USER_TEMPLATE_FILE" "$USER_CONFIG_FILE"
    cp "$CLOUD_INIT_TEMPLATE_FILE" "$CLOUD_INIT_CONFIG_FILE"

    file_replace_text "_SSH_KEY_.*$" "$(cat "$SSH_KEY_PATH"/"${SSH_KEY}".pub)" "$USER_CONFIG_FILE"
    file_replace_text "ssh-rsa.*$" "$(cat "$SSH_KEY_PATH"/"${SSH_KEY}".pub)" "$CLOUD_INIT_CONFIG_FILE"

    echo "$USER_CONFIG_FILE & $CLOUD_INIT_CONFIG_FILE Generated for $VM_NAME"
}

check_pre_conditions
generate_ssh_key 
create_config_from_template 


