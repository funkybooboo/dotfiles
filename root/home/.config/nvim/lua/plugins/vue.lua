return {
  -- Configure nvim-lspconfig for Vue
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Vue Language Server
        volar = {
          filetypes = { "vue" },
        },
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "vue-language-server", -- Vue LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vue",
      },
    },
  },
}
