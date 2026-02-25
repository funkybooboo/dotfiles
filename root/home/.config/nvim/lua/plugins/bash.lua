return {
  -- Configure nvim-lspconfig for Bash
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Bash Language Server
        bashls = {
          settings = {
            bashIde = {
              globPattern = "*@(.sh|.inc|.bash|.command)",
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
        "bash-language-server", -- Bash LSP
        "shellcheck",           -- Shell script linter
        "shfmt",                -- Shell script formatter
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
      },
    },
  },
}
