return {
  -- Enable built-in spell checking
  {
    "neovim/nvim-lspconfig",
    opts = function()
      vim.opt.spell = true
      vim.opt.spelllang = "en_us"
    end,
  },

  -- LTeX LSP for grammar and spell checking
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

  -- Mason: Install spell checker
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "ltex-ls", -- Grammar and spell checker
      },
    },
  },
}
