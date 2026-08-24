# 000204-podman.sh — Podman container runtime + docker/compose wrappers
# Installs: podman, docker-compose, fuse-overlayfs
# Links:    ~/.config/containers/storage.conf,
#           ~/.config/containers/storage.conf.d/01-overlay.conf,
#           ~/.local/bin/docker
# Deploys: /etc/sysctl.d/00-userns.conf
# Enables:  podman.socket (system, root API), podman.socket (user, rootless API for lazydocker)
# Note:     fuse-overlayfs is extra/fuse-overlayfs 1.17-2; /dev/fuse is already accessible (mode 666).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "podman"

install_pacman podman
# fuse-overlayfs: userspace (FUSE) overlay implementation. Kernel
# overlay-over-btrfs fails rootless here (/home is btrfs without userxattr=1),
# so the overlay storage driver is routed through fuse-overlayfs via
# mount_program in storage.conf + the 01-overlay.conf drop-in. This gives
# proper layer sharing (vs vfs's full-copy layers). Needs /dev/fuse (mode 666,
# default on Arch).
install_pacman fuse-overlayfs
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

# storage.conf + 01-overlay.conf drop-in: driver=overlay routed through
# fuse-overlayfs (mount_program). The drop-in overrides the Arch package
# drop-in (/usr/share/containers/storage.conf.d/00-storage-arch.conf) that
# sets driver=overlay with NO mount_program (which would try kernel overlay
# over btrfs and fail). User .d drop-ins merge last, so this wins.
link_file "$DOTFILES_HOME/.config/containers/storage.conf" \
  "$HOME/.config/containers/storage.conf"
link_file "$DOTFILES_HOME/.config/containers/storage.conf.d/01-overlay.conf" \
  "$HOME/.config/containers/storage.conf.d/01-overlay.conf"
# Remove a drop-in from a prior version of this migration (was 01-vfs.conf).
# Idempotent: a dangling symlink is ignored by podman's merge anyway, but
# removing it keeps the .d dir clean.
[[ -L "$HOME/.config/containers/storage.conf.d/01-vfs.conf" ]] && rm -f "$HOME/.config/containers/storage.conf.d/01-vfs.conf"
# If the existing on-disk store was initialized for a DIFFERENT driver
# (vfs from a prior run of this migration, or overlay-without-mount_program),
# podman refuses to start with a "graph driver does not match" / overlay-over-
# btrfs error. A driver switch requires a fresh store. Wipe it ONLY when the
# live storage.conf driver differs from what the store DB records -- this is
# safe (rootless store has no persistent containers/images worth keeping on a
# dev machine) and idempotent (once the store matches, the guard skips).
# We detect mismatch by asking podman; if it errors on `ps`, wipe and re-init.
if command -v podman &>/dev/null; then
  if ! podman ps -a >/dev/null 2>&1; then
    info "podman store driver mismatch (or stale store) -- resetting store"
    podman system reset -f >/dev/null 2>&1 || true
    rm -rf "$HOME/.local/share/containers/storage" >/dev/null 2>&1 || true
  fi
fi
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
