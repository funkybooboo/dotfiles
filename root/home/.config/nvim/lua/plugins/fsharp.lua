return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        fsautocomplete = {},
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "fsautocomplete",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "fsharp",
      })
    end,
  },
}