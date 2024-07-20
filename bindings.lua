-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

local hotkeys_popup = require("awful.hotkeys_popup")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local conf = require("config")
local xrandr = require("xrandr")
local menu = require("menu")

-- {{{ Key bindings
local globalkeys =
	gears.table.join(
		awful.key({ conf.MODKEY }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
		awful.key({ conf.MODKEY }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
		awful.key({ conf.MODKEY }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
		awful.key({ conf.MODKEY }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),
		awful.key(
			{ conf.MODKEY },
			"j",
			function()
				awful.client.focus.byidx(1)
			end,
			{ description = "focus next by index", group = "client" }
		),
		awful.key(
			{ conf.MODKEY },
			"k",
			function()
				awful.client.focus.byidx(-1)
			end,
			{ description = "focus previous by index", group = "client" }
		),
		awful.key(
			{ conf.MODKEY },
			"w",
			function()
				mymainmenu:show()
			end,
			{ description = "show main menu", group = "awesome" }
		),
		-- Layout manipulation
		awful.key(
			{ conf.MODKEY, "Shift" },
			"j",
			function()
				awful.client.swap.byidx(1)
			end,
			{ description = "swap with next client by index", group = "client" }
		),
		awful.key(
			{ conf.MODKEY, "Shift" },
			"k",
			function()
				awful.client.swap.byidx(-1)
			end,
			{ description = "swap with previous client by index", group = "client" }
		),
		awful.key(
			{ conf.MODKEY, "Control" },
			"j",
			function()
				awful.screen.focus_relative(1)
			end,
			{ description = "focus the next screen", group = "screen" }
		),
		awful.key(
			{ conf.MODKEY, "Control" },
			"k",
			function()
				awful.screen.focus_relative(-1)
			end,
			{ description = "focus the previous screen", group = "screen" }
		),
		awful.key({ conf.MODKEY }, "u", awful.client.urgent.jumpto,
			{ description = "jump to urgent client", group = "client" }),
		awful.key(
			{ conf.MODKEY },
			"Tab",
			function()
				awful.client.focus.history.previous()
				if client.focus then
					client.focus:raise()
				end
			end,
			{ description = "go back", group = "client" }
		),
		-- Standard program
		awful.key(
			{ conf.MODKEY },
			"Return",
			function()
				awful.spawn(conf.TERMINAL)
			end,
			{ description = "open a terminal", group = "launcher" }
		),
		awful.key({ conf.MODKEY, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
		awful.key({ conf.MODKEY, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
		awful.key(
			{ conf.MODKEY },
			"l",
			function()
				awful.tag.incmwfact(0.05)
			end,
			{ description = "increase master width factor", group = "layout" }
		),
		awful.key(
			{ conf.MODKEY },
			"h",
			function()
				awful.tag.incmwfact(-0.05)
			end,
			{ description = "decrease master width factor", group = "layout" }
		),
		awful.key(
			{ conf.MODKEY, "Shift" },
			"h",
			function()
				awful.tag.incnmaster(1, nil, true)
			end,
			{ description = "increase the number of master clients", group = "layout" }
		),
		awful.key(
			{ conf.MODKEY, "Shift" },
			"l",
			function()
				awful.tag.incnmaster(-1, nil, true)
			end,
			{ description = "decrease the number of master clients", group = "layout" }
		),
		awful.key(
			{ conf.MODKEY, "Control" },
			"h",
			function()
				awful.tag.incncol(1, nil, true)
			end,
			{ description = "increase the number of columns", group = "layout" }
		),
		awful.key(
			{ conf.MODKEY, "Control" },
			"l",
			function()
				awful.tag.incncol(-1, nil, true)
			end,
			{ description = "decrease the number of columns", group = "layout" }
		),
		awful.key(
			{ conf.MODKEY },
			"space",
			function()
				awful.layout.inc(1)
			end,
			{ description = "select next", group = "layout" }
		),
		awful.key(
			{ conf.MODKEY, "Shift" },
			"space",
			function()
				awful.layout.inc(-1)
			end,
			{ description = "select previous", group = "layout" }
		),
		awful.key(
			{ conf.MODKEY, "Control" },
			"n",
			function()
				local c = awful.client.restore()
				-- Focus restored client
				if c then
					c:emit_signal("request::activate", "key.unminimize", { raise = true })
				end
			end,
			{ description = "restore minimized", group = "client" }
		),
		-- Prompt
		awful.key(
			{ conf.MODKEY },
			"r",
			function()
				awful.screen.focused().mypromptbox:run()
			end,
			{ description = "run prompt", group = "launcher" }
		),
		awful.key(
			{ conf.MODKEY },
			"x",
			function()
				awful.prompt.run {
					prompt = "Run Lua code: ",
					textbox = awful.screen.focused().mypromptbox.widget,
					exe_callback = awful.util.eval,
					history_path = awful.util.get_cache_dir() .. "/history_eval"
				}
			end,
			{ description = "lua execute prompt", group = "awesome" }
		),
		-- Menubar
		awful.key(
			{ conf.MODKEY },
			"p",
			function()
				menu.menubar.show()
			end,
			{ description = "show the menubar", group = "launcher" }
		),
		-- fabrb-keybindings
		awful.key(
			{ conf.MODKEY, "Shift" },
			"b",
			function()
				awful.util.spawn("firefox")
			end,
			{ description = "run firefox", group = "apps" }
		),
		awful.key(
			{ conf.MODKEY, "Shift" },
			"w",
			function()
				xrandr.xrandr()
			end,
			{ description = "change display settings", group = "apps" }
		),
		awful.key(
			{ conf.MODKEY, "Shift" },
			"s",
			function()
				awful.util.spawn("spotify")
			end,
			{ description = "run spotify", group = "apps" }
		),
		awful.key(
			{ conf.MODKEY, "Shift" },
			"d",
			function()
				awful.util.spawn("discord")
			end,
			{ description = "run discord", group = "apps" }
		),
		awful.key(
			{ conf.MODKEY, "Shift" },
			"m",
			function()
				awful.util.spawn("thunderbird")
			end,
			{ description = "run thunderbird", group = "apps" }
		),
		awful.key(
			{ conf.MODKEY, "Shift" },
			"k",
			function()
				awful.util.spawn("krita --nosplash --canvasonly")
			end,
			{ description = "run krita", group = "apps" }
		),

		awful.key(
			{ conf.MODKEY },
			"l",
			function()
				awful.util.spawn("bash lock.sh")
			end,
			{ description = "lock screen", group = "awesome" }
		),

		awful.key(
			{ conf.MODKEY, "Shift" },
			"g",
			function()
				awful.util.spawn("/home/fabrb/Documents/godot/godot-4.2.2.x86_64")
			end,
			{ description = "run godot engine", group = "apps" }
		)
	)

local clientkeys =
	gears.table.join(
		awful.key(
			{ conf.MODKEY },
			"f",
			function(c)
				c.fullscreen = not c.fullscreen
				c:raise()
			end,
			{ description = "toggle fullscreen", group = "client" }
		),
		awful.key(
			{ conf.MODKEY, "Shift" },
			"c",
			function(c)
				c:kill()
			end,
			{ description = "close", group = "client" }
		),
		awful.key(
			{ conf.MODKEY, "Control" },
			"space",
			awful.client.floating.toggle,
			{ description = "toggle floating", group = "client" }
		),
		awful.key(
			{ conf.MODKEY, "Control" },
			"Return",
			function(c)
				c:swap(awful.client.getmaster())
			end,
			{ description = "move to master", group = "client" }
		),
		awful.key(
			{ conf.MODKEY },
			"o",
			function(c)
				c:move_to_screen()
			end,
			{ description = "move to screen", group = "client" }
		),
		awful.key(
			{ conf.MODKEY },
			"t",
			function(c)
				c.ontop = not c.ontop
			end,
			{ description = "toggle keep on top", group = "client" }
		),
		awful.key(
			{ conf.MODKEY },
			"n",
			function(c)
				-- The client currently has the input focus, so it cannot be
				-- minimized, since minimized clients can't have the focus.
				c.minimized = true
			end,
			{ description = "minimize", group = "client" }
		),
		awful.key(
			{ conf.MODKEY },
			"m",
			function(c)
				c.maximized = not c.maximized
				c:raise()
			end,
			{ description = "(un)maximize", group = "client" }
		),
		awful.key(
			{ conf.MODKEY, "Control" },
			"m",
			function(c)
				c.maximized_vertical = not c.maximized_vertical
				c:raise()
			end,
			{ description = "(un)maximize vertically", group = "client" }
		),
		awful.key(
			{ conf.MODKEY, "Shift" },
			"m",
			function(c)
				c.maximized_horizontal = not c.maximized_horizontal
				c:raise()
			end,
			{ description = "(un)maximize horizontally", group = "client" }
		)
	)

local clientbuttons =
	gears.table.join(
		awful.button(
			{},
			1,
			function(c)
				c:emit_signal("request::activate", "mouse_click", { raise = true })
			end
		),
		awful.button(
			{ conf.MODKEY },
			1,
			function(c)
				c:emit_signal("request::activate", "mouse_click", { raise = true })
				awful.mouse.client.move(c)
			end
		),
		awful.button(
			{ conf.MODKEY },
			3,
			function(c)
				c:emit_signal("request::activate", "mouse_click", { raise = true })
				awful.mouse.client.resize(c)
			end
		)
	)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Mouse bindings
root.buttons(
	gears.table.join(
		awful.button(
			{},
			3,
			function()
				mymainmenu:toggle()
			end
		),
		awful.button({}, 4, awful.tag.viewnext),
		awful.button({}, 5, awful.tag.viewprev)
	)
)
-- }}}

return {
    clientbuttons,
    clientkeys,
	globalkeys
}
