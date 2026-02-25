return {
  -- Configure nvim-lspconfig for Java
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Java Language Server
        jdtls = {
          -- Note: jdtls is typically configured via nvim-jdtls plugin
          -- This is a basic setup; for full features, consider using nvim-jdtls
        },
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "jdtls",           -- Java LSP
        "java-debug-adapter", -- Java debugger
        "java-test",       -- Java test runner
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "java",
      },
    },
  },
}
