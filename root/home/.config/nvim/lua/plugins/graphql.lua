return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        graphql = {},
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "graphql-language-service-cli",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "graphql",
      })
    end,
  },
}