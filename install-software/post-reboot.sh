#!/usr/bin/env bash
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/log.sh"

SEPARATOR="=============================================================="

# Post-reboot installers
POST_REBOOT_SCRIPTS=(
  "java.sh"
  "jetbrains-toolbox.sh"
  "ollama.sh"
  "global-protect.sh"
  "github-desktop.sh"
  "ssh-key.sh"
  "gpg-key.sh"
  "git-repos.sh"
  "signal-desktop.sh"
  "packages.sh"
  "nerd-fonts.sh"
  "icons.sh"
  "lazyvim.sh"
  "bun.sh"
)

log "Starting post-reboot installations"

for script in "${POST_REBOOT_SCRIPTS[@]}"; do
  echo "${SEPARATOR}"
  log "Running $script"
  "$SCRIPT_DIR/installers/$script"
  echo "${SEPARATOR}"
done

log "Post-reboot installation done."
log "You really should reboot before continuing."

"$SCRIPT_DIR/utils/reboot.sh"
