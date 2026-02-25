return {
  -- Configure nvim-lspconfig for Perl
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Perl Language Server
        perlnavigator = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "perlnavigator", -- Perl LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "perl",
      },
    },
  },
}
