return {
  -- Enable LazyVim's Python extras
  {
    "LazyVim/LazyVim",
    opts = {
      -- This will automatically configure Python LSP
    },
  },

  -- Configure nvim-lspconfig for Python
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Pyright (recommended Python LSP)
        pyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic", -- "off", "basic", "strict"
              },
            },
          },
        },
        -- Alternative: Ruff LSP (fast linter/formatter)
        ruff_lsp = {
          init_options = {
            settings = {
              args = {},
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
        "pyright",      -- Python LSP
        "ruff-lsp",     -- Python linter/formatter LSP
        "debugpy",      -- Python debugger
        "black",        -- Python formatter (optional)
        "isort",        -- Import sorter (optional)
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "python",
      },
    },
  },
}
