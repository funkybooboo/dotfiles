# 000589-ansible.sh -- ansible (the homelab IaC engine, pacman)
# Installs: ansible
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. The homelab v2 arc
#       (OPS-7 IaC skeleton) drives the PVE cluster declaratively
#       from debbie; ansible is the engine, so it is a tracked
#       runtime here. The collections ride with 000590
#       (homelab-maintenance: engine here, collections there).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "ansible"

install_pacman ansible

ok "ansible"
