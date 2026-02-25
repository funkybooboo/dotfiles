return {
  -- Configure nvim-lspconfig for Ruby
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Ruby LSP (official from Shopify)
        ruby_lsp = {
          init_options = {
            formatter = "auto",
            linters = { "rubocop" },
          },
        },
        -- Alternative: Solargraph
        -- solargraph = {
        --   settings = {
        --     solargraph = {
        --       diagnostics = true,
        --       completion = true,
        --     },
        --   },
        -- },
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "ruby-lsp",    -- Ruby LSP (official)
        "rubocop",     -- Ruby linter/formatter
        -- "solargraph", -- Alternative Ruby LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "ruby",
      },
    },
  },
}
