-- leetcode.nvim -- solve LeetCode problems inside Neovim.
-- All deps already present: plenary.nvim, nui.nvim, snacks.nvim (picker),
-- nvim-treesitter (html parser in ensure_installed, auto-updated on :TSUpdate).
--
-- Launch the standalone UI with:  nvim leetcode.nvim
-- (the `arg` below is the literal argv[1] the plugin matches on). Once inside,
-- :Leet opens the dashboard; :Leet list/daily/random/run/submit/etc.
-- First run: :Leet then sign in via the on-screen button (LeetCode session
-- cookie is cached under vim.fn.stdpath("data")/leetcode).
return {
  "kawre/leetcode.nvim",
  lazy = false, -- standalone UI: load on any `nvim leetcode.nvim` launch
  -- no build step: the html treesitter parser is already in ensure_installed
  -- (lua/plugins/treesitter.lua) and updates on every normal :TSUpdate. lazy
  -- runs build in a headless instance where nvim-treesitter isn't loaded, so
  -- `build = ":TSUpdate html"` errors with E492 (no :TSUpdate command yet).
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "folke/snacks.nvim", -- picker provider (auto-resolved, first preference)
  },
  opts = {
    arg = "leetcode.nvim",
    lang = "python3",
    -- cn = { enabled = false }, -- set enabled = true for leetcode.cn
    logging = true,
    image_support = false, -- set true if image.nvim v1.4+ is installed
    -- picker = { provider = "snacks" }, -- auto-resolves to snacks; uncomment to pin
    hooks = {
      --["enter"] = { function() end },
    },
  },
}
