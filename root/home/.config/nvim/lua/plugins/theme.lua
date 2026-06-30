-- Colorscheme / theme — matches the omarchy "Tokyo Night" default look.
-- See ~/referances/omarchy/themes/tokyo-night/neovim.lua
-- LazyVim's default colorscheme is "tokyonight" (the "moon" style, which
-- renders as tokyonight-moon, bg #1a1b26-ish blue). Omarchy's default uses
-- the "night" style (tokyonight-night, bg #1a1b26) via this spec, matching
-- the terminal palette in themes/tokyo-night/colors.toml.
return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
