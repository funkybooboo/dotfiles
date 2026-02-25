return {
  -- Configure nvim-lspconfig for Terraform
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Terraform Language Server
        terraformls = {},
        -- Terraform Linter
        tflint = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "terraform-ls", -- Terraform LSP
        "tflint",       -- Terraform linter
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "terraform",
        "hcl",
      },
    },
  },
}
