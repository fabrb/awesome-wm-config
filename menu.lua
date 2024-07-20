local awful = require("awful")
local beautiful = require("beautiful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")
require("awful.autofocus")

local conf = require("config")

local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
	{ "hotkeys", function()
		hotkeys_popup.show_help(nil, awful.screen.focused())
	end },
	{ "manual",      conf.TERMINAL .. " -e man awesome" },
	{ "edit config", conf.EDITOR_CMD .. " " .. awesome.conffile },
	{ "restart",     awesome.restart },
	{ "quit", function()
		awesome.quit()
	end }
}

local menu_awesome = { "awesome", myawesomemenu }
local menu_terminal = { "open terminal", conf.TERMINAL }

if has_fdo then
    mymainmenu =
        freedesktop.menu.build(
            {
                before = {
                    menu_awesome,
                    {
                        "debian",
                        debian.menu.Debian_menu.Debian,
                    },
                },
                after = {
                    menu_terminal,
                }
            }
        )
else
    mymainmenu =
        awful.menu(
            {
                items = {
                    menu_awesome,
                    {
                        "debian",
                        debian.menu.Debian_menu.Debian,
                    },
                    menu_terminal
                }
            }
        )
end


mylauncher =
	awful.widget.launcher(
		{
			image = beautiful.awesome_icon,
			menu = mymainmenu,
			bg = beautiful.launcher_bg,
			fg = beautiful.launcher_fg,
			border_width = beautiful.launcher_border_width,
			border_color = beautiful.launcher_border_color,
		}
	)

-- Menubar configuration
menubar.utils.terminal = conf.TERMINAL -- Set the terminal for applications that require it
-- }}}

return {
	menubar
}