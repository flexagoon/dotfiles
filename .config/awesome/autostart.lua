--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--                           Autostart
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--Libraries--------------------------------------------------------------
local awful = require("awful")
--Run function-----------------------------------------------------------
local function run_once(cmd)
    local findme = cmd
    local firstspace = cmd:find(' ')
    if firstspace then findme = cmd:sub(0, firstspace - 1) end
    awful.spawn.easy_async_with_shell(string.format(
                                          'pgrep -u $USER -x %s > /dev/null || (%s)',
                                          findme, cmd))
end
--Autostart apps---------------------------------------------------------
autostart_apps = {
    "~/.config/awesome/keyboard",
    "picom",
    "keynav"
}

for app = 1, #autostart_apps do run_once(autostart_apps[app]) end
