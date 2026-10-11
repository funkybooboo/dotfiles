# 000233-exercism.sh -- exercism CLI (nix flake)
# Nix:     .#exercism
# Links:   --
# Enables: --
# Note: one piece of software = one migration. Provides the `exercism` CLI used
#       by 2kabhishek/exercism.nvim (declared in nvim plugin spec
#       lua/plugins/exercism.lua). After install, run `exercism configure` once
#       (needs a token from exercism.io -> Account Settings -> API token) to
#       set the token before the plugin can fetch/test/submit. The CLI
#       workspace is enforced below (exercism.nvim checks/opens exercises in
#       its own exercism_workspace, so downloads must land there; without
#       this, downloads went to the CLI default ~/exercism and the plugin
#       could never open them, seen 2026-10-10). Split out as its own
#       dev-tools migration per the one-package-per-file convention.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "exercism"

install_nix .#exercism

# Enforce the CLI workspace to match exercism.nvim's exercism_workspace
# (lua/plugins/exercism.lua). Safe to re-run: skips when already correct.
# Needs jq (000213-jq.sh) and the token already configured (the CLI refuses
# `configure` without one, hence the warning path for fresh machines).
EXERCISM_USER_JSON="${HOME}/.config/exercism/user.json"
EXERCISM_WORKSPACE="${HOME}/Projects/problem_practice/exercism"
if [[ -f "${EXERCISM_USER_JSON}" ]]; then
    current_ws=$(jq -r '.workspace // empty' "${EXERCISM_USER_JSON}" 2>/dev/null)
    if [[ "${current_ws}" == "${EXERCISM_WORKSPACE}" ]]; then
        ok "exercism workspace already ${EXERCISM_WORKSPACE}"
    elif exercism configure --workspace="${EXERCISM_WORKSPACE}" >/dev/null 2>&1; then
        ok "exercism workspace set to ${EXERCISM_WORKSPACE}"
    else
        _add_warning "exercism configure --workspace failed; run manually: exercism configure --workspace=${EXERCISM_WORKSPACE}"
    fi
else
    _add_warning "exercism not configured yet; run: exercism configure --token=<token> --workspace=${EXERCISM_WORKSPACE}"
fi

ok "exercism"
