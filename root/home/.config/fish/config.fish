# config.fish -- fish startup entrypoint
#
# Only the bits that MUST live here: greeting and vi-mode key binding style.
# Everything else (env, path, colors, abbreviations, aliases, tool init) is
# split by concern into conf.d/*.fish, which fish sources in lexical order
# before this file. Standalone commands live as autoloaded functions in
# functions/*.fish (one per file, lazy-loaded on first use).

set -g fish_greeting

# Vi mode. fish calls fish_user_key_bindings (defined in functions/) after
# applying the mode, so custom binds live there -- not inline here.
set -g fish_key_bindings fish_vi_key_bindings
