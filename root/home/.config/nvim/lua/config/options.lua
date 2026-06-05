-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable providers we don't use to silence health warnings
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Make locally-installed npm packages discoverable by Node.js provider
vim.env.NODE_PATH = (vim.env.NODE_PATH or "") .. ":" .. vim.fn.expand("~/.local/lib/node_modules")

-- Point node provider to our local neovim-node-host
vim.g.node_host_prog = vim.fn.expand("~/.local/bin/neovim-node-host")

-- Ensure treesitter parser install dir is in runtimepath
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")