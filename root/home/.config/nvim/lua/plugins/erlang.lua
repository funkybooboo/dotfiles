return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        erlangls = {},
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "erlang-ls",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "erlang",
      })
    end,
  },
}