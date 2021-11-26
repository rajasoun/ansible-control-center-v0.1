#!/usr/bin/env bash

# Returns true (0) if this is an OS X server or false (1) otherwise.
function os_is_darwin {
  [[ $(uname -s) == "Darwin" ]]
}

# Replace a line of text that matches the given regular expression in a file with the given replacement.
# Only works for single-line replacements.
function file_replace_text {
  local -r original_text_regex="$1"
  local -r replacement_text="$2"
  local -r file="$3"

  local args=()
  args+=("-i")

  if os_is_darwin; then
    # OS X requires an extra argument for the -i flag (which we set to empty string) which Linux does no:
    # https://stackoverflow.com/a/2321958/483528
    args+=("")
  fi

  args+=("s|$original_text_regex|$replacement_text|")
  args+=("$file")

  sed "${args[@]}" > /dev/null
}

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
        echo "$USER_CONFIG_FILE exists"
        echo "Reusing Existing Config Files"
        return 0
    fi
    echo "Generating Config Files..."
    cp "$USER_TEMPLATE_FILE" "$USER_CONFIG_FILE"
    cp "$CLOUD_INIT_TEMPLATE_FILE" "$CLOUD_INIT_CONFIG_FILE"

    file_replace_text "_SSH_KEY_.*$" "$(cat "$SSH_KEY_PATH"/"${SSH_KEY}".pub)" "$USER_CONFIG_FILE"
    file_replace_text "ssh-rsa.*$" "$(cat "$SSH_KEY_PATH"/"${SSH_KEY}".pub)" "$CLOUD_INIT_CONFIG_FILE"

    echo "$USER_CONFIG_FILE & $CLOUD_INIT_CONFIG_FILE Generated"
}

# Workaround for Path Limitations in Windows
function _docker() {
  export MSYS_NO_PATHCONV=1
  export MSYS2_ARG_CONV_EXCL='*'

  case "$OSTYPE" in
      *msys*|*cygwin*) os="$(uname -o)" ;;
      *) os="$(uname)";;
  esac

  if [[ "$os" == "Msys" ]] || [[ "$os" == "Cygwin" ]]; then
      # shellcheck disable=SC2230
      realdocker="$(which -a docker | grep -v "$(readlink -f "$0")" | head -1)"
      printf "%s\0" "$@" > /tmp/args.txt
      # --tty or -t requires winpty
      if grep -ZE '^--tty|^-[^-].*t|^-t.*' /tmp/args.txt; then
          #exec winpty /bin/bash -c "xargs -0a /tmp/args.txt '$realdocker'"
          winpty /bin/bash -c "xargs -0a /tmp/args.txt '$realdocker'"
          return 0
      fi
  fi
  docker "$@"
  return 0
}

function ansible_docker() {
    echo "Provisioning $VM_NAME... Docker Container"
    _docker run --rm -it  \
        --hostname control-center \
        --name control-center \
        --workdir /ansible \
        -v "${PWD}:/ansible" \
        -v "${PWD}/keys:/keys" \
        -v "${PWD}/.ansible:/root/.ansible" \
        cytopia/ansible:latest-tools
}

function run_from_docker() {
    echo "Running $1 in Ansible Container"
    _docker run --rm -it  \
        --hostname control-center \
        --name control-center \
        --workdir /ansible \
        -v "${PWD}:/ansible" \
        -v "${PWD}/keys:/keys" \
        -v "${PWD}/.ansible:/root/.ansible" \
        cytopia/ansible:latest-tools bash -c "$1"
}
