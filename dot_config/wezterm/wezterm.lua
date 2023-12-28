local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.window_decorations = 'RESIZE'
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.color_scheme = 'Catppuccin Frappe'

return config
