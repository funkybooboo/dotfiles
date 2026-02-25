return {
  -- Configure nvim-lspconfig for LaTeX
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- LaTeX Language Server
        texlab = {
          settings = {
            texlab = {
              build = {
                onSave = true,
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
        "texlab",     -- LaTeX LSP
        "latexindent", -- LaTeX formatter
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "latex",
        "bibtex",
      },
    },
  },
}
