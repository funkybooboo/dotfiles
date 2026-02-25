return {
  "funkybooboo/exercism.nvim",
  lazy = false,
  dependencies = {
    "2kabhishek/utils.nvim",
    "2kabhishek/termim.nvim",
  },
  config = function()
    require("exercism").setup({})
  end,
}
