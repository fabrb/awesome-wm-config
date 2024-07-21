-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme/barbosa.lua")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local conf = require("config")

local bind = require("bindings")
require("errors")
require("signals.focus")
require("menu")

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.fair,
	-- awful.layout.suit.fair.horizontal,
	awful.layout.suit.floating,
	-- awful.layout.suit.tile,
	-- awful.layout.suit.tile.left,
	-- awful.layout.suit.tile.bottom,
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se
}
-- }}}

-- Keyboard map indicator and switcher
local mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
local mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons =
	gears.table.join(
		awful.button(
			{},
			1,
			function(t)
				t:view_only()
			end
		),
		awful.button(
			{ conf.MODKEY },
			1,
			function(t)
				if client.focus then
					client.focus:move_to_tag(t)
				end
			end
		),
		awful.button({}, 3, awful.tag.viewtoggle),
		awful.button(
			{ conf.MODKEY },
			3,
			function(t)
				if client.focus then
					client.focus:toggle_tag(t)
				end
			end
		),
		awful.button(
			{},
			4,
			function(t)
				awful.tag.viewnext(t.screen)
			end
		),
		awful.button(
			{},
			5,
			function(t)
				awful.tag.viewprev(t.screen)
			end
		)
	)

local tasklist_buttons =
	gears.table.join(
		awful.button(
			{},
			1,
			function(c)
				if c == client.focus then
					c.minimized = true
				else
					c:emit_signal("request::activate", "tasklist", { raise = true })
				end
			end
		),
		awful.button(
			{},
			3,
			function()
				awful.menu.client_list({ theme = { width = 250 } })
			end
		),
		awful.button(
			{},
			4,
			function()
				awful.client.focus.byidx(1)
			end
		),
		awful.button(
			{},
			5,
			function()
				awful.client.focus.byidx(-1)
			end
		)
	)

local function set_wallpaper(s)
	awful.spawn.with_shell("nitrogen --restore")
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(
	function(s)
		-- Each screen has its own tag table.
		awful.tag({ "1", "2", "3" }, s, awful.layout.layouts[1])

		-- Create a promptbox for each screen
		s.mypromptbox = awful.widget.prompt()

		-- Create an imagebox widget which will contain an icon indicating which layout we're using.
		-- We need one layoutbox per screen.
		s.mylayoutbox = awful.widget.layoutbox(s)
		s.mylayoutbox:buttons(
			gears.table.join(
				awful.button(
					{},
					1,
					function()
						awful.layout.inc(1)
					end
				),
				awful.button(
					{},
					3,
					function()
						awful.layout.inc(-1)
					end
				),
				awful.button(
					{},
					4,
					function()
						awful.layout.inc(1)
					end
				),
				awful.button(
					{},
					5,
					function()
						awful.layout.inc(-1)
					end
				)
			)
		)
		-- Create a taglist widget
		s.mytaglist =
			awful.widget.taglist {
				screen = s,
				filter = awful.widget.taglist.filter.all,
                buttons = taglist_buttons,
				
				style   = {
					shape_border_width = 1,
					shape_border_color = '#777777',
					shape              = gears.shape.rounded_bar,
				},
				layout  = {
					spacing        = 2,
					spacing_widget = {
						{
							widget       = wibox.widget.textbox
						},
						valign = 'center',
						halign = 'center',
						widget = wibox.container.place,
					},
					layout         = wibox.layout.flex.horizontal
				},

			}

		-- Create a tasklist widget
		s.mytasklist =
			awful.widget.tasklist {
				screen = s,
				filter = awful.widget.tasklist.filter.currenttags,
				buttons = tasklist_buttons,

				style   = {
					shape_border_width = beautiful.border_width,
					shape_border_color = beautiful.border_focus,
					shape              = gears.shape.rounded_bar,
				},
				layout  = {
					spacing        = 6,
					spacing_widget = {
						{
							widget       = wibox.widget.textbox
						},
						valign = 'center',
						halign = 'center',
						widget = wibox.container.place,
					},
					layout         = wibox.layout.flex.horizontal
				},
			}

		-- Create the wibox
		s.mywibox =
            awful.wibar {
				
				position = "top",
				screen = s,
				height = 38,
				ontop = false,
				stretch = false,
                width = 800,
				shape = function (cr, width, height)
					gears.shape.rounded_rect(cr, width, height, 32)
				end
            }
		
        s.datecalendar = awful.widget.calendar_popup.month {
            screen        		= awful.mouse.client.screen,
			margin 				= 8,
			long_weekdays 		= true,
			spacing 			= 10,
            week_numbers 		= true,
			start_sunday 		= true,
			style_header		= {
				border_width 	= 1,
				border_color 	= '#777777',
				shape              	= gears.shape.rounded_bar,
            },
			style_weeknumber 	= {
				border_width 		= 0,
			},
		}
		s.datecalendar:attach(mytextclock, "tc")

		-- Add widgets to the wibox
		s.mywibox:setup {
			{
				layout = wibox.layout.align.horizontal,
				{
					s.mylayoutbox,
					layout = wibox.layout.fixed.horizontal,
					s.mytaglist,
					s.mypromptbox
				},

				s.mytasklist,

				{
					layout = wibox.layout.fixed.horizontal,
					mykeyboardlayout,
					wibox.widget.systray(),
					mytextclock
				},
			},

			bottom = 10,
			top = 10,
			left = 6,
			right = 6,

			widget = wibox.container.margin
		}
	end
)
-- }}}



-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = bind.clientkeys,
			buttons = bind.clientbuttons,
			screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		}
    },
	
	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry"
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer"
			},
			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester" -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up" -- e.g. Google Chrome's (detached) Developer Tools.
			}
		},
		properties = { floating = true }
    },
	
	-- Add titlebars to normal clients and dialogs
	{
		rule_any = {
			type = { "normal", "dialog" }
		},
		properties = { titlebars_enabled = true }
	}
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal(
	"manage",
	function(c)
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- if not awesome.startup then awful.client.setslave(c) end

		if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
			-- Prevent clients from being unreachable after screen count changes.
			awful.placement.no_offscreen(c)
		end
	end
)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal(
	"request::titlebars",
	function(c)
		-- buttons for the titlebar
		local buttons = gears.table.join(
			awful.button(
				{},
				1,
				function()
					c:emit_signal("request::activate", "titlebar", { raise = true })
					awful.mouse.client.move(c)
				end
			),
			awful.button(
				{},
				3,
				function()
					c:emit_signal("request::activate", "titlebar", { raise = true })
					awful.mouse.client.resize(c)
				end
			)
		)

		awful.titlebar(c, { size = 30 }):setup {
			{
				{
					{
						-- Left
						awful.titlebar.widget.iconwidget(c),
						buttons = buttons,
						layout = wibox.layout.fixed.horizontal
					},
					margins = 4,
					widget = wibox.container.margin
				},

				{
					-- Middle
					{
						-- Title
						align = "center",
						widget = awful.titlebar.widget.titlewidget(c)
					},
					buttons = buttons,
					layout = wibox.layout.flex.horizontal
				},

				{
					{
						-- Right
						awful.titlebar.widget.floatingbutton(c),
						awful.titlebar.widget.maximizedbutton(c),
						awful.titlebar.widget.stickybutton(c),
						awful.titlebar.widget.ontopbutton(c),
						awful.titlebar.widget.closebutton(c),
						layout = wibox.layout.fixed.horizontal()
					},

					margins = 4,
					widget = wibox.container.margin
				},

				layout = wibox.layout.align.horizontal
            },
			
            bg = "#000000ff",
			shape = function(cr, width, height)
				gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 10)
			end,

			widget = wibox.container.background
		}
	end
)

-- }}}

-- Autostart Apps
-- awful.spawn.with_shell("compton")
awful.spawn.with_shell("nitrogen --restore")

-- Config monitors
awful.spawn.with_shell("xrandr --output HDMI-1 --primary  --left-of eDP-1")

-- Visual stuff
awful.spawn.with_shell("pkill compton; pkill xcompmgr; pkill picom; picom --config ~/.config/picom/picom.conf &")

