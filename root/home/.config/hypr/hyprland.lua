-- Hyprland Lua config entry point.
-- Order matches the old hyprland.conf `source` order:
--   monitors.conf -> env.conf -> autostart.conf -> input.conf ->
--   looknfeel.conf -> windows.conf -> bindings.conf -> workspaces.conf
-- monitors.lua is machine-local (nwg-displays-generated) and lives at the
-- config root (not under lua/), so it is required directly. The lua/ modules
-- are tracked in ~/dotfiles and symlinked here by migration 000322.
-- hyprlang and Lua do NOT coexist: while hyprland.conf exists, this file is
-- ignored. Activate by moving hyprland.conf aside (see plan/hyprland-lua-migration.md).

-- Use explicit relative paths with the .lua extension -- this is the form
-- proven by Hyprland's own hyprtester (require("./lua-require/relative.lua")).
-- Bare module specs like "lua/env" do not reliably resolve.
require("./monitors.lua")
require("./lua/env.lua")
require("./lua/autostart.lua")
require("./lua/input.lua")
require("./lua/looknfeel.lua")
require("./lua/windows.lua")
require("./lua/bindings.lua")
require("./lua/workspaces.lua")
