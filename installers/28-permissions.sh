# 28-permissions.sh — secure SSH and GPG directories

section "Permissions"

if [[ -d "$HOME/.ssh" ]]; then
  run_cmd chmod 700 "$HOME/.ssh"
  [[ $DRY_RUN -eq 0 ]] && ok "~/.ssh → 700"
fi
if [[ -d "$HOME/.gnupg" ]]; then
  run_cmd chmod 700 "$HOME/.gnupg"
  [[ $DRY_RUN -eq 0 ]] && ok "~/.gnupg → 700"
fi