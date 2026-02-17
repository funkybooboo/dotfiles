-- LSP Configuration for various languages
return {
  -- Configure LSP servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- C/C++ Language Server (clangd)
        -- Use system clangd instead of Mason's version
        clangd = {
          cmd = { "/usr/bin/clangd" },
        },

        -- TypeScript/JavaScript Language Server
        ts_ls = {},  -- LazyVim uses ts_ls now instead of tsserver

        -- Java Language Server (jdtls)
        jdtls = {},

        -- Python Language Server (pyright)
        pyright = {},
      },
    },
  },

  -- Ensure treesitter parsers are installed
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "c",
        "cpp",
        "typescript",
        "javascript",
        "java",
        "python",
      })
      return opts
    end,
  },

  -- Ensure Mason tools are installed
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- Don't install clangd via Mason, use system clangd
        "pyright",
        "jdtls",
        "typescript-language-server",
        "asmfmt",  -- Assembly formatter
      },
    },
  },
}
