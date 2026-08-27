-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Consistent 4-space indentation for every language.
--
-- Why this is here and not in config/options.lua:
--   `shiftwidth`/`tabstop`/`softtabstop` are BUFFER-LOCAL options (scope=buf,
--   global_local=false), so `vim.opt.shiftwidth = N` sets the CURRENT buffer's
--   value, not a global default. LazyVim's own options.lua does
--   `vim.opt.shiftwidth = 2` and runs AFTER config/options.lua (which is
--   sourced before lazy.nvim startup), so any value set there is clobbered.
--   LazyVim also re-applies sw=2 to buffers opened after startup.
--
-- Why vim.schedule:
--   FileType autocmds run in creation order; LazyVim's sw=2 handler is
--   registered before ours, so a plain callback would be overridden. Deferring
--   via vim.schedule runs our set after the synchronous FileType chain
--   (including LazyVim's) completes, so 4 wins.
--
-- Why also set vim.go (global default) on VimEnter + VeryLazy:
--   shiftwidth is scope=buf, so NEW buffers inherit vim.go.shiftwidth. LazyVim
--   sets vim.go to 2 at startup. Without resetting it to 4 AFTER LazyVim runs,
--   any buffer opened later (whose FileType event LazyVim's handler also sets
--   to 2) would get 2. VimEnter fires after LazyVim's options.lua (which runs
--   during lazy.setup, before VimEnter); VeryLazy fires later still. Both set
--   the global default to 4 and re-apply 4 to already-open buffers. (VeryLazy
--   does not fire in --headless mode, so VimEnter is what makes this testable
--   there; in real use both fire and are idempotent.)
local set_indent = function(bufnr)
  vim.bo[bufnr].shiftwidth = 4
  vim.bo[bufnr].tabstop = 4
  vim.bo[bufnr].softtabstop = 4
  vim.bo[bufnr].expandtab = true
end

-- Set the GLOBAL default too: shiftwidth is scope=buf, so new buffers inherit
-- vim.go.shiftwidth. LazyVim sets vim.go to 2; without this, any buffer opened
-- after startup would still get 2 even after the VeryLazy loop fixed the
-- already-open ones.
local set_global_indent = function()
  vim.go.shiftwidth = 4
  vim.go.tabstop = 4
  vim.go.softtabstop = 4
  vim.go.expandtab = true
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("indent_four_spaces", { clear = true }),
  pattern = "*",
  callback = function(event)
    vim.schedule(function() set_indent(event.buf) end)
  end,
})

-- BufReadPost: fires when a file is read into a buffer. FileType does NOT fire
-- in --headless for post-startup opens (and some plugins set filetype without
-- firing FileType), so this is the reliable backstop that also runs on every
-- file load in real sessions. Scheduled so it still wins over any synchronous
-- sw=2 set during the BufRead chain.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("indent_four_spaces_bufread", { clear = true }),
  callback = function(event)
    vim.schedule(function() set_indent(event.buf) end)
  end,
})

local apply_global_and_open_buffers = function()
  set_global_indent()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].filetype ~= "" then
      set_indent(b)
    end
  end
end

-- VimEnter: fires after LazyVim's options.lua, also in --headless. Sets the
-- global default to 4 and fixes any buffer opened at startup.
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("indent_four_spaces_vimenter", { clear = true }),
  once = true,
  callback = apply_global_and_open_buffers,
})

-- VeryLazy: fires later in real (interactive) sessions. Idempotent re-apply
-- in case anything reset values between VimEnter and VeryLazy.
vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("indent_four_spaces_verylazy", { clear = true }),
  pattern = "VeryLazy",
  once = true,
  callback = apply_global_and_open_buffers,
})
