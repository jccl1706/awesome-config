local gears = require("gears")
local awful = require("awful")

local tag_move = {}

function tag_move.move_to_previous_tag()
	local c = client.focus
	if not c then
		return
	end
	local t = c.screen.selected_tag
	local tags = c.screen.tags
	local idx = t.index
	local newtag = tags[gears.math.cycle(#tags, idx - 1)]
	c:move_to_tag(newtag)
	awful.tag.viewprev()
end

function tag_move.move_to_next_tag()
	local c = client.focus
	if not c then
		return
	end
	local t = c.screen.selected_tag
	local tags = c.screen.tags
	local idx = t.index
	local newtag = tags[gears.math.cycle(#tags, idx + 1)]
	c:move_to_tag(newtag)
	awful.tag.viewnext()
end
-- }}}

-- {{{ function to move tag to a tag with clients and pass empty tags
function tag_move.view_next_tag_with_client()
	local initial_tag_index = awful.screen.focused().selected_tag.index
	while true do
		awful.tag.viewnext()
		local current_tag = awful.screen.focused().selected_tag
		local current_tag_index = current_tag.index
		if #current_tag:clients() > 0 or current_tag_index == initial_tag_index then
			return
		end
	end
end

function tag_move.view_prev_tag_with_client()
	local initial_tag_index = awful.screen.focused().selected_tag.index
	while true do
		awful.tag.viewprev()
		local current_tag = awful.screen.focused().selected_tag
		local current_tag_index = current_tag.index
		if #current_tag:clients() > 0 or current_tag_index == initial_tag_index then
			return
		end
	end
end
-- }}}

return tag_move

