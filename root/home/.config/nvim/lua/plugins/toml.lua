return {
  -- Configure nvim-lspconfig for TOML
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- TOML Language Server
        taplo = {
          settings = {
            evenBetterToml = {
              schema = {
                enabled = true,
                associations = {
                  ["pyproject\\.toml"] = "https://json.schemastore.org/pyproject.json",
                  ["Cargo\\.toml"] = "https://json.schemastore.org/cargo.json",
                },
              },
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
        "taplo", -- TOML LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "toml",
      },
    },
  },
}
