-- Active colorscheme: catppuccin (mocha).
-- Ported from omarchy themes/catppuccin/neovim.lua. The "catppuccin-nvim"
-- colorscheme name resolves to the mocha flavour (bg #1e1e2e), matching the
-- omarchy catppuccin terminal palette (themes/catppuccin/colors.toml).
-- catppuccin is also listed in all-themes.lua (lazy); this spec activates it.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-nvim",
    },
  },
}
