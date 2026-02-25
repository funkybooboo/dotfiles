return {
  -- Configure nvim-lspconfig for Assembly
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Assembly Language Server
        asm_lsp = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "asm-lsp", -- Assembly LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "asm",
      },
    },
  },
}
