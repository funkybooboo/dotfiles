# 000204-podman.sh — Podman container runtime + docker wrappers
# Installs: podman
# Links:    ~/.config/containers/storage.conf, ~/.local/bin/docker,
#           ~/.local/bin/docker-compose
# Deploys: /etc/sysctl.d/00-userns.conf
# Enables:  podman.socket

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "podman"

install_pacman podman
# Remove the standalone Docker runtime in favor of Podman (the docker wrapper
# scripts linked below make `docker` / `docker-compose` commands forward to
# podman). Docker was installed previously but is disabled; removing it frees
# ~150 MiB and eliminates the duplicated container-runtime service.
remove_pkg docker containerd

link_file "$DOTFILES_HOME/.config/containers/storage.conf" \
  "$HOME/.config/containers/storage.conf"
link_file "$DOTFILES_HOME/.local/bin/docker"         "$HOME/.local/bin/docker"
link_file "$DOTFILES_HOME/.local/bin/docker-compose" "$HOME/.local/bin/docker-compose"

deploy_etc_file "$DOTFILES_ROOT_ETC/sysctl.d/00-userns.conf" \
  "/etc/sysctl.d/00-userns.conf" 644
if command -v sysctl &>/dev/null; then
  sudo sysctl -p /etc/sysctl.d/00-userns.conf >/dev/null 2>&1 || true
fi

enable_system_service "podman.socket"
