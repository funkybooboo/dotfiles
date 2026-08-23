-- exercism.nvim -- browse/test/submit Exercism exercises from inside Neovim.
-- Requires the external `exercism` CLI (installed via the 000233-exercism
-- migration, `nix profile install .#exercism`). Run `exercism configure` once
-- to set the token + workspace before first use.
return {
  "2kabhishek/exercism.nvim",
  cmd = { "Exercism" },
  keys = {
    { "<leader>exa", "<cmd>Exercism languages<cr>", desc = "Exercism: languages" },
    { "<leader>exl", "<cmd>Exercism list<cr>", desc = "Exercism: list exercises" },
    { "<leader>ext", "<cmd>Exercism test<cr>", desc = "Exercism: run tests" },
    { "<leader>exs", "<cmd>Exercism submit<cr>", desc = "Exercism: submit" },
    { "<leader>exr", "<cmd>Exercism recents<cr>", desc = "Exercism: recents" },
  },
  dependencies = {
    "2kabhishek/utils.nvim", -- required: utils.notification, utils.shell
    "2kabhishek/termim.nvim", -- optional: better test-run UX (:STerm)
    "nvim-lua/plenary.nvim", -- required: plenary.path (used in main.lua)
  },
  opts = {
    exercism_workspace = "~/Projects/problem_practice/exercism",
    add_default_keybindings = false, -- keys are declared above instead
    max_recents = 30,
  },
}
