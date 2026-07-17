# 000500-calcure.sh — calcure (TUI calendar) + config
# Installs: calcure
# Links:    ~/.config/calcure/config.ini
# Enables:  —
# Note: calendar-tui (in personal-admin-scripts) launches calcure.
#.policy-exception: this is the ONE remaining `install_aur` call after the
# 2026-07 off-AUR audit (every other install_aur was moved to install_pacman
# because their packages landed in Arch extra/, or vendored into pkgbuilds/
# and audited). calcure stays AUR-only by documented user decision (the only
# PyPI-hosted holdout + a chain of AUR python-* deps from PyPI sources; vendoring
# would require pinning ~7 PyPI packages in pkgbuilds/ with hand-computed shas —
# not worth the churn for this app). If upstream lands in Arch extra OR ships
# official binary releases, swap to that tier then. Until then: install_aur
# is the lowest-trust tier but it's the only available channel for this app.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "calcure"

install_aur calcure
link_file "$DOTFILES_HOME/.config/calcure/config.ini" "$HOME/.config/calcure/config.ini"
