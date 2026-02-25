return {
  -- Configure nvim-lspconfig for Docker
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Docker Language Server
        dockerls = {},
        -- Docker Compose Language Server
        docker_compose_language_service = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "dockerfile-language-server",        -- Dockerfile LSP
        "docker-compose-language-service",   -- Docker Compose LSP
        "hadolint",                          -- Dockerfile linter
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "dockerfile",
      },
    },
  },
}
