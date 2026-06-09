# 29-systemd-services.sh — enable user services and set git hooks

section "Systemd User Services"

if [[ $DRY_RUN -eq 0 ]]; then
  systemctl --user daemon-reload
fi

# Set git hooks path so pre-commit secret scanning is active
GITHOOKS_SRC="$REPO_ROOT/.githooks"
if [[ -d "$GITHOOKS_SRC" ]]; then
  if [[ $DRY_RUN -eq 1 ]]; then
    info "would set git core.hooksPath to .githooks"
  else
    git config core.hooksPath .githooks
    ok "git hooks path set to .githooks (pre-commit secret scanning active)"
  fi
fi

enable_user_service "ssh-agent.service"
enable_user_service "power-profile-switch.service"
enable_user_service "battery-notify.timer"

enable_user_service "openviking.service"
enable_user_service "hypr-wallpaper.service"