local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.front_end = 'OpenGL'

config.window_decorations = 'RESIZE'
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.color_scheme = 'Gruvbox Material (Gogh)'

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

-- Neovim zen-mode support
-- https://github.com/folke/zen-mode.nvim#wezterm
wezterm.on('user-var-changed', function(window, pane, name, value)
  local overrides = window:get_config_overrides() or {}
  if name == "ZEN_MODE" then
    local incremental = value:find("+")
    local number_value = tonumber(value)
    if incremental ~= nil then
      while (number_value > 0) do
        window:perform_action(wezterm.action.IncreaseFontSize, pane)
        number_value = number_value - 1
      end
      overrides.enable_tab_bar = false
    elseif number_value < 0 then
      window:perform_action(wezterm.action.ResetFontSize, pane)
      overrides.font_size = nil
      overrides.enable_tab_bar = true
    else
      overrides.font_size = number_value
      overrides.enable_tab_bar = false
    end
  end
  window:set_config_overrides(overrides)
end)

return config
