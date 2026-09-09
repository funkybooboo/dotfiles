return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        dockerls = {},
        docker_compose_language_service = {},
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "dockerfile-language-server",
        "docker-compose-language-service",
        "hadolint",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "dockerfile",
      })
    end,
  },

  -- hadolint has no LSP equivalent: dockerls does schema/completion, not
  -- Dockerfile best-practice lint. mason already installed it above, but nothing
  -- referenced it, so it never ran. Zero-config, so no gate needed.
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        dockerfile = { "hadolint" },
      },
    },
  },
}