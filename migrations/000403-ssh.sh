# 000403-ssh.sh — OpenSSH client + config + ssh-agent user service
# Installs: openssh
# Links:    ~/.ssh/config, ~/.ssh/id_ed25519.pub, ~/.config/systemd/user/ssh-agent.service
# Enables:  ssh-agent.service
# Note: chmod 700 ~/.ssh is applied after the config is linked.
#       The public key ~/.ssh/id_ed25519.pub is a tracked convenience (public,
#       non-secret) for the Ed25519 keypair whose private half lives in
#       Proton Pass (auto-loaded into the agent by secretmgr ssh-add at login,
#       load_on_login=true in ~/.config/secretmgr/config.toml). It is the same
#       keypair across all machines, so committing + linking the .pub is the
#       simplest reproducible path; the private key never enters git.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "ssh"

install_pacman openssh

mkdir -p "$HOME/.ssh"
link_file "$DOTFILES_HOME/.ssh/config" "$HOME/.ssh/config"
link_file "$DOTFILES_HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/id_ed25519.pub"
chmod 700 "$HOME/.ssh"
ok "~/.ssh → 700"

link_file "$DOTFILES_HOME/.config/systemd/user/ssh-agent.service" \
  "$HOME/.config/systemd/user/ssh-agent.service"
enable_user_service "ssh-agent.service"
