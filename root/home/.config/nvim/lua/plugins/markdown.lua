return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {},
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "marksman",
        "markdownlint",
        "markdown-toc",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "markdown",
        "markdown_inline",
      })
    end,
  },

  -- marksman handles links/refs but does not lint prose style. mason already
  -- installed markdownlint above, but nothing referenced it, so it never ran.
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = { "markdownlint" },
      },
    },
  },

  -- Live browser preview that renders mermaid code blocks as diagrams
  -- (docs/network.md, docs/backups.md). First :MarkdownPreview opens a
  -- local server + the default browser. Build = the plugin's own
  -- install.sh (prebuilt server binary download, npm fallback); the
  -- mkdp#util#install form fails on FRESH installs because the plugin's
  -- autoload is not sourced during build. node/npm presence is
  -- migration-guaranteed (000208-neovim-node-host.sh), so no runtime
  -- step is owed on any machine.
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && sh install.sh",
  },
}