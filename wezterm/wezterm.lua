-- nikitas_dotfiles managed config
-- Mirrors the Terminator setup so muscle memory carries over.
-- The marker comment on line 1 lets uninstall.sh know this file is ours
-- and safe to remove. Do not delete that line.

local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- Platform flag + the VSCode launcher used by the open-uri handler below.
-- On Windows the `code` command is a .cmd (not spawnable by
-- background_child_process), so we launch Code.exe directly. home_dir keeps
-- this user-agnostic; adjust if VSCode is installed outside the user profile.
local is_windows = wezterm.target_triple:find("windows") ~= nil
local vscode_exe = wezterm.home_dir .. "/AppData/Local/Programs/Microsoft VS Code/Code.exe"

-- No bell. Matches Terminator's icon_bell = False.
-- (wezterm never scrolls on output, so Terminator's scroll_on_output = False
--  needs no equivalent here.)
config.audible_bell = "Disabled"

-- JetBrainsMono Nerd Font (installed by setup/fonts.sh). The Nerd Font glyphs
-- render the eza icons and the git branch symbol in the prompt.
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 11.0

-- Tab titles as "N:name", where name is the active pane's folder (or its title
-- when there's no folder).
wezterm.on("format-tab-title", function(tab)
	local function basename(path)
		return (path:gsub("[/\\]+$", ""):gsub(".*[/\\]", ""))
	end
	local title = tab.tab_title
	if title == nil or #title == 0 then
		local cwd = tab.active_pane.current_working_dir
		if cwd ~= nil then
			title = basename(cwd.file_path or tostring(cwd))
		else
			title = tab.active_pane.title
		end
	end
	return string.format(" %d:%s ", tab.tab_index + 1, title)
end)

-- Open file:// links (the prompt's folder link and eza --hyperlink output) in
-- VSCode. Other links (http/https, e.g. the prompt's branch link) fall through
-- to default handling (browser). Ctrl+Click a link to open it.
wezterm.on("open-uri", function(_, _, uri)
	local path = uri:match("^file://[^/]*(/.*)$")
	if path then
		-- Percent-decode (eza encodes spaces etc. as %20).
		path = path:gsub("%%(%x%x)", function(h)
			return string.char(tonumber(h, 16))
		end)
		if is_windows then
			-- Git-Bash paths look like /c/Users/...; VSCode needs C:/Users/...
			path = path:gsub("^/(%a)/", function(d)
				return d:upper() .. ":/"
			end)
			wezterm.background_child_process({ vscode_exe, path })
		else
			-- No "--" here on purpose: VSCode's CLI re-injects the instance's launch
			-- flags (e.g. --ozone-platform=x11), and a "--" would turn that flag into
			-- a bogus filename. Paths from eza are absolute, so "--" isn't needed.
			wezterm.background_child_process({ "code", path })
		end
		return false -- handled; skip default
	end
end)

-- Open on the left half of the active screen (full height) by default, like a
-- Super+Left snap. Sized from the active screen's geometry at startup.
wezterm.on("gui-startup", function(cmd)
	local active = wezterm.gui.screens().active
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	local gui = window:gui_window()
	gui:set_position(active.x, active.y)
	gui:set_inner_size(active.width / 2, active.height)
end)

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

	-- Pane navigation: Alt+Arrow moves focus to the pane in that direction.
	{ key = "LeftArrow", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "ALT", action = act.ActivatePaneDirection("Down") },
}

-- Require Ctrl+Click to open links. By default wezterm opens a link on a plain
-- left click (its default Up binding is CompleteSelectionOrOpenLinkAtMouseCursor);
-- these bindings make a plain click only complete a selection, and move the
-- link-open onto Ctrl+Click.
config.mouse_bindings = {
	-- Plain left click: finish a selection, never open a link.
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
	},
	-- Ctrl + left click: open the link under the mouse.
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
	-- Suppress the selection that the Ctrl mouse-down would otherwise start.
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.Nop,
	},
}

-- Broadcast-to-all-panes (Terminator's Shift+Alt+B / Shift+Alt+O) has no native
-- wezterm equivalent and is intentionally omitted. Keep Terminator around if you
-- need that workflow.

return config
