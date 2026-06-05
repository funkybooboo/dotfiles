return {
  {
    "neovim/nvim-lspconfig",
    opts = function()
      vim.opt.spell = true
      vim.opt.spelllang = "en_us"
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ltex = {
          settings = {
            ltex = {
              language = "en-US",
              diagnosticSeverity = "information",
              checkFrequency = "save",
            },
          },
        },
      },
    },
  },

  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "ltex-ls",
      })
    end,
  },
}