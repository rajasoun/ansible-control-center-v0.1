#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
# shellcheck source=src/lib/os.bash
source "$SCRIPT_DIR/provision/lib/os.bash"


start=$(date +%s)
export VM_NAME=control-center && provision/multipass/setup.sh
export VM_NAME=mmonit && provision/multipass/setup.sh
export VM_NAME=observability && provision/multipass/setup.sh
export VM_NAME=reverse-proxy && provision/multipass/setup.sh

local MONIT_TEMPLATE_FILE="config/templates/monit.yml"
local MONIT_CONFIG_FILE="monitoring/monit.yml"

cp "$MONIT_TEMPLATE_FILE" "$MONIT_CONFIG_FILE"
multipass exec control-center -- sed -i 's/sda1/vda1/g' ansible-control-center/monitoring/monit.yml
IP=$(multipass info "$VM_NAME" | grep IPv4 | awk '{print $2}')
multipass exec control-center -- sed -i 's/_MMONIT_SERVER_IP_/$IP/g' ansible-control-center/monitoring/monit.yml

end=$(date +%s)
runtime=$((end-start))
echo -e "Full Setup Done In $(display_time $runtime)"