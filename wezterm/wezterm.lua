-- nikitas_dotfiles managed config
-- Mirrors the Terminator setup so muscle memory carries over.
-- The marker comment on line 1 lets uninstall.sh know this file is ours
-- and safe to remove. Do not delete that line.

local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- No bell. Matches Terminator's icon_bell = False.
-- (wezterm never scrolls on output, so Terminator's scroll_on_output = False
--  needs no equivalent here.)
config.audible_bell = "Disabled"

config.keys = {
	-- Zoom: Ctrl+= / Ctrl+- , with Ctrl+0 to reset (Terminator zoom_in/zoom_out).
	{ key = "=", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },

	-- Splits. Note: Terminator and wezterm name split directions oppositely.
	-- Terminator split_horiz (Alt+Shift+-) makes a top/bottom split  -> SplitVertical.
	-- Terminator split_vert  (Alt+Shift++) makes a left/right split  -> SplitHorizontal.
	-- Matched on the physical key position (phys:) rather than the character.
	-- Holding ALT changes the composed character wezterm would otherwise see, so
	-- character matching ("_"/"+") silently fails under ALT; physical position does not.
	{ key = "phys:Minus", mods = "ALT|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "phys:Equal", mods = "ALT|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
}

-- Broadcast-to-all-panes (Terminator's Shift+Alt+B / Shift+Alt+O) has no native
-- wezterm equivalent and is intentionally omitted. Keep Terminator around if you
-- need that workflow.

return config
