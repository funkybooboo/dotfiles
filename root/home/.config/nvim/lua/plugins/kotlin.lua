return {
  -- Configure nvim-lspconfig for Kotlin
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Kotlin Language Server
        kotlin_language_server = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "kotlin-language-server", -- Kotlin LSP
        "ktlint",                 -- Kotlin linter
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "kotlin",
      },
    },
  },
}
