return {
  -- Configure nvim-lspconfig for SQL
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- SQL Language Server
        sqlls = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "sqlls",      -- SQL LSP
        "sqlfmt",     -- SQL formatter
        "sqlfluff",   -- SQL linter
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "sql",
      },
    },
  },
}
