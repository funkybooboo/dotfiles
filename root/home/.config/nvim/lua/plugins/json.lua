return {
  -- SchemaStore for JSON schemas
  {
    "b0o/schemastore.nvim",
  },

  -- Configure nvim-lspconfig for JSON
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "b0o/schemastore.nvim",
    },
    opts = {
      servers = {
        -- JSON Language Server
        jsonls = {
          on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
          end,
          settings = {
            json = {
              format = {
                enable = true,
              },
              validate = { enable = true },
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
        "json-lsp", -- JSON LSP
        "jq",       -- JSON processor
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "json",
        "json5",
        "jsonc",
      },
    },
  },
}
