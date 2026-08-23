-- Hyprland Lua config entry point.
-- Order matches the old hyprland.conf `source` order:
--   monitors.conf -> env.conf -> autostart.conf -> input.conf ->
--   looknfeel.conf -> windows.conf -> bindings.conf -> workspaces.conf
-- All modules live flat at the config root (alongside this file) and are
-- tracked in ~/dotfiles, symlinked here by migration 000322.
-- monitors.lua is machine-local (nwg-displays-generated), gitignored, and
-- required directly so it always resolves.
-- hyprlang and Lua do NOT coexist: while hyprland.conf exists, this file is
-- ignored. Activate by moving hyprland.conf aside (see plan/hyprland-lua-migration.md).

-- Use explicit relative paths with the .lua extension -- this is the form
-- proven by Hyprland's own hyprtester (require("./relative.lua")).
-- Bare module specs do not reliably resolve.
require("./monitors.lua")
require("./env.lua")
require("./autostart.lua")
require("./input.lua")
require("./looknfeel.lua")
require("./windows.lua")
require("./bindings.lua")
require("./workspaces.lua")
