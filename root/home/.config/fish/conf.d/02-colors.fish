# 02-colors.fish -- syntax/pager colors (Catppuccin Mocha)
#
# fish_color_* govern the syntax highlighter; fish_pager_color_* govern the
# tab-completion pager. Set as global (not universal) so they track this file
# rather than ~/.config/fish/fish_variables, and so a theme change here
# applies on next session without per-user drift.

set -g fish_color_command cba6f7
set -g fish_color_keyword f5c2e7
set -g fish_color_param cdd6f4
set -g fish_color_option 89b4fa
set -g fish_color_normal cdd6f4
set -g fish_color_comment 6c7086
set -g fish_color_error f38ba8
set -g fish_color_redirection fab387
set -g fish_color_end f5e0dc
set -g fish_color_operator 89dceb
set -g fish_color_autosuggestion 7f849c
set -g fish_color_search_match --background=45475a
set -g fish_color_selection --background=45475a
set -g fish_pager_color_completion cdd6f4
set -g fish_pager_color_description a6adc8
set -g fish_pager_color_prefix cba6f7
