-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable providers we don't use to silence health warnings
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Ported from omarchy-nvim: use neo-tree as the file explorer instead of the
-- LazyVim default (snacks_explorer). LazyVim makes the "explorer" default-extra
-- category mutually exclusive; setting this global forces neo-tree (checked
-- first in register_defaults, origin="global"), which auto-disables
-- snacks_explorer and imports the neo-tree extra. In neo-tree: `H` toggles
-- hidden files, `I` toggles git-ignored files.
vim.g.lazyvim_explorer = "neo-tree"

-- Ensure treesitter parser install dir is in runtimepath
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")