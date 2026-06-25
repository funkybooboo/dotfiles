# 000403-ssh.sh — OpenSSH client + config + ssh-agent user service
# Installs: openssh
# Links:    ~/.ssh/config, ~/.config/systemd/user/ssh-agent.service
# Enables:  ssh-agent.service
# Note: chmod 700 ~/.ssh is applied after the config is linked.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "ssh"

install_pacman openssh

mkdir -p "$HOME/.ssh"
link_file "$DOTFILES_HOME/.ssh/config" "$HOME/.ssh/config"
chmod 700 "$HOME/.ssh"
ok "~/.ssh → 700"

link_file "$DOTFILES_HOME/.config/systemd/user/ssh-agent.service" \
  "$HOME/.config/systemd/user/ssh-agent.service"
enable_user_service "ssh-agent.service"
