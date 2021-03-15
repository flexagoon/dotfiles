--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--                           Tag binds
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--Libraries and variables------------------------------------------------
local awful = require("awful")
local vars = require("vars")
local modkey = vars.modkey
--Bind all key numbers to tags-------------------------------------------
for i = 1, 5 do
  local descr_view, descr_toggle, descr_move, descr_toggle_focus
  if i == 1 or i == 5 then
    descr_view = {description = 'view tag #', group = 'tag'}
    descr_toggle = {description = 'toggle tag #', group = 'tag'}
    descr_move = {description = 'move focused client to tag #', group = 'tag'}
    descr_toggle_focus = {description = 'toggle focused client on tag #', group = 'tag'}
  end
  keybinds =
    awful.util.table.join(
      keybinds,
      -- View tag only.
      awful.key(
        {modkey},
        '#' .. i + 9,
        function()
          local screen = awful.screen.focused()
          local tag = screen.tags[i]
          if tag then
            tag:view_only()
          end
        end,
        descr_view
      ),
      -- Toggle tag display.
      awful.key(
        {modkey, 'Control'},
        '#' .. i + 9,
        function()
          local screen = awful.screen.focused()
          local tag = screen.tags[i]
          if tag then
            awful.tag.viewtoggle(tag)
          end
        end,
        descr_toggle
      ),
      -- Move client to tag.
      awful.key(
        {modkey, 'Shift'},
        '#' .. i + 9,
        function()
          if _G.client.focus then
            local tag = _G.client.focus.screen.tags[i]
            if tag then
              _G.client.focus:move_to_tag(tag)
            end
          end
        end,
        descr_move
      ),
      -- Toggle tag on focused client.
      awful.key(
        {modkey, 'Control', 'Shift'},
        '#' .. i + 9,
        function()
          if _G.client.focus then
            local tag = _G.client.focus.screen.tags[i]
            if tag then
              _G.client.focus:toggle_tag(tag)
            end
          end
        end,
        descr_toggle_focus
      )
    )
end

return keybinds
