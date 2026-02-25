return {
  -- Configure nvim-lspconfig for F#
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- F# Language Server
        fsautocomplete = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "fsautocomplete", -- F# LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "fsharp",
      },
    },
  },
}
