# 00-env.fish -- environment variables (exported, universal-gx)
#
# Sourced first so every later conf.d file and tool init sees these.

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx MANPAGER less
set -gx SUDO_EDITOR nvim
set -gx BAT_THEME "Catppuccin Mocha"
set -gx MANROFFOPT -c
set -gx LESSHISTFILE -
set -gx PYTHONSTARTUP $HOME/.config/python/pythonrc

# SSH agent (user systemd unit ssh-agent.service owns the socket)
set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

# Libvirt: use the system connection by default for virt-manager / virsh.
set -gx LIBVIRT_DEFAULT_URI "qemu:///system"

# Podman: expose the rootless API socket so Docker-API clients (lazydocker,
# docker CLI via the ~/.local/bin/docker->podman wrapper) hit podman.
# Requires: systemctl --user enable --now podman.socket
set -gx DOCKER_HOST unix://$XDG_RUNTIME_DIR/podman/podman.sock

# pi coding agent: skip startup network ops by default. pi awaits a
# best-effort remote model-catalog refresh (https://pi.dev/api/models/...)
# on every startup for each provider with a stored credential; that
# endpoint currently hangs server-side and pi only aborts it after 15s,
# making every launch freeze ~15s (e.g. `pi --help` takes 15.7s vs 0.9s).
# PI_OFFLINE only gates catalog/version-check/telemetry fetches, NOT model
# inference, so the agent is fully functional offline. Force a one-off
# refresh (e.g. after pi.dev is fixed) with:
#   env -u PI_OFFLINE pi --list-models
set -gx PI_OFFLINE 1
