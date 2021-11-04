#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/lib/os.bash
source "$SCRIPT_DIR/lib/os.bash"


start=$(date +%s)
export VM_NAME=control-center && provision/multipass/setup.sh
export VM_NAME=mmonit && provision/multipass/setup.sh
export VM_NAME=observability && provision/multipass/setup.sh
export VM_NAME=dashboard && provision/multipass/setup.sh
export VM_NAME=reverse-proxy && provision/multipass/setup.sh
end=$(date +%s)
runtime=$((end-start))
echo -e "Full Setup Done In $(display_time $runtime)"