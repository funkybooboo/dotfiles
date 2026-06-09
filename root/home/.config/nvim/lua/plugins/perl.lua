return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        perlnavigator = {},
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "perlnavigator",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "perl",
      })
    end,
  },
}