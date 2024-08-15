local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.window_decorations = 'RESIZE'
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

config.color_scheme = 'Kanagawa (Gogh)'
config.font = wezterm.font('SauceCodePro NFM', { weight = 'Medium' })
config.font_size = 13

config.keys = {
	-- Alt+Enter is used for a line break in many REPLs
	{
		key = 'Enter',
		mods = 'ALT',
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		key = 'j',
		mods = 'SUPER',
		action = wezterm.action.SpawnCommandInNewTab {
			args = { 'fish', '-c', 'julia' },
		},
	},

	-- Better split keybinds
	{
		key = 's',
		mods = 'ALT|SHIFT',
		action = wezterm.action.SplitHorizontal {}
	},
	{
		key = 'h', -- Wezterm's "vertical split" is actually horizontal
		mods = 'ALT|SHIFT',
		action = wezterm.action.SplitVertical {}
	},
	{
		key = 'RightArrow',
		mods = 'ALT|SHIFT',
		action = wezterm.action.ActivatePaneDirection 'Right',
	},
	{
		key = 'i',
		mods = 'ALT|SHIFT',
		action = wezterm.action.ActivatePaneDirection 'Right',
	},
	{
		key = 'LeftArrow',
		mods = 'ALT|SHIFT',
		action = wezterm.action.ActivatePaneDirection 'Left',
	},
	{
		key = 'm',
		mods = 'ALT|SHIFT',
		action = wezterm.action.ActivatePaneDirection 'Left',
	},
	{
		key = 'DownArrow',
		mods = 'ALT|SHIFT',
		action = wezterm.action.ActivatePaneDirection 'Down',
	},
	{
		key = 'n',
		mods = 'ALT|SHIFT',
		action = wezterm.action.ActivatePaneDirection 'Down',
	},
	{
		key = 'UpArrow',
		mods = 'ALT|SHIFT',
		action = wezterm.action.ActivatePaneDirection 'Up',
	},
	{
		key = 'e',
		mods = 'ALT|SHIFT',
		action = wezterm.action.ActivatePaneDirection 'Up',
	},
}

-- ALT + number to activate tab
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = 'ALT',
		action = wezterm.action.ActivateTab(i - 1),
	})
end

return config
