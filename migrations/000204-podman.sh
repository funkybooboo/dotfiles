# 000204-podman.sh — Podman container runtime + docker/compose wrappers
# Installs: podman, docker-compose
# Links:    ~/.config/containers/storage.conf,
#           ~/.config/containers/storage.conf.d/01-vfs.conf,
#           ~/.local/bin/docker
# Deploys: /etc/sysctl.d/00-userns.conf
# Enables:  podman.socket (system, root API), podman.socket (user, rootless API for lazydocker)

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "podman"

install_pacman podman
# Install the real docker-compose (Go v2 binary, standalone -- no docker
# daemon dependency). It talks to podman via DOCKER_HOST (set in config.fish
# to the rootless podman socket). `podman compose` auto-discovers it as its
# compose provider, and lazydocker's `docker compose ...` calls work through
# that chain. We do NOT ship a docker-compose wrapper script anymore -- the
# previous `exec podman "$@"` wrapper dropped the `compose` subcommand
# (`docker-compose config` -> `podman config`, wrong) and would shadow this
# real binary via ~/.local/bin being ahead of /usr/bin on PATH.
install_pacman docker-compose
# Remove the standalone Docker runtime in favor of Podman (the docker wrapper
# linked below makes `docker` forward to podman). Docker was installed
# previously but is disabled; removing it frees ~150 MiB and eliminates the
# duplicated container-runtime service.
remove_pkg docker containerd

# storage.conf sets driver=vfs, and the 01-vfs.conf drop-in overrides the
# Arch package drop-in (/usr/share/containers/storage.conf.d/00-storage-arch.conf)
# that forces driver=overlay -- rootless overlay over btrfs fails without
# userxattr or fuse-overlayfs, so vfs is the reliable rootless choice.
link_file "$DOTFILES_HOME/.config/containers/storage.conf" \
  "$HOME/.config/containers/storage.conf"
link_file "$DOTFILES_HOME/.config/containers/storage.conf.d/01-vfs.conf" \
  "$HOME/.config/containers/storage.conf.d/01-vfs.conf"
# docker wrapper: `docker ...` -> `podman ...` (drop-in for muscle memory /
# tooling that calls the docker CLI). No docker-compose wrapper -- the real
# /usr/bin/docker-compose is used directly (see install_pacman above).
link_file "$DOTFILES_HOME/.local/bin/docker"         "$HOME/.local/bin/docker"
# Remove a stale docker-compose wrapper symlink from a prior version of this
# migration. A dangling symlink is skipped by PATH resolution anyway, but
# removing it keeps ~/.local/bin clean so /usr/bin/docker-compose is found
# directly without ambiguity.
[[ -L "$HOME/.local/bin/docker-compose" ]] && rm -f "$HOME/.local/bin/docker-compose"

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
