# 000023-greetd-config.sh — deploy greetd config (tuigreet -> uwsm Hyprland) + PAM
# Installs: —
# Links:    —
# Deploys:  /etc/greetd/config.toml, /etc/pam.d/greetd
# Enables:  —
#
# 000022-greetd.sh installs greetd + greetd-tuigreet and enables the service,
# but ships no config — without this migration /etc/greetd/config.toml stays
# the stock `agreety --cmd /bin/sh` default, so on reboot greetd launches a
# plain shell prompt instead of a graphical greeter, and Hyprland never
# starts. This deploys a config pointing tuigreet at the uwsm-managed
# Hyprland session (hyprland-uwsm.desktop, installed by 000310-hyprland.sh).
#
# It also deploys /etc/pam.d/greetd WITHOUT pam_securetty.so. The stock
# greetd PAM file includes `auth required pam_securetty.so`, which works for
# agreety (it sets PAM_TTY) but breaks tuigreet: tuigreet does not set
# PAM_TTY, so pam_securetty fails with "cannot determine user's tty" and,
# being `required`, blocks ALL logins. Dropping pam_securetty is the standard
# fix for graphical/TUI greeters under greetd (the greeter already owns a
# dedicated VT, so securetty's root-TTY restriction is irrelevant here).
#
# deploy_etc_file backs up existing files to <dest>.bak.<ts> before
# overwriting, so stock or hand-edited configs are never lost.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "greetd config"

deploy_etc_file \
  "$DOTFILES_ROOT_ETC/greetd/config.toml" \
  "/etc/greetd/config.toml" \
  644

deploy_etc_file \
  "$DOTFILES_ROOT_ETC/pam.d/greetd" \
  "/etc/pam.d/greetd" \
  644

ok "greetd configured: tuigreet -> Hyprland (uwsm) + PAM fixed for tuigreet"
