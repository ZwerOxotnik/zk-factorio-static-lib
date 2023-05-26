---@class ZWsurface
local M = {}


local source_left_top = {x = 0, y = 0}
local source_right_bottom = {x = 0, y = 0}
local destination_left_top = {x = 0, y = 0}
local destination_right_bottom = {x = 0, y = 0}
local clone_data = {
	source_area = {
		left_top = source_left_top,
		right_bottom = source_right_bottom
	},
	destination_area = {
		left_top = destination_left_top,
		right_bottom = destination_right_bottom
	},
	destination_force="neutral", clone_tiles=true, clone_entities=false,
	clone_decoratives=false, clear_destination_entities=false,
	clear_destination_decoratives=false, expand_map=false,
	create_build_effect_smoke=false
}


-- Initital x, y for left bottom corner which creates tiles to right top corner
---@param surface LuaSurface
---@param x number
---@param y number
---@param size integer
---@param tile_name string
M.fill_box_with_tiles = function(surface, x, y, size, tile_name)
	y = y - 1 -- Factorio offsets it
	local tiles = {
		{position = {x, y}, name = tile_name}
	}
	if size == 2 then
		tiles[2] = {position = {x, y - 1}, name = tile_name}
	elseif size == 3 then
		tiles[3] = {position = {x, y - 2}, name = tile_name}
	end
	surface.set_tiles(tiles, true, false, false)
	y = y + 1

	if size >= 4 then
		local step = 2
		source_left_top.x = x
		source_right_bottom.y = y
		source_right_bottom.x = x + 1
		destination_left_top.x = x
		destination_right_bottom.x = x + 1
		local max_step = size / 2
		while step <= max_step do
			source_left_top.y = y - step
			destination_left_top.y = y - step * 2
			destination_right_bottom.y = y - step
			surface.clone_area(clone_data)
			step = step * 2
		end

		local rest = size - step
		if rest > 0 then
			source_left_top.y = y - rest
			destination_left_top.y = y - step - rest
			destination_right_bottom.y = y - step
			surface.clone_area(clone_data)
		end
	end

	if size >= 2 then
		local step = 1
		source_left_top.x = x
		source_left_top.y = y - size
		destination_left_top.y = y - size
		source_right_bottom.y = y
		destination_right_bottom.y = y
		local max_step = size / 2
		while step <= max_step do
			source_right_bottom.x = x + step
			destination_left_top.x = x + step
			destination_right_bottom.x = x + step * 2
			surface.clone_area(clone_data)
			step = step * 2
		end

		local rest = size - step
		if rest > 0 then
			source_right_bottom.x = x + rest
			destination_left_top.x = x + step
			destination_right_bottom.x = x + step + rest
			surface.clone_area(clone_data)
		end
	end
end


return M
