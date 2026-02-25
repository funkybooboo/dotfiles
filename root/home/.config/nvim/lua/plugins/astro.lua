return {
  -- Configure nvim-lspconfig for Astro
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Astro Language Server
        astro = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "astro-language-server", -- Astro LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "astro",
      },
    },
  },
}
