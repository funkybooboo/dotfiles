return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = {
                  enable = true,
                },
              },
              -- rust-analyzer's schema: `checkOnSave` is a boolean, and the
              -- sub-options live under `check.*`. Passing a table here made
              -- rust-analyzer reject the whole block ("invalid type: map,
              -- expected a boolean"), silently disabling clippy-on-save -- and
              -- taking procMacro.ignored below down with it, since the server
              -- rejects the entire ["rust-analyzer"] object, not just this key.
              -- `check.features` inherits `cargo.features`, already all above.
              checkOnSave = true,
              check = {
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
            },
          },
        },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "rust-analyzer",
        "codelldb",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "rust",
        "toml",
      })
    end,
  },

  -- Debugging via codelldb. Two halves: the adapter (how to start the debug
  -- server) and the configuration (what to debug). Same shape LazyVim uses for
  -- c/cpp in extras/lang/clangd.lua.
  --
  -- mason already installed codelldb above, but nothing registered it with
  -- nvim-dap, so Rust debugging was dead: the binary was on disk and unreachable.
  --
  -- This attaches via `opts`, deliberately NOT `config`. zig.lua owns the single
  -- `config` on mfussenegger/nvim-dap and lazy.nvim keeps only one when specs
  -- merge (see the note at the top of dap.lua). `opts` functions merge instead, so
  -- this coexists -- the same arrangement the work repo already runs.
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")

      if not dap.adapters["codelldb"] then
        dap.adapters["codelldb"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "codelldb", -- mason puts this on PATH
            args = {
              "--port",
              "${port}",
            },
          },
        }
      end

      dap.configurations.rust = {
        {
          name = "Launch cargo binary",
          type = "codelldb",
          request = "launch",
          program = function()
            -- dev profile, not --release: release strips DWARF and inlines, so
            -- breakpoints misland and locals read <optimized out>
            vim.fn.system({ "cargo", "build" })
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          -- loads codelldb's Rust type formatters, so Vec/String/Option render
          -- readably instead of as raw pointer guts
          sourceLanguages = { "rust" },
        },
      }
    end,
  },
}