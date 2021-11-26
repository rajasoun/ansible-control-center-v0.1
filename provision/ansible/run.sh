#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
# shellcheck source=src/lib/os.bash
source "$SCRIPT_DIR/provision/lib/os.bash"

VM_NAME=${VM_NAME:-"control-center"}
ANSIBLE_HOME=${ANSIBLE_HOME:-"$HOME/ansible-control-center"}


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

function run_from_docker() {
    echo "Running $1 in Ansible Container"
    _docker run --rm -it \
        --hostname control-center \
        --name control-center \
        --workdir /ansible \
        -v "${PWD}:/ansible" \
        -v "${PWD}/keys:/home/ubuntu/.ssh" \
        -v "${PWD}/.ansible:/root/.ansible" \
        cytopia/ansible:latest-tools bash -c "$1"
}

if [ ! -f "inventory" ]; then
    echo "Inventory File Not Availabe. Exiting..."
    exit 1
fi

run_from_docker "$1"
