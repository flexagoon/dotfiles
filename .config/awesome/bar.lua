--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--                              Wibox 
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--Libraries--------------------------------------------------------------
local wibox     = require("wibox")
local awful     = require("awful")
local gears     = require("gears")
local beautiful = require("beautiful")
local machi = require("layout-machi")
beautiful.layout_machi = machi.get_icon()
--Widgets----------------------------------------------------------------
local textclock = wibox.widget.textclock      ()
local keyboard  = awful.widget.keyboardlayout ()

local volume    = require("widgets.volume-widget.volume")
local battery   = require("widgets.battery-widget.battery")
local github    = require("widgets.batteryarc-widget.batteryarc")

local emotd     = require("widgets.emotd")
--Panel creation---------------------------------------------------------
awful.screen.connect_for_each_screen(function(s)
    s.taglist   = awful.widget.taglist {
        screen  = s,
	filter  = awful.widget.taglist.filter.all,
	buttons = gears.table.join(
                      awful.button({}, 1, function (t) t:view_only() end)
	          )
    }
    s.mylayoutbox = awful.widget.layoutbox(s)

    s.bar = awful.wibar({position = "top", screen = s})
    s.bar:setup {
        layout     = wibox.layout.align.horizontal,
	{
	    layout = wibox.layout.fixed.horizontal,
	    s.taglist
	},  nil,
	{
	    layout         = wibox.layout.fixed.horizontal,
	    spacing        = 20,
	    spacing_widget = {
		color      = "#3b4252",
		widget     = wibox.widget.separator
	    },
	    ---------------------------------------
	    -- github{
	    --     username = "flexagoon",
	    -- },
	    emotd(),
	    battery(),
	    volume({display_notification = true}),
	    keyboard,
            textclock,
	    s.mylayoutbox
	}
    }
end)
