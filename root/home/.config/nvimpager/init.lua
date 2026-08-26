-- nvimpager config
-- nvimpager sets NVIM_APPNAME=nvimpager, so this runs as a SEPARATE neovim
-- config from the main LazyVim one at ~/.config/nvim. Keep it minimal: just a
-- colorscheme + a few display options so paged output (git log, man, etc.)
-- looks consistent with the main editor instead of neovim's default theme.

-- Terminal true-colour (catppuccin needs it; nvim 0.12 defaults to true).
vim.opt.termguicolors = true

-- Reuse the catppuccin plugin installed by the main nvim's lazy, if present,
-- so the pager matches the editor. Fall back to a decent built-in otherwise.
local catppuccin = os.getenv("HOME") .. "/.local/share/nvim/lazy/catppuccin"
if vim.fn.isdirectory(catppuccin) == 1 then
  vim.opt.rtp:prepend(catppuccin)
  local ok = pcall(vim.cmd, "colorscheme catppuccin-mocha")
  if not ok then
    pcall(vim.cmd, "colorscheme habamax")
  end
else
  pcall(vim.cmd, "colorscheme habamax")
end

-- Display options for a cleaner pager.
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = "no"
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 5
vim.opt.list = false
vim.opt.fillchars = { eob = " " } -- hide the ~ end-of-buffer markers
