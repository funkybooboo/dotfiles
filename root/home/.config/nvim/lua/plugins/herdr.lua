-- herdr-nvim -- annotate lines in nvim, then hand the annotations to a coding
-- agent running in a sibling herdr pane.
--
-- This spec is only half the plugin. The same upstream repo also ships a herdr
-- plugin (Rust: the full-height nvim sidebar, and a picker over the files the
-- agent touched this session), installed by the 000238-herdr-nvim migration
-- through herdr's own plugin manager. lazy carries the annotation half only.
--
-- cond rather than an unconditional spec: every entry point here resolves a
-- target agent by asking the herdr server over $HERDR_SOCKET_PATH, so outside a
-- herdr session the maps would exist with nothing to send to. herdr exports
-- HERDR_ENV=1 into every pane it owns, including the nvim daemon behind its own
-- sidebar, so the sidebar still gets these maps.
--
-- keymaps = false plus an explicit keys table, following exercism.lua: setup()
-- would bind these same five maps itself, but declaring them here is what lets
-- lazy defer the load (defaults.lazy = false in config/lazy.lua) and what gives
-- which-key a description. They mirror upstream's own bindings, x mode included
-- -- select mode leaves no useful '< '> marks for the range to read.
return {
  "ChmaraX/herdr-nvim",
  cond = function()
    return vim.env.HERDR_ENV == "1"
  end,
  cmd = "Herdr",
  keys = {
    {
      "<leader>ac",
      function()
        require("herdr-nvim").comment_line()
      end,
      desc = "Herdr: comment line",
    },
    -- The Lua API rather than <cmd>Herdr comment<cr>: a <cmd> mapping does not
    -- carry the visual range, and comment_selection materializes '< '> first.
    {
      "<leader>ac",
      function()
        require("herdr-nvim").comment_selection()
      end,
      mode = "x",
      desc = "Herdr: comment selection",
    },
    {
      "<leader>al",
      function()
        require("herdr-nvim").list_comments()
      end,
      desc = "Herdr: list comments",
    },
    {
      "<leader>as",
      function()
        require("herdr-nvim").send_all({ submit = false })
      end,
      desc = "Herdr: paste comments to agent",
    },
    {
      "<leader>aS",
      function()
        require("herdr-nvim").send_all({ submit = true })
      end,
      desc = "Herdr: send comments to agent",
    },
  },
  opts = {
    keymaps = false, -- keys are declared above instead
    -- clear_after_send left at its default: upstream treats the comments as
    -- ephemeral, and they are already in the agent's input once sent.
  },
}
