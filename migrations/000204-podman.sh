# 000204-podman.sh — Podman container runtime + docker wrappers
# Installs: podman
# Links:    ~/.config/containers/storage.conf,
#           ~/.config/containers/storage.conf.d/01-vfs.conf,
#           ~/.local/bin/docker, ~/.local/bin/docker-compose
# Deploys: /etc/sysctl.d/00-userns.conf
# Enables:  podman.socket (system, root API), podman.socket (user, rootless API for lazydocker)

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "podman"

install_pacman podman
# Remove the standalone Docker runtime in favor of Podman (the docker wrapper
# scripts linked below make `docker` / `docker-compose` commands forward to
# podman). Docker was installed previously but is disabled; removing it frees
# ~150 MiB and eliminates the duplicated container-runtime service.
remove_pkg docker containerd

# storage.conf sets driver=vfs, and the 01-vfs.conf drop-in overrides the
# Arch package drop-in (/usr/share/containers/storage.conf.d/00-storage-arch.conf)
# that forces driver=overlay -- rootless overlay over btrfs fails without
# userxattr or fuse-overlayfs, so vfs is the reliable rootless choice.
link_file "$DOTFILES_HOME/.config/containers/storage.conf" \
  "$HOME/.config/containers/storage.conf"
link_file "$DOTFILES_HOME/.config/containers/storage.conf.d/01-vfs.conf" \
  "$HOME/.config/containers/storage.conf.d/01-vfs.conf"
link_file "$DOTFILES_HOME/.local/bin/docker"         "$HOME/.local/bin/docker"
link_file "$DOTFILES_HOME/.local/bin/docker-compose" "$HOME/.local/bin/docker-compose"

deploy_etc_file "$DOTFILES_ROOT_ETC/sysctl.d/00-userns.conf" \
  "/etc/sysctl.d/00-userns.conf" 644
if command -v sysctl &>/dev/null; then
  sudo sysctl -p /etc/sysctl.d/00-userns.conf >/dev/null 2>&1 || true
fi

enable_system_service "podman.socket"
# Rootless API socket at $XDG_RUNTIME_DIR/podman/podman.sock -- lets
# Docker-API clients (lazydocker, the docker->podman wrapper) talk to
# rootless podman via DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock
enable_user_service "podman.socket"
