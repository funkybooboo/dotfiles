return {
  -- Configure nvim-lspconfig for Elixir
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Elixir Language Server
        elixirls = {
          settings = {
            elixirLS = {
              dialyzerEnabled = true,
              fetchDeps = false,
            },
          },
        },
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "elixir-ls", -- Elixir LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "elixir",
        "heex",
        "eex",
      },
    },
  },
}
