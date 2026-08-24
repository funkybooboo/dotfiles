-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Consistent 4-space indentation for every language. LazyVim's default is
-- 2 spaces (shiftwidth=2 tabstop=2). This file is sourced at the VeryLazy
-- event, which runs AFTER LazyVim's own options.lua, so setting the values
-- here actually overrides them (setting them in config/options.lua does NOT,
-- because that file runs before lazy.nvim startup and LazyVim re-sets them to
-- 2 during startup). expandtab stays on (spaces, not literal tabs). Global,
-- so all filetypes inherit 4 unless a ftplugin sets a buffer-local value.
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
