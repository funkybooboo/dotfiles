-- Assembly Language Server (asm-lsp) configuration
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Ensure servers table exists
      opts.servers = opts.servers or {}

      -- Add asm_lsp to servers
      local home = vim.fn.expand("~")
      opts.servers.asm_lsp = {
        cmd = { home .. "/.cargo/bin/asm-lsp" },
        filetypes = { "asm", "s", "S", "nasm" },
        settings = {},
      }

      -- Setup custom server registration
      opts.setup = opts.setup or {}
      opts.setup.asm_lsp = function(_, server_opts)
        local lspconfig = require("lspconfig")
        local configs = require("lspconfig.configs")
        local util = require("lspconfig.util")

        -- Register asm_lsp if not already registered
        if not configs.asm_lsp then
          configs.asm_lsp = {
            default_config = {
              cmd = server_opts.cmd,
              filetypes = server_opts.filetypes,
              root_dir = util.root_pattern(".git", ".asm-lsp.toml") or util.path.dirname,
              settings = server_opts.settings or {},
            },
          }
        end

        -- Setup the server
        lspconfig.asm_lsp.setup(server_opts)
        return true
      end

      return opts
    end,
  },
}
