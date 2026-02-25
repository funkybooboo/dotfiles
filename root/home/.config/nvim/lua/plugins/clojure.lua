return {
  -- Configure nvim-lspconfig for Clojure
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Clojure Language Server
        clojure_lsp = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "clojure-lsp", -- Clojure LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "clojure",
      },
    },
  },
}
