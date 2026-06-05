return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
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

  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "taplo",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "toml",
      })
    end,
  },
}