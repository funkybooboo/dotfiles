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
        -- Ruff (fast linter/formatter)
        ruff = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "pyright",      -- Python LSP
        "ruff",         -- Python linter/formatter LSP (replaces ruff-lsp)
        "debugpy",      -- Python debugger
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
