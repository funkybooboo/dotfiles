return {
  -- Configure nvim-lspconfig for PHP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- PHP Language Server (Intelephense)
        intelephense = {
          settings = {
            intelephense = {
              stubs = {
                "bcmath",
                "bz2",
                "calendar",
                "Core",
                "curl",
                "zip",
                "zlib",
                "wordpress",
                "woocommerce",
                "acf-pro",
                "wordpress-globals",
                "wp-cli",
                "genesis",
                "polylang",
              },
              environment = {
                includePaths = {},
              },
              files = {
                maxSize = 5000000,
              },
            },
          },
        },
        -- Alternative: phpactor
        -- phpactor = {},
      },
    },
  },

  -- Mason: Automatically install LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "intelephense", -- PHP LSP
        "phpcs",        -- PHP CodeSniffer
        "php-cs-fixer", -- PHP formatter
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "php",
        "phpdoc",
      },
    },
  },
}
