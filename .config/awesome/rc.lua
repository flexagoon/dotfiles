--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--                           rc.lua
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--Libraries--------------------------------------------------------------
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local bling = require("bling")
local machi = require("layout-machi")

require("awful.autofocus")

local vars = require("vars")
--Theme------------------------------------------------------------------
local theme_file = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), vars.theme_name)
beautiful.init(theme_file)
--Layouts----------------------------------------------------------------
local layout = machi.layout.create({
    name = "test",
    default_cmd = "w44"
})

awful.layout.layouts = {
    awful.layout.suit.spiral.dwindle,
    machi.default_layout,
    awful.layout.suit.tile,
    awful.layout.suit.fair,
    awful.layout.suit.floating
}
--Screen init------------------------------------------------------------
awful.screen.connect_for_each_screen(function(s)
    awful.tag({"1", "2", "3", "4", "5"}, s, awful.layout.layouts[1])
    gears.wallpaper.maximized(beautiful.wallpaper, s)
end)
require("bar")
--Keybinds---------------------------------------------------------------
_G.root.keys(require("keys.keys"))
--Rules------------------------------------------------------------------
awful.rules.rules = {
    {
        rule = {},
	properties = { 
	    border_width = beautiful.border_width,
	    border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }, callback = awful.client.setslave
    }
}
--Signals----------------------------------------------------------------
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
--Bling------------------------------------------------------------------
bling.module.window_swallowing.start()
--Autostart--------------------------------------------------------------
require("autostart")
