pcall(require, "luarocks.loader")
require("awful.autofocus")
require("awful.hotkeys_popup.keys")
require("modules.autostart")

local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local dpi = require("beautiful.xresources").apply_dpi
local tag_move = require("modules.tag_move")
local screen_move = require("modules.screen_move")
local mywidgets = require("modules.widgets")
local autohide_wibar = require("modules.autohide_wibar")

local mywtemp = mywidgets.create_wtemp_widget()
local mywflow = mywidgets.create_wflow_widget()
local mycputemp = mywidgets.create_cputemp_widget()

-- {{{ Check if I am on my asus vivobook laptop.
local f = io.open("/home/jc/.myasus", "r")
if f ~= nil then
	io.close(f)
	myasus = true
end
-- }}}

-- {{{ Check if I am on my alta desktop monster pc.
local f = io.open("/home/jc/.myalta", "r")
if f ~= nil then
	io.close(f)
	myalta = true
end
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

-- {{{ Themes define colors, icons, font and wallpapers.
beautiful.init("/home/jc/.config/awesome/themes/zenburn/theme.lua")
-- }}}

-- {{{ This is used later as the default terminal and editor to run.
terminal = "wezterm"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor
-- }}}

-- {{{ Default modkey.
modkey = "Mod4"
altkey = "Mod1"
ctrlkey = "Control"
-- }}}

-- {{{ Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.spiral.dwindle,
	awful.layout.suit.fair,
	awful.layout.suit.max,
}
-- }}}

-- {{{ Create a launcher widget and a main menu
myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}
local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

-- -- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")
local mymainmenu = freedesktop.menu.build({ before = { menu_awesome }, after = { menu_terminal } })
local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- }}}

-- {{{ Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-----------------------------------------------------------------------------------------------------------
-- {{{ Create a textclock widget
local mytextclock = wibox.widget({
	{
		widget = wibox.widget.textclock,
		format = "%a %b %d, %H:%M",
		align = "center",
		valign = "center",
	},
	widget = wibox.container.background,
})
-- }}}
-----------------------------------------------------------------------------------------------------------

-- {{{ Actions for when I click on my taglist buttons
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({}, 3, awful.tag.viewtoggle)
)
-- }}}

-- {{{ Actions for when I click on my tasklist buttons
local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 400 } })
	end)
)
-- }}}

-- {{{ Create wallpapers function
local function set_wallpaper(s)
	if beautiful.wallpaper then
		local bcwallpaper

		if myasus then
			bcwallpaper = "/home/jc/.config/awesome/wall/debian_2-1920x1200.jpg"
		elseif myalta then
			bcwallpaper = "/home/jc/.config/awesome/wall/peaceful_place_2560x1440.jpg"
		end

		if myasus then
			gears.wallpaper.maximized(bcwallpaper)
		else
			gears.wallpaper.set(gears.surface(bcwallpaper))
		end
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)
-- }}}

awful.screen.connect_for_each_screen(function(s)
	local screen_width = s.geometry.width
	local wibar_width = math.floor(screen_width * 0.995) -- 75% of the screen width

	-- Wallpaper
	set_wallpaper(s)

	-- {{{ My tag name
	term = " 1 • terminal  "
	nave = " 2 • navegador  "
	expl = " 3 • explorador "
	util = " 4 • utilidades "
	virt = " 5 • virtualizar "
	-- }}}

	-- {{{ Set my tags for each screen with their own preferred layouts.
	awful.tag.add(term, { layout = awful.layout.suit.tile, screen = s, selected = true })
	awful.tag.add(nave, { layout = awful.layout.suit.max, screen = s })
	awful.tag.add(util, { layout = awful.layout.suit.floating, screen = s })
	awful.tag.add(virt, { layout = awful.layout.suit.floating, screen = s })
	-- }}}

	-- {{{ This machin has two screen, and different tag appear on different screens
	--	if myalta then
	--	if s.index == 1 then
	--	awful.tag.add(expl, { layout = awful.layout.suit.fair, screen = s })
	--	awful.tag.add(util, { layout = awful.layout.suit.floating, screen = s })
	--	awful.tag.add(virt, { layout = awful.layout.suit.floating, screen = s })
	--		elseif s.index == 2 then
	--			awful.tag.add(util, { layout = awful.layout.suit.floating, screen = s })
	--			awful.tag.add(virt, { layout = awful.layout.suit.floating, screen = s })
	--		end
	--end
	-- }}}

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end)
	))

	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		--filter  = awful.widget.taglist.filter.all,
		filter = awful.widget.taglist.filter.noempty,
		buttons = taglist_buttons,
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
	})

	-- {{{ Create my top wibar
	s.mytopbar = awful.wibar({
		position = "top",
		screen = s,
		height = 28,
		visible = true,
		ontop = false,
		opacity = 0.9,
		width = wibar_width,
	})

	-- Set the shape for the top wibar
	s.mytopbar.shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 6) -- Change 10 to your desired corner radius
	end

	-- Add widgets to the to wibox
	if s.index == 1 then
		s.mytopbar:setup({
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(5),
				s.mylayoutbox,
				--mylauncher,
				s.mytaglist,
				s.mypromptbox,
			},
			s.nill,
			--s.mytasklist, -- Middle widget
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(5),
				mycputemp,
				mywflow,
				mywtemp,
				mytextclock,
				wibox.widget.systray(),
			},
		})
	else
		s.mytopbar:setup({
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(5),
				s.mytaglist,
			},
			s.nill, -- Middle widget
			{ -- Right widget
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(5),
				s.mylayoutbox,
			},
		})
	end -- end of my topbar}}}
	if myalta then
		-- {{{ Create my bottom wibar
		s.mybottombar =
			awful.wibar({ position = "bottom", screen = s, height = 28, opacity = 0.9, width = wibar_width })

		-- Set the shape for the bottom wibar
		s.mybottombar.shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, 6) -- Set corner radius for the bottom bar
		end

		if s.index == 1 then
			-- Add widgets to the wibar
			s.mybottombar:setup({
				layout = wibox.layout.align.horizontal,
				{ -- Left widgets
					layout = wibox.layout.fixed.horizontal,
					mylauncher,
				},
				s.mytasklist, -- Middle widget
				{ -- Right widgets
					layout = wibox.layout.fixed.horizontal,
				},
			})
		else
			-- Add widgets to the wibar
			s.mybottombar:setup({
				layout = wibox.layout.align.horizontal,
				{ -- Left widgets
					layout = wibox.layout.fixed.horizontal,
				},
				s.mytasklist, -- Middle widget
				{ -- Right widgets
					layout = wibox.layout.fixed.horizontal,
				},
			})
		end
	end -- end of my bottombar }}}

	-- Now enable the auto-hide functionality
	autohide_wibar.enable(s)
end)

-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 3, function()
	mymainmenu:toggle()
end)))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(

	-- Awesome WM
	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	awful.key({ modkey }, "w", function()
		mymainmenu:show()
	end, { description = "show main menu", group = "awesome" }),
	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),

	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),

	-- Use "= and -" to increase and decrease the factor of the master
	awful.key({ modkey }, "=", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ modkey }, "-", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),

	-- Use "l" for layout
	awful.key({ modkey, "Control" }, "l", function()
		awful.layout.inc(1)
	end, { description = "select next layout", group = "layout" }),

	-- Prompt
	awful.key({ modkey }, "r", function()
		awful.screen.focused().mypromptbox:run()
	end, { description = "run prompt", group = "launcher" }),

	-- Menubar
	awful.key({ modkey }, "p", function()
		menubar.show()
	end, { description = "show the menubar", group = "launcher" }),

	-- Standard program
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open a terminal", group = "launcher" })
)

clientkeys = gears.table.join(

	-- Use "f" for fullsreen
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),

	awful.key({ modkey }, "c", function(c)
		c:kill()
	end, { description = "close", group = "client" }),

	awful.key(
		{ modkey, "Control" },
		"space",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),

	awful.key(
		{ modkey },
		"[",
		tag_move.move_to_previous_tag,
		{ description = "move client to the previous tag", group = "tag" }
	),
	awful.key(
		{ modkey },
		"]",
		tag_move.move_to_next_tag,
		{ description = "move client to the next tag", group = "tag" }
	),

	-- Horizontal Vim navigation keys to go left and right on tags.
	awful.key({ modkey }, "Left", function()
		tag_move.view_prev_tag_with_client()
	end, { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "Right", function()
		tag_move.view_next_tag_with_client()
	end, { description = "view next tag with client on it", group = "tag" }),

	-- Move client to screen
	awful.key({ modkey, "Shift" }, "Left", function(c)
		screen_move.move_client_to_screen(c, c.screen.index - 1)
	end, { description = "move client one screen left", group = "client" }),
	awful.key({ modkey, "Shift" }, "Right", function(c)
		screen_move.move_client_to_screen(c, c.screen.index + 1)
	end, { description = "move client one screen right", group = "client" }),

	-- Set client ontop
	awful.key({ modkey }, "t", function(c)
		c.ontop = not c.ontop
	end, { description = "toggle keep on top", group = "client" }),

	-- Minimize & restore the client
	awful.key({ modkey }, "n", function(c)
		c.minimized = true
	end, { description = "minimize", group = "client" }),
	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),

	-- Maximize & restore the client
	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "(un)maximize", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end),
		--{description = "view tag #"..i, group = "tag"}),

		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end),
		--{description = "toggle tag #" .. i, group = "tag"}),

		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end),
		--{description = "move focused client to tag #"..i, group = "tag"}),

		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end)
		--{description = "toggle focused client on tag #" .. i, group = "tag"})
	)
end

clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Use: xprop | grep -i 'class'
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
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			size_hints_honor = false,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			class = { "Arandr", "Gpick", "Nm-connection-editor" },
			-- xev
			name = { "Event Tester" },
		},
		properties = { floating = true },
	},

	{ rule = { class = "Firefox" }, properties = { screen = 1, tag = nave } },

	-- Rules for my laptop and desktop computers.
	(myalta and {
		rule = { class = "Pavucontrol" },
		properties = { floating = true, screen = 1, tag = util },
		callback = function(c)
			awful.placement.centered(c, nil)
		end,
	} or (myasus and {
		rule = { class = "Pavucontrol" },
		properties = { floating = true, screen = 1, tag = util },
		callback = function(c)
			awful.placement.centered(c, nil)
		end,
	} or nil)),

	{
		rule = { class = "Code" },
		properties = { floating = true },
		callback = function(c)
			awful.placement.centered(c, nil)
		end,
	},

	(myalta and {
		rule = { class = "Virt-manager" },
		properties = { floating = true, switchtotag = true, tag = virt },
		callback = function(c)
			awful.placement.centered(c, nil)
		end,
	} or nil),

	-- Add titlebars to normal clients and dialogs if I am on the myalta pc
	(myalta and {
		rule_any = { type = { "normal", "dialog" } },
		properties = { titlebars_enabled = true },
	} or nil),
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- {{{ Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	-- {{{ Create a left titlebar
	awful.titlebar(c, { position = "left", size = 38 }):setup({
		{
			{ -- Left
				awful.titlebar.widget.closebutton(c),
				--awful.titlebar.widget.minimizebutton (c),
				awful.titlebar.widget.ontopbutton(c),
				spacing = dpi(10),
				layout = wibox.layout.fixed.vertical,
			},
			margins = dpi(10),
			widget = wibox.container.margin,
		},
		{ -- Right
			layout = wibox.layout.fixed.vertical(),
		},
		nil,
		layout = wibox.layout.align.vertical,
	})
end)
-- }}}

-- {{{ Function to create rounded borders
if myalta then
	local function set_rounded_corners(c)
		-- Adjust the radius based on your preference
		local radius = 9
		c.shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, radius)
		end
	end

	-- Connect the function to the "manage" signal
	client.connect_signal("manage", function(c)
		set_rounded_corners(c)
	end)
end
-- }}}

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

--- Enable for lower memory consumption
collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
-- }}}
