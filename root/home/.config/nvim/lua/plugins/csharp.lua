return {
  -- Configure nvim-lspconfig for C#
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- C# Language Server (OmniSharp)
        omnisharp = {
          cmd = { "omnisharp" },
          enable_roslyn_analyzers = true,
          organize_imports_on_format = true,
          enable_import_completion = true,
        },
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "omnisharp",  -- C# LSP
        "csharpier",  -- C# formatter
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "c_sharp",
      },
    },
  },
}
