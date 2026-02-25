return {
  -- Configure nvim-lspconfig for GraphQL
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- GraphQL Language Server
        graphql = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "graphql-language-service-cli", -- GraphQL LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "graphql",
      },
    },
  },
}
