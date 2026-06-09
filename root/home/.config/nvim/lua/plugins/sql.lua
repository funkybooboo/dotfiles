return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sqlls = {},
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "sqlls",
        "sqlfmt",
        "sqlfluff",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "sql",
      })
    end,
  },
}