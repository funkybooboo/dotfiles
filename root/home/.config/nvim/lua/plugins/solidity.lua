return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        solidity = {},
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "solidity",
        "solhint",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "solidity",
      })
    end,
  },
}