return {
  -- Configure nvim-lspconfig for Protobuf
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Protobuf Language Server
        bufls = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "buf", -- Protobuf LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "proto",
      },
    },
  },
}
