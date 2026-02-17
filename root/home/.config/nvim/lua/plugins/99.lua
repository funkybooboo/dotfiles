return {
  "funkybooboo/99",
  branch = "no-cmp-requirement",
  dir = "/home/nate/projects/99", -- Use local development version
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local Providers = require("99").Providers

    require("99").setup({
      provider = Providers.OpenCodeProvider,
      model = "opencode/kimi-k2.5-free", -- Use a free model
      display_errors = true, -- Show errors in the UI
      show_in_flight_requests = true, -- Show when requests are running
      logger = {
        level = require("99").DEBUG,
        path = vim.fn.stdpath("state") .. "/99.log",
      },
      -- DON'T set completion.source - this allows it to run without nvim-cmp
      completion = {
        source = nil, -- Explicitly disable cmp integration
        custom_rules = {},
      },
    })

    -- Set up keybindings
    vim.keymap.set("n", "<leader>9v", function()
      require("99").visual()
    end, { desc = "99: AI Visual Request" })

    vim.keymap.set("v", "<leader>9v", function()
      require("99").visual()
    end, { desc = "99: AI Visual Request" })

    vim.keymap.set("n", "<leader>9s", function()
      require("99").stop_all_requests()
    end, { desc = "99: Stop All Requests" })

    vim.keymap.set("n", "<leader>9i", function()
      require("99").info()
    end, { desc = "99: Show Info" })

    vim.keymap.set("n", "<leader>9l", function()
      vim.cmd("edit " .. vim.fn.stdpath("state") .. "/99.log")
    end, { desc = "99: View Log File" })

    vim.keymap.set("n", "<leader>9d", function()
      require("99").view_logs()
    end, { desc = "99: View Debug Logs" })
  end,
}
