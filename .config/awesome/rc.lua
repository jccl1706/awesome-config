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

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

-- Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/home/jc/.config/awesome/themes/default/theme.lua")

-- Set default terminal
--terminal = "alacritty"
terminal = "zutty"

editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkeys.
modkey = "Mod4"
altkey = "Mod1"
ctrlkey = "Control"

-- Table of layouts to cover with awful.layout.inc, order matters.
local l = awful.layout.suit
awful.layout.layouts = {
   	l.floating,
    	l.tile,
    	l.spiral.dwindle,
    	l.fair,
    	l.max,
}

-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")
mymainmenu = freedesktop.menu.build({ before = { menu_awesome }, after = { menu_terminal } })
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set terminal for applications that require it

-- Keyboard map indicator and switcher
local mykeyboardlayout = awful.widget.keyboardlayout()

---------------------------------------------------------------- test -----------------------------------------

-- Create a widget for water temp
local mywtemp = wibox.widget.textbox()

-- Function to update the widget's text
local function updateWaterTempWidget()
    awful.spawn.easy_async("coolantemp", function(stdout)
        mywtemp:set_markup(string.format('<span font="%s">%s</span>', "DejaVuSans 12", " " .. stdout))
    end)
end

-- Update the widget when Awesome WM starts
awesome.connect_signal("startup", function()
    if myalta then
        updateWaterTempWidget()
    end
end)

---------------------------------------------------------------- test -----------------------------------------

-- Create a textclock widget
local mytextclock = wibox.widget({
    {
     widget = wibox.widget.textclock,
     format = "%a %b %d, %H:%M",
     font = "DejaVuSans 12",
     --widget = wibox.widget.textclock( '<span color="#FFFFFF" font="sans bold 12"> %a %d, %H:%M </span>', 15 )
    },
    fg = tasklist_fg_normal,
    bg = beautiful.tasklist_bg_focus,
    widget = wibox.container.background
})

-- Create a tooltip for the clock time
local myclock_t = awful.tooltip {
    objects        = { mytextclock },
    timer_function = function()
        return os.date("Today is %A %B %d %Y\nThe time is %T")
    end,
}

-- Create a widget separator for wibar
local myvertsep = wibox.widget({
    {
    widget = wibox.widget.separator,
    orientation = "vertical",
    forced_width = 15,
    color = beautiful.tasklist_bg_focus,
    },
    bg = beautiful.tasklist_bg_focus,
    widget = wibox.container.background
})

-- Actions for when I click on my taglist buttons
local taglist_buttons = gears.table.join(
        awful.button({ }, 1, function(t) t:view_only() end),
        awful.button({ }, 3, awful.tag.viewtoggle)
)

-- Actions for when I click on my tasklist buttons
local tasklist_buttons = gears.table.join(
        awful.button({ }, 1, function (c)
               if c == client.focus then
                       c.minimized = true
               else
                       c:emit_signal(
                       "request::activate",
                       "tasklist",
                       {raise = true}
                       )
               end
       end),
        awful.button({ }, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end)
)

-- Check if I am on my asus vivobook laptop.
local f=io.open("/home/jc/.myasus","r")
if f~=nil then
	io.close(f)
	myasus = true
end

-- Check if I am on my alta desktop monster pc.
local f=io.open("/home/jc/.myalta","r")
if f~=nil then
	io.close(f)
	myalta = true
end

local function set_wallpaper(s)
    if beautiful.wallpaper then
        bcwallpaper = "/home/jc/Downloads/background.jpg"
	 if myasus then
	      gears.wallpaper.maximized(bcwallpaper)
	 else
	      gears.wallpaper.set(gears.surface(bcwallpaper))
	 end
     end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

-- My tag name
term=  " 1 • terminal  "
nave=  " 2 • navegador  "
expl=  " 3 • explorador "
util=  " 4 • utilidades "
virt=  " 5 • virtualizar "

    -- Set my tags for each screen with their own preferred layouts.
	awful.tag.add(term, { layout = l.tile, screen = s, selected = true, })
	awful.tag.add(nave, { layout = l.max, screen = s, })

    -- These two machines have three screens, and different tags appear on different screens.
    if myalta then
	    if s.index == 1 then
		awful.tag.add(expl, { layout = l.fair, screen = s, })
	    elseif s.index == 2 then
		awful.tag.add(util, { layout = l.tile, screen = s, })
	    else
		awful.tag.add(virt, { layout = l.fair, screen = s, })
	    end
	    -- If these are put together with awful.tag then both vari and term are selected on start for some reason.
	    awful.tag.add(vari, { layout = l.tile, screen = s, })
	   awful.tag.add(virt, { layout = l.tile, screen = s, })
    end

    -- Create a promptbox for each screen
    --s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end)))
    
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
	-- There is no point in showing an empty tag.
        filter  = awful.widget.taglist.filter.noempty,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 28 })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widget
	    layout = wibox.layout.fixed.horizontal,
        s.mylayoutbox,
	    s.mytaglist,
        },
        s.mytasklist, -- Middle widget
	--s.nill,
	{ -- Right widget 
	    layout = wibox.layout.fixed.horizontal,
            --mykeyboardlayout,
	    mywtemp,
	    myvertsep,
        mytextclock,
	    myvertsep,
        wibox.widget.systray(),
        },
    }
end)

-- Mouse binding when I click on an empty screen
root.buttons(gears.table.join(awful.button({ }, 3, function () mymainmenu:toggle() end)))

-- These two functions are for moving the current client to the next/previous tag and following view to that tag.
local function move_to_previous_tag()
	local c = client.focus
	if not c then return end
	local t = c.screen.selected_tag
	local tags = c.screen.tags
	local idx = t.index
	local newtag = tags[gears.math.cycle(#tags, idx - 1)]
	c:move_to_tag(newtag)
	awful.tag.viewprev()
end
local function move_to_next_tag()
	local c = client.focus
	if not c then return end
	local t = c.screen.selected_tag
	local tags = c.screen.tags
	local idx = t.index
	local newtag = tags[gears.math.cycle(#tags, idx + 1)]
	c:move_to_tag(newtag)
	awful.tag.viewnext()
end

-- There is no reason to navigate next or previous in my tag list and have to pass by empty tags in route to the next tag with a client. The following two functions bypass the empty tags when navigating to next or previous.
function view_next_tag_with_client()
	local initial_tag_index = awful.screen.focused().selected_tag.index
	while (true) do
		awful.tag.viewnext()
		local current_tag = awful.screen.focused().selected_tag
		local current_tag_index = current_tag.index
		if #current_tag:clients() > 0 or current_tag_index == initial_tag_index then
			return
		end
	end
end
function view_prev_tag_with_client()
	local initial_tag_index = awful.screen.focused().selected_tag.index
	while (true) do
		awful.tag.viewprev()
		local current_tag = awful.screen.focused().selected_tag
		local current_tag_index = current_tag.index
		if #current_tag:clients() > 0 or current_tag_index == initial_tag_index then
			return
		end
	end
end

-- Toggle showing the desktop
local show_desktop = false
function show_my_desktop()
	if show_desktop then
		for _, c in ipairs(client.get()) do
			c:emit_signal(
				"request::activate", "key.unminimize", {raise = true}
			)
		end
		show_desktop = false
	else
		for _, c in ipairs(client.get()) do
			c.minimized = true
		end
		show_desktop = true
	end
end

-- Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey }, "s", hotkeys_popup.show_help,
              {description="show help", group="awesome"}),

    -- Horizontal Vim navegation keys to go left and right on tags.
    awful.key({ modkey }, "Left", function() view_prev_tag_with_client() end,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey }, "Right", function() view_next_tag_with_client() end,
              {description = "view next", group = "tag"}),
    
    -- I use "Left" and "Right" to go to the next client or next in reverse.
    awful.key({ ctrlkey }, "Right",function () awful.client.focus.byidx( 1) end,
              {description = "focus next by index", group = "client"}),
    awful.key({ ctrlkey }, "Left", function () awful.client.focus.byidx(-1) end,
              {description = "focus previous by index", group = "client"}),

    --  Vertical "Left" and "Right" navegation keys to swap client.
    awful.key({ modkey, ctrlkey }, "Right", function () awful.client.swap.byidx(  1) end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, ctrlkey }, "Left", function () awful.client.swap.byidx( -1) end,
              {description = "swap with previous client by index", group = "client"}),
    
    -- Horizontal Vim navegation keys to go left and right a screen.
    awful.key({ modkey }, "h", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey }, "l", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),

    -- Horizontal Vim navigation keys to move the client to the next or previous tag and follow there.
    awful.key({ modkey, altkey }, "Left", function (c) move_to_previous_tag() end,
	      {description = "move client to previous tag", group = "tag"}),
    awful.key({ modkey, altkey }, "Right", function (c) move_to_next_tag() end,
	      {description = "move cliet to next tag", group = "tag"}),
   
    -- Restart and Quit Awesome.
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    -- Increase "i" client width or "increase" in reverse. 
    awful.key({ altkey }, "i", function () awful.tag.incmwfact( 0.05) end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey, altkey }, "i", function () awful.tag.incmwfact(-0.05) end,
              {description = "decrease master width factor", group = "layout"}),

    -- Use "l" for layout 
    awful.key({ modkey, "Control" }, "l", function () awful.layout.inc( 1) end,
              {description = "select next layout", group = "layout"}),

    -- Show my Desktop. call my function above
    awful.key({ altkey, "Control" }, "d", function(c) show_my_desktop() end,
	      {description = "toggle showing the desktop", group = "client"}),

    -- Minimize and un-minimize clients.
    awful.key({ modkey }, "n",
            function () if client.focus then client.focus.minimized = true end end,
	    {description = "minimize", group = "client"}),
    awful.key({ modkey, "Control" }, "n",
            function ()
                     local c = awful.client.restore()
                     -- Focus restored client
                     if c then
                             c:emit_signal(
                                      "request::activate", "key.unminimize", {raise = true}
                             )
                     end
            end,
            {description = "restore minimized", group = "client"}),

-- Launchers
    -- Terminal
    awful.key({ modkey }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    
    -- Prompt
    --awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
    --          {description = "run prompt", group = "launcher"}),

    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

-- If I close the last client on a given tag, it will automatically switch to a tag that has a client. That is, there is no reason to stay on a tag that is empty.
client.connect_signal("unmanage", function(c)
	local t = c.first_tag or awful.screen.focused().selected_tag
	for _, cl in ipairs(t:clients()) do
		if cl ~= c then
			return
		end
	end
	for _, t in ipairs(awful.screen.focused().tags) do
		if #t:clients() > 0 then
			t:view_only()
			return
		end
	end
end)

move_client_to_screen = function(c, s)
	function avoid_showing_empty_tag_client_move(c)
		-- Get the current tag.
		local t = c.first_tag or awful.screen.focused().selected_tag
		-- Cycle through all clients on the current tag. If there are 2 or greater clients on the current tag then leave function.
		for _, cl in ipairs(t:clients()) do
			if cl ~= c then
				return
			end
		end
		-- This step is only run if there is one client on the current tag.
		-- Cycle through all tags on the current screen. We must skip the current tag. We then move to the lowest index tag with one or more clients on it.
		for _, tg in ipairs(awful.screen.focused().tags) do
			if tg ~= t then
				if #tg:clients() > 0 then
					tg:view_only()
					break
				end
			end
		end
	end
	avoid_showing_empty_tag_client_move(c)
	-- Move to new screen but also keep it on the same tag index.
	local index = c.first_tag.index
	c:move_to_screen(s)
	local tag = c.screen.tags[index]
	c:move_to_tag(tag)
	tag:view_only()
end

clientkeys = gears.table.join(
        awful.key({ modkey }, "c", function (c) c:kill() end,
                {description = "close", group = "client"}),

	awful.key({ modkey, "Shift" }, "Left", function (c) move_client_to_screen(c, c.screen.index-1) end,
	        {description = "move client one screen left", group = "client"}),
	
	awful.key({ modkey, "Shift" }, "Right", function (c) move_client_to_screen(c, c.screen.index+1) end,
                {description = "move client one screen right", group = "client"}),

        awful.key({ modkey }, "f", awful.client.floating.toggle,
                {description = "toggle floating", group = "client"}),

	awful.key({ modkey }, "t", function (c) c.ontop = not c.ontop end,
	        {description = "toggle keep on top", group = "client"}),

	awful.key({ modkey }, "m",
		function (c)
			c.maximized = not c.maximized
			c:raise()
		end,
	{description = "(un)maximize", group = "client"})

)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    	awful.button({ }, 1, function (c)
        	c:emit_signal("request::activate", "mouse_click", {raise = true})
    	end),
    	awful.button({ modkey }, 1, function (c)
        	c:emit_signal("request::activate", "mouse_click", {raise = true})
        	awful.mouse.client.move(c)
    	end),
    	awful.button({ modkey }, 3, function (c)
        	c:emit_signal("request::activate", "mouse_click", {raise = true})
        	awful.mouse.client.resize(c)
    	end)
)

-- Set keys
root.keys(globalkeys)

-- Use: xprop | grep -i 'class'
-- Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      	     properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
		             size_hints_honor = false,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
             class = { "Arandr", "Gpick", "Nm-connection-editor" },
             -- xev  
	     name = { "Event Tester" }, }, properties = { floating = true }},

    {rule = { class = "Firefox" },
    properties = { screen = 1, tag = nave } },

    (myalta and {
        rule = { class = "Pavucontrol" },
        properties = { floating = true, screen = 2, tag = util }, 
        callback = function (c)
            awful.placement.centered(c, nil)
        end
    } or
    (myasus and {
        rule = { class = "Pavucontrol" },
        properties = { floating = true, screen = 1, tag = util },
        callback = function (c)
            awful.placement.centered(c, nil)
        end
    } or nil)),

    --{rule = { class = "Pavucontrol" },
    --properties = { floating = true }, 
    --	callback = function (c)
	--    awful.placement.centered(c, nil)
    --	end
    --},

    {
        rule = { class = "Virt-manager" },
        properties = { floating = true, screen = 2, tag = virt }, 
    	callback = function (c)
	        awful.placement.centered(c, nil)
    	end
    },

    -- Add titlebars to normal clients and dialogs if I am on the myalta pc
    (myalta and {
         rule_any = {type = { "normal", "dialog" }},
        properties = { titlebars_enabled = true } 
    } or nil),
    
}

-- Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            --awful.titlebar.widget.iconwidget(c),
            awful.titlebar.widget.closebutton    (c),
	    --buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
		font   = "Intervariable Bold 12",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
             layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Autostart Applications
awful.spawn.with_shell("~/.config/awesome/autorun.sh")

-- }}}
