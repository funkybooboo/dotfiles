return {
  -- Configure nvim-lspconfig for Markdown
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Markdown Language Server
        marksman = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "marksman",      -- Markdown LSP
        "markdownlint",  -- Markdown linter
        "markdown-toc",  -- Table of contents generator
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "markdown",
        "markdown_inline",
      },
    },
  },
}
