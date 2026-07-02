# 000203-python.sh -- system Python + poetry + pythonrc
# Installs: python python-poetry-core
# Links:    ~/.config/python/pythonrc
# Enables:  --
# Note: System python is installed for pythonrc / poetry-core. Language runtime
#       versions for projects are managed by mise (see 000202-mise).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "python"

if is_debian; then install_apt python3 python3-poetry
else install_pacman python python-poetry-core
fi
link_file "$DOTFILES_HOME/.config/python/pythonrc" "$HOME/.config/python/pythonrc"
