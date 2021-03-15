--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--                           Keybinds
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--Libraries and variables------------------------------------------------
local gears = require("gears")
local awful = require("awful")
local vars = require("vars")
local machi = require("layout-machi")
local menubar = require("menubar")
local modkey = vars.modkey
--Global keys------------------------------------------------------------
keybinds = gears.table.join(
    awful.key({modkey         }, "w",      function () awful.spawn(vars.edit_cmd .. " " .. awesome.conffile) end,
              {description = "edit config", group = "awesome"}),
    awful.key({modkey, "Shift"}, "r",      awesome.restart,
              {description = "restart awesome", group = "awesome"}),
	      
    awful.key({modkey           }, "d",           function () menubar.show()                          end,
              {description = "app launcher",    group = "apps"}),
    awful.key({modkey           }, "Return",      function () awful.spawn(vars.terminal)              end,
              {description = "open terminal",   group = "apps"}),
    awful.key({modkey           }, "b",           function () awful.spawn(vars.browser)               end,
              {description = "launch browser",  group = "apps"}),
    awful.key({modkey           }, "t",           function () awful.spawn("kotatogram-desktop")       end,
              {description = "launch telegram", group = "apps"}),
    awful.key({modkey           }, "m",           function () awful.spawn("emacs")                    end,
              {description = "launch emacs",    group = "apps"}),

    awful.key({modkey           }, "h",       function () awful.client.focus.bydirection("left")  end,
              {description = "focus left",  group = "windows"}),
    awful.key({modkey           }, "j",       function () awful.client.focus.bydirection("down")  end,
              {description = "focus down",  group = "windows"}),
    awful.key({modkey           }, "k",       function () awful.client.focus.bydirection("up")    end,
              {description = "focus up",    group = "windows"}),
    awful.key({modkey           }, "l",       function () awful.client.focus.bydirection("right") end,
              {description = "focus right", group = "windows"}),

    awful.key({modkey, "Shift"  }, "h",      function () awful.client.swap.bydirection("left")  end,
              {description = "swap left", group = "windows"}),
    awful.key({modkey, "Shift"  }, "j",      function () awful.client.swap.bydirection("down")  end,
              {description = "swap down", group = "windows"}),
    awful.key({modkey, "Shift"  }, "k",      function () awful.client.swap.bydirection("up")    end,
              {description = "swap up", group = "windows"}),
    awful.key({modkey, "Shift"  }, "l",      function () awful.client.swap.bydirection("right") end,
              {description = "swap right", group = "windows"}),

--  awful.key({modkey, "Control"}, "j",      function () awful.client.swap.bydirection("down")  end,
--            {description = "swap down", group = "windows"}),
--  awful.key({modkey, "Control"}, "k",      function () awful.client.swap.bydirection("up")    end,
--            {description = "swap up", group = "windows"}),
	      
    awful.key({modkey          }, "space", function () awful.layout.inc( 1)                end,
              {description = "next layout", group = "layout"}),
    awful.key({modkey, "Shift" }, "space", function () awful.layout.inc(-1)                end,
              {description = "previous layout", group = "layout"}),

    awful.key({modkey          }, "/",     function () machi.default_editor.start_interactive() end,
              {desctiption = "edit machi layout", group = "layout"}),
    awful.key({modkey          }, ".",     function () machi.switcher.start()                   end,
              {description = "move machi windows", group = "layout"})
)

require("keys.tags")

-- Layout Machi
-- awful.keyboard.append_global_keybindings(
--     {
--         awful.key({modkey}, "/", function() machi.default_editor.start_interactive() end, {
--             description = "edit the current layout if it is a machi layout",
--             group = "layout"
--         }),
--         awful.key({modkey}, "e", function() machi.switcher.start() end, {
--             description = "switch between windows for a machi layout",
--             group = "layout"
--         })
--     })
--Client keys------------------------------------------------------------
clientkeys = gears.table.join(
    awful.key({modkey,  "Shift"}, "q",      function (c) c:kill() end,
              {description = "close", group = "windows"}),

    awful.key({modkey,         }, "f",
        function (c)
	    c.fullscreen = not c.fullscreen
	    c:raise()
	end,
        {description = "toggle fullscreen", group = "windows"})
)
--Set global keys--------------------------------------------------------
return keybinds
