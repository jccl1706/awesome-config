local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")

-- {{{ Check if I am on my alta desktop monster pc.
local f = io.open("/home/jc/.myalta", "r")
if f ~= nil then
	io.close(f)
	myalta = true
end
-- }}}

local widgets = {}

-- {{{ Function to create a water temp widget
function widgets.create_wtemp_widget()
	local mywtemp = wibox.widget.textbox()

	local function updateWaterTempWidget()
		awful.spawn.easy_async("wtemp", function(stdout)
			mywtemp:set_markup(string.format('<span font="%s">%s</span>', beautiful.font, " " .. stdout))
		end)
	end

	-- Update the widget conditionally
	if myalta then
		awesome.connect_signal("startup", function()
			updateWaterTempWidget()
		end)

		local wtemp_timer = gears.timer({
			timeout = 3,
			autostart = true,
			call_now = true,
			callback = function()
				updateWaterTempWidget()
			end,
		})
	end
	return mywtemp
end
-- }}}

-- {{{ Function to create a water flow widget
function widgets.create_wflow_widget()
	local mywflow = wibox.widget.textbox()

	local function updateWaterFlowWidget()
		--awful.spawn.easy_async("wflow1", function(stdout)
		awful.spawn.easy_async_with_shell("wflow1", function(stdout, stderr, exitreason, exitcode)
			if exitcode == 0 then
				mywflow:set_markup(string.format('<span font="%s">%s</span>', beautiful.font, " " .. stdout))
			else
				mywflow:set_text("Error: " .. stderr)
			end
		end)
	end

	-- Update the widget conditionally
	if myalta then
		awesome.connect_signal("startup", function()
			updateWaterFlowWidget()
		end)

		local wflow_timer = gears.timer({
			timeout = 3,
			autostart = true,
			call_now = true,
			callback = function()
				updateWaterFlowWidget()
			end,
		})
	end
	return mywflow
end
--- }}}

-- {{{ Function to create cpu temp widget
function widgets.create_cputemp_widget()
	local mycputemp = wibox.widget.textbox()

	local function updateCpuTempWidget()
		awful.spawn.easy_async("cpu_temp", function(stdout)
			mycputemp:set_markup(string.format('<span font="%s">%s</span>', beautiful.font, " " .. stdout))
		end)
	end

	-- Update the widget conditionally
	if myalta then
		awesome.connect_signal("startup", function()
			updateCpuTempWidget()
		end)

		local cputemp_timer = gears.timer({
			timeout = 5,
			autostart = true,
			call_now = true,
			callback = function()
				updateCpuTempWidget()
			end,
		})
	end
	return mycputemp
end
-- }}}

return widgets
