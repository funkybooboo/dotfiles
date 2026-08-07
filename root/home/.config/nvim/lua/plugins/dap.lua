-- dap.lua -- JS/TS/Bun debugger (vscode-js-debug) + DAP UI, scoped so it does
-- not collide with the existing `nvim-dap` config in zig.lua.
--
-- Why this layout:
--   zig.lua already declares `mfussenegger/nvim-dap` with its own `config`
--   (the zig adapter). lazy.nvim keeps only one `config` per plugin when specs
--   merge, so we MUST NOT add another `config` on the nvim-dap spec or our JS
--   setup would be dropped. Instead we own the single config of nvim-dap-ui
--   (a plugin nobody else here configures) and do all JS adapter + launch
--   setup from there. All DAP action keymaps are attached to nvim-dap-ui, so
--   pressing any of them loads dap-ui + its config (registering adapters and
--   the erledigen launch configs) BEFORE dap.continue() runs.
--
-- Extras not enabled in this config (lazyvim.json extras = []), so this file
-- also provides the DAP UI providers + signs the dap-core extra would have.

local ERLEDIGEN = vim.fn.expand("~/Projects/erledigen")

-- Only register the erledigen launch configs when working inside that repo,
-- so `:DapContinue` does not offer Bun/Chrome entries for unrelated projects.
local function in_erledigen()
  local buf = vim.api.nvim_buf_get_name(0)
  if buf ~= "" and vim.startswith(buf, ERLEDIGEN) then
    return true
  end
  return vim.startswith(vim.fn.getcwd(0), ERLEDIGEN)
end

return {
  -- Inline variable values + exception scopes next to the code.
  -- `opts = {}` makes lazy.nvim call require("nvim-dap-virtual-text").setup
  -- automatically; the plugin attaches its own dap listeners on load.
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      commented = true, -- prefix with comment syntax -> visually quiet
      only_first_definition = false,
      all_frames = false,
    },
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    -- stylua: ignore
    keys = {
      { "<leader>du", function() require("dapui").toggle() end, desc = "DAP UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = { "n", "x" } },
      { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Breakpoint Condition" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")

      -- DAP UI + auto open/close around sessions.
      dapui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close({})
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close({})
      end

      -- Breakpoint/stopped signs (replicate the dap-core extra). Prefer
      -- LazyVim's icon set so the gutter matches the rest of the config;
      -- fall back to ASCII glyphs so this is correct even without it.
      local icons = (LazyVim and LazyVim.config and LazyVim.config.icons and LazyVim.config.icons.dap)
        or {}
      local defaults = {
        Breakpoint = "B",
        BreakpointCondition = "C",
        BreakpointRejected = "R",
        Stopped = ">",
      }
      for name, fallback in pairs(defaults) do
        local icon = icons[name]
        local text = icon and (type(icon) == "table" and icon[1] or icon) or fallback
        local texthl = ({
          Breakpoint = "DiagnosticSignError",
          BreakpointCondition = "DiagnosticSignWarn",
          BreakpointRejected = "DiagnosticSignHint",
          Stopped = "DiagnosticSignWarn",
        })[name]
        local def = { text = text, texthl = texthl }
        if name == "Stopped" then
          def.linehl = "DapStoppedLine"
          def.numhl = "DapStoppedLine"
        end
        vim.fn.sign_define("Dap" .. name, def)
      end
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      -- vscode-js-debug speaks the pwa-node and pwa-chrome adapter types.
      -- dapDebugServer.js is invoked on a chosen port; it restarts per session.
      -- Mason installs vscode-js-debug under
      -- packages/js-debug-adapter/js-debug/src/dapDebugServer.js (note the
      -- nested `js-debug/` dir); resolve it robustly in case the layout moves.
      local mason = vim.fn.stdpath("data") .. "/mason"
      local server = mason .. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
      if vim.fn.filereadable(server) ~= 1 then
        -- fall back to the older flat layout
        server = mason .. "/packages/js-debug-adapter/src/dapDebugServer.js"
      end
      if vim.fn.filereadable(server) == 1 then
        -- Already declared by another dap spec? Keep idempotent.
        dap.adapters["pwa-node"] = {
          type = "server",
          host = "127.0.0.1",
          port = "${port}",
          executable = { command = "node", args = { server, "${port}" } },
        }
        dap.adapters["pwa-chrome"] = {
          type = "server",
          host = "127.0.0.1",
          port = "${port}",
          executable = { command = "node", args = { server, "${port}" } },
        }
      else
        -- Defer: if the Mason package isn't installed yet, leave a helpful
        -- message via the dap error path. Mason auto-installs on next load
        -- (ensure_installed in javascript-typescript.lua).
        vim.schedule(function()
          vim.notify(
            "js-debug-adapter not found in Mason; run :MasonInstall js-debug-adapter",
            vim.log.levels.WARN
          )
        end)
      end

      dap.configurations.javascript = dap.configurations.javascript or {}
      dap.configurations.typescript = dap.configurations.typescript or {}

      if in_erledigen() then
        local bun = vim.fn.exepath("bun")
        if bun == "" then
          bun = "bun"
        end

        local function add(list)
          for _, c in ipairs(list) do
            table.insert(dap.configurations.javascript, c)
            table.insert(dap.configurations.typescript, c)
          end
        end

        add({
          {
            type = "pwa-node",
            request = "launch",
            name = "erledigen: server (Bun)",
            -- Wait for the debugger before running user code, so module
            -- top-level breakpoints hit. Then run the Hono entrypoint.
            runtimeExecutable = bun,
            runtimeArgs = { "run", "src/index.ts" },
            cwd = ERLEDIGEN .. "/apps/server",
            sourceMaps = true,
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
            skipFiles = { "<node_internals>/**" },
            console = "integratedTerminal",
          },
          {
            type = "pwa-chrome",
            request = "launch",
            name = "erledigen: web (Vite + React in Chrome)",
            -- The web app must already be running (`mise run dev` or
            -- `bun --filter @erledigen/web dev`); attach a fresh Chrome.
            url = "http://localhost:5173",
            webRoot = ERLEDIGEN .. "/apps/web",
            sourceMaps = true,
            resolveSourceMapLocations = {
              "${webRoot}/**",
              "${webRoot}/src/**",
              "!**/node_modules/**",
            },
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
          },
        })
      end
    end,
  },
}