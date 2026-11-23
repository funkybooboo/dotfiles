# 000590-homelab-maintenance.sh -- homelab maintenance loop tooling
# Installs: the ansible collections the homelab loop drives
# Links:    --
# Enables:  --
# Note: 000589 installs the ansible ENGINE; this installs the
#       collections so a fresh machine can run the homelab
#       maintenance loop (~/Projects/homelab, git clone from GitHub):
#         make deps        <- this migration
#         make converge    # guests/*.yaml -> running (idempotent)
#         make update      # tier-gated patch pass (OPS-23 model)
#         make verify      # read-only drift check
#       plus `make deps` after the repo is cloned. The repo's
#       ansible/requirements.yml is the source of truth when the
#       repo is checked out; without it, the known set installs and
#       the operator re-runs make deps after cloning. SECRETS STAY
#       OUT: local/*.env (gitignored API tokens + passwords) is the
#       operator's to restore -- the loop refuses to converge
#       without it, loudly.
#       Weekly habit + reboot runbook: docs/maintenance.md in the
#       homelab repo.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "homelab maintenance"

REPO="$HOME/Projects/homelab"

if [[ -f "$REPO/ansible/requirements.yml" ]]; then
    if ansible-galaxy collection install -r "$REPO/ansible/requirements.yml"; then
        ok "collections from $REPO/ansible/requirements.yml"
    else
        _add_warning "ansible-galaxy install from the homelab repo failed"
    fi
else
    warn "homelab repo not found at $REPO"
    if ansible-galaxy collection install community.proxmox ansible.posix community.general oxlorg.opnsense; then
        _add_warning "homelab repo absent: known collections installed; re-run make deps after cloning"
    else
        _add_warning "ansible-galaxy install of the known collections failed"
    fi
fi
