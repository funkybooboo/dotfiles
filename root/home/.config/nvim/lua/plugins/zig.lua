return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        zls = {},
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "zls",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "zig",
      })
    end,
  },

  {
    "mfussenegger/nvim-dap",
    -- nvim-dap has no .setup() function, so use `config` (imperative)
    -- rather than `opts`, which would trigger lazy's default setup() call.
    config = function()
      local dap = require("dap")
      dap.adapters.zig = {
        type = "executable",
        command = vim.fn.exepath("gdb") or "/usr/bin/gdb",
        args = { "-i", "dap" },
      }
      dap.configurations.zig = {
        {
          name = "Debug lazyrts",
          type = "zig",
          request = "launch",
          program = "${workspaceFolder}/zig-out/bin/lazyrts",
          cwd = "${workspaceFolder}",
        },
      }
    end,
  },
}
