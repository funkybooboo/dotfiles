return {
  -- Configure nvim-lspconfig for OCaml
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- OCaml Language Server
        ocamllsp = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "ocaml-lsp", -- OCaml LSP
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "ocaml",
        "ocaml_interface",
      },
    },
  },
}
