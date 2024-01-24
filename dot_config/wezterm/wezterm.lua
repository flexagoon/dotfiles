local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.window_decorations = 'RESIZE'
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.color_scheme = 'Catppuccin Frappe'

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
