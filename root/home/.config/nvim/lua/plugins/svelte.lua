return {
  -- Configure nvim-lspconfig for Svelte
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Svelte Language Server
        svelte = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "svelte-language-server", -- Svelte LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "svelte",
      },
    },
  },
}
