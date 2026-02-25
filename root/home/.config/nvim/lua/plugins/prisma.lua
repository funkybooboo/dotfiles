return {
  -- Configure nvim-lspconfig for Prisma
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Prisma Language Server
        prismals = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "prisma-language-server", -- Prisma LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "prisma",
      },
    },
  },
}
