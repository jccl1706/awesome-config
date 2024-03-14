local awful = require("awful")

local screen_move = {}

-- {{{
screen_move.move_client_to_screen = function(c, s)
	local function avoid_showing_empty_tag_client_move(c)
		local t = c.first_tag or awful.screen.focused().selected_tag
		for _, cl in ipairs(t:clients()) do
			if cl ~= c then
				return
			end
		end
		for _, tg in ipairs(awful.screen.focused().tags) do
			if tg ~= t and #tg:clients() > 0 then
				tg:view_only()
				break
			end
		end
	end

	avoid_showing_empty_tag_client_move(c)
	local index = c.first_tag.index
	c:move_to_screen(s)
	local tag = c.screen.tags[index]
	c:move_to_tag(tag)
	tag:view_only()
end
-- }}}

return screen_move

