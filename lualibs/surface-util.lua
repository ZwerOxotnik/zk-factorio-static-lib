---@class ZOsurface
local M = {}


local tile_source_left_top = {x = 0, y = 0}
local tile_source_right_bottom = {x = 0, y = 0}
local tile_destination_left_top = {x = 0, y = 0}
local tile_destination_right_bottom = {x = 0, y = 0}
local clone_tile_data = {
	source_area = {
		left_top = tile_source_left_top,
		right_bottom = tile_source_right_bottom
	},
	destination_area = {
		left_top = tile_destination_left_top,
		right_bottom = tile_destination_right_bottom
	},
	destination_force="neutral", clone_tiles=true, clone_entities=false,
	clone_decoratives=false, clear_destination_entities=false,
	clear_destination_decoratives=false, expand_map=false,
	create_build_effect_smoke=false
}
local resource_position = {0, 0}
---@type LuaSurface.create_entity_param
local resource_data = {name="", amount=4294967295, snap_to_tile_center=true, position=resource_position}


-- Initital x, y for left bottom corner which creates tiles to right top corner
-- This function clones area
---@param surface LuaSurface
---@param x number
---@param y number
---@param size integer
---@param tile_name string
M.fill_horizontal_line_with_tiles = function(surface, x, y, size, tile_name)
	y = y - 1 -- Factorio offsets it
	local tiles = {
		{position = {x, y}, name = tile_name}
	}
	if size >= 2 then
		tiles[2] = {position = {x, y - 1}, name = tile_name}
	end
	if size == 3 then
		tiles[3] = {position = {x, y - 2}, name = tile_name}
	end
	surface.set_tiles(tiles, true, false, false)
	y = y + 1

	if size >= 4 then
		local step = 2
		tile_source_left_top.x = x
		tile_source_right_bottom.y = y
		tile_source_right_bottom.x = x + 1
		tile_destination_left_top.x = x
		tile_destination_right_bottom.x = x + 1
		local max_step = size / 2
		while step <= max_step do
			tile_source_left_top.y = y - step
			tile_destination_left_top.y = y - step * 2
			tile_destination_right_bottom.y = y - step
			surface.clone_area(clone_tile_data)
			step = step * 2
		end

		local rest = size - step
		if rest > 0 then
			tile_source_left_top.y = y - rest
			tile_destination_left_top.y = y - step - rest
			tile_destination_right_bottom.y = y - step
			surface.clone_area(clone_tile_data)
		end
	end
end


-- Initital x, y for left bottom corner which creates tiles to right top corner
-- This function clones area
---@param surface LuaSurface
---@param x number
---@param y number
---@param size integer
---@param tile_name string
M.fill_box_with_tiles = function(surface, x, y, size, tile_name)
	M.fill_horizontal_line_with_tiles(surface, x, y, size, tile_name)

	if size >= 2 then
		local step = 1
		tile_source_left_top.x = x
		tile_source_left_top.y = y - size
		tile_destination_left_top.y = y - size
		tile_source_right_bottom.y = y
		tile_destination_right_bottom.y = y
		local max_step = size / 2
		while step <= max_step do
			tile_source_right_bottom.x = x + step
			tile_destination_left_top.x = x + step
			tile_destination_right_bottom.x = x + step * 2
			surface.clone_area(clone_tile_data)
			step = step * 2
		end

		local rest = size - step
		if rest > 0 then
			tile_source_right_bottom.x = x + rest
			tile_destination_left_top.x = x + step
			tile_destination_right_bottom.x = x + step + rest
			surface.clone_area(clone_tile_data)
		end
	end
end


-- Initital x, y for left bottom corner which creates tiles to right top corner
---@param surface LuaSurface
---@param x number
---@param y number
---@param size integer
---@param tile_name string
M.fill_box_with_tiles_safely = function(surface, x, y, size, tile_name)
	local c = 0
	local tiles = {}
	y = y - 1
	for x2 = x, x + size - 1 do
		for y2 = y - size + 1, y do
			c = c + 1
			tiles[c] = {position = {x2, y2}, name = tile_name}
			if c > 1024 then
				surface.set_tiles(tiles, true, false, false)
				tiles = {}
				c = 0
			end
		end
	end
	surface.set_tiles(tiles, true, false, false)
end


-- Initital x, y for left bottom corner which creates resources to right top corner
-- This function clones area
---@param surface LuaSurface
---@param x number
---@param y number
---@param size integer
---@param resource_name string
---@param amount uint
---@param clone_area_param LuaSurface.clone_area_param #source_area and destination_area will be overwritten
M.fill_box_with_resources = function(surface, x, y, size, resource_name, amount, clone_area_param)
	if amount == nil then
		error("amount is nil")
	end

	local resource_source_left_top = {x = 0, y = 0}
	local resource_source_right_bottom = {x = 0, y = 0}
	local resource_destination_left_top = {x = 0, y = 0}
	local resource_destination_right_bottom = {x = 0, y = 0}
	clone_area_param.source_area = {
		left_top = resource_source_left_top,
		right_bottom = resource_source_right_bottom
	}
	clone_area_param.destination_area = {
		left_top = resource_destination_left_top,
		right_bottom = resource_destination_right_bottom
	}

	local create_entity = surface.create_entity
	resource_data.amount = amount
	resource_data.name = resource_name

	y = y - 1 -- Factorio offsets it

	resource_position[1] = x
	resource_position[2] = y
	create_entity(resource_data)
	if size >= 2 then
		resource_position[1] = x
		resource_position[2] = y - 1
		create_entity(resource_data)
	end
	if size == 3 then
		resource_position[1] = x
		resource_position[2] = y - 2
		create_entity(resource_data)
	end
	y = y + 1

	if size >= 4 then
		local step = 2
		resource_source_left_top.x = x
		resource_source_right_bottom.y = y
		resource_source_right_bottom.x = x + 1
		resource_destination_left_top.x = x
		resource_destination_right_bottom.x = x + 1
		local max_step = size / 2
		while step <= max_step do
			resource_source_left_top.y = y - step
			resource_destination_left_top.y = y - step * 2
			resource_destination_right_bottom.y = y - step
			surface.clone_area(clone_area_param)
			step = step * 2
		end

		local rest = size - step
		if rest > 0 then
			resource_source_left_top.y = y - rest
			resource_destination_left_top.y = y - step - rest
			resource_destination_right_bottom.y = y - step
			surface.clone_area(clone_area_param)
		end
	end

	if size >= 2 then
		local step = 1
		resource_source_left_top.x = x
		resource_source_left_top.y = y - size
		resource_destination_left_top.y = y - size
		resource_source_right_bottom.y = y
		resource_destination_right_bottom.y = y
		local max_step = size / 2
		while step <= max_step do
			resource_source_right_bottom.x = x + step
			resource_destination_left_top.x = x + step
			resource_destination_right_bottom.x = x + step * 2
			surface.clone_area(clone_area_param)
			step = step * 2
		end

		local rest = size - step
		if rest > 0 then
			resource_source_right_bottom.x = x + rest
			resource_destination_left_top.x = x + step
			resource_destination_right_bottom.x = x + step + rest
			surface.clone_area(clone_area_param)
		end
	end
end


-- Initital x, y for left bottom corner which creates tiles to right top corner
---@param surface LuaSurface
---@param x number
---@param y number
---@param size integer
---@param tile_name string
---@param amount uint
M.fill_box_with_resources_safely = function(surface, x, y, size, tile_name, amount)
	if tile_name == nil then
		error("tile_name is nil")
	end
	if amount == nil then
		error("amount is nil")
	end

	y = y - 1
	local create_entity = surface.create_entity
	resource_data.amount = amount
	resource_data.name = tile_name
	for x2 = x, x + size - 1 do
		for y2 = y - size + 1, y do
			resource_position[1] = x2
			resource_position[2] = y2
			create_entity(resource_data)
		end
	end
end

return M
