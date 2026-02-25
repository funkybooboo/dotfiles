return {
  -- Configure nvim-lspconfig for Erlang
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Erlang Language Server
        erlangls = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "erlang-ls", -- Erlang LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "erlang",
      },
    },
  },
}
