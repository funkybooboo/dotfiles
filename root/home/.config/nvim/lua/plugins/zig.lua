return {
  -- Configure nvim-lspconfig for Zig
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Zig Language Server
        zls = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "zls", -- Zig LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "zig",
      },
    },
  },
}
