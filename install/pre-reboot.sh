#!/usr/bin/env bash
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/log.sh"

SEPARATOR="=============================================================="

# Pre-reboot installers
PRE_REBOOT_SCRIPTS=(
    "basic.sh"
    "cuda.sh" 
    "container-runtime.sh"
    "package-managers.sh"
)

log "Starting pre-reboot installations"

for script in "${PRE_REBOOT_SCRIPTS[@]}"; do
    echo "${SEPARATOR}"
    log "Running $script"
    "$SCRIPT_DIR/installers/$script"
    echo "${SEPARATOR}"
done

log "Pre-reboot installation done."
log "You really should reboot before continuing."

"$SCRIPT_DIR/utils/reboot.sh"
