-- module/autohide_wibar.lua
local gears = require("gears")
local wibox = require("wibox")

local autohide_wibar = {}

function autohide_wibar.enable(s)
	-- Assuming s.mytopbar has been previously defined and is the wibar you want to control

	local hide_timer = gears.timer({ timeout = 3 })
	hide_timer:connect_signal("timeout", function()
		s.mytopbar.visible = false
	end)

	local detector = wibox({
		screen = s,
		x = s.geometry.x,
		y = s.geometry.y,
		width = s.geometry.width,
		height = 1,
		visible = true,
		ontop = true,
	})
	detector.opacity = 0
	detector:connect_signal("mouse::enter", function()
		s.mytopbar.visible = true
		hide_timer:stop()
	end)
	detector:connect_signal("mouse::leave", function()
		if not s.mytopbar.visible then
			hide_timer:start()
		end
	end)

	s.mytopbar:connect_signal("mouse::enter", function()
		hide_timer:stop()
		s.mytopbar.visible = true
	end)
	s.mytopbar:connect_signal("mouse::leave", function()
		hide_timer:stop()
		hide_timer:start()
	end)
end

return autohide_wibar

