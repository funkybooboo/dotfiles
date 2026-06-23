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
    opts = function()
      local dap = require("dap")
      dap.adapters.zig = {
        type = "executable",
        command = "/usr/bin/gdb",
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
