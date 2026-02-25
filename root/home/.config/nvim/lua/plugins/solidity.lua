return {
  -- Configure nvim-lspconfig for Solidity
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Solidity Language Server
        solidity = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "solidity",       -- Solidity LSP
        "solhint",        -- Solidity linter
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "solidity",
      },
    },
  },
}
