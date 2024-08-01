---@class ZOplayer_util
local player_util = {build = 10}


--[[
player_util.get_new_resource_position_by_player_resource(player, resource): MapPosition?
player_util.get_resource_position_for_player(player): MapPosition?
player_util.teleport_safely(player, surface, target_position): boolean
player_util.delete_character(player)
player_util.create_new_character(player, character_name?)
player_util.teleport_players(players=game.players, surface, position): boolean
player_util.teleport_players_safely(players=game.players, surface, position): boolean
player_util.print_to_players(players=game.players, message, color?): boolean
player_util.emulate_message_to_server(player, message, is_log?)
player_util.delete_gui_for_players(players=game.players, source_gui_name, gui_name)
player_util.find_closest_player_to_position(players=game.connected_players, position): LuaPlayer?, uint?
player_util.find_players_in_radius(players=game.connected_players, position, radius): LuaPlayer[]
player_util.is_there_player_in_radius(players=game.connected_players, position, radius): boolean
player_util.has_all_items(player, item_requests): boolean
player_util.has_all_items(player, item_requests, is_return_rest_by_missing_items): boolean, rest_items?
TODO: player_util.get_all_items(player, item_requests): ItemStack[]
TODO: player_util.get_all_items(player, item_requests, is_return_rest_by_missing_items): ItemStack[], rest_items?
player_util.has_any_item(player, item_requests): boolean
TODO: player_util.get_any_item(player, item_requests): item
]]


---@param player LuaPlayer
---@param resource LuaEntity
---@return MapPosition?
function player_util.get_new_resource_position_by_player_resource(player, resource)
	local resource_reach_distance = player.resource_reach_distance
	if resource_reach_distance > 40 then
		resource_reach_distance = 40
	end

	local settings = {position = player.position, radius = resource_reach_distance, name = resource.name, limit = 2}
	local resources = player.surface.find_entities_filtered(settings)
	for i=1, #resources do
		local new_resource = resources[i]
		if resource ~= new_resource then
			return new_resource.position
		end
	end
end


---@param player LuaPlayer
---@return MapPosition?
function player_util.get_resource_position_for_player(player)
	local resource_reach_distance = player.resource_reach_distance
	if resource_reach_distance > 40 then
		resource_reach_distance = 40
	end

	local settings = {position = player.position, radius = resource_reach_distance, type = "resource", limit = 1}
	local new_resource = player.surface.find_entities_filtered(settings)[1]
	if new_resource then
        return new_resource.position
	end
end


---@param player LuaPlayer
---@param surface LuaSurface?
---@param target_position? MapPosition
---@return boolean
function player_util.teleport_safely(player, surface, target_position)
	if not (player and player.valid) then
		return false
	end
	if surface then
		if not surface.valid then
			return false
		end
	else
		surface = player.surface
	end
	if target_position == nil then
		return false
	end

	local character = player.character
	if not (character and character.valid) then
		-- Perhaps, its should beginning changed
		player.teleport(target_position, surface)
		return true
	end

	local target
	local is_vehicle = false
	local vehicle = player.vehicle
	local target_name
	if vehicle and vehicle.valid and not vehicle.train and vehicle.get_driver() == character and vehicle.get_passenger() == nil then
		target = vehicle
		target_name = vehicle.name
		is_vehicle = true
	else
		target = player
		target_name = character.name
	end
	local radius = 200
	local non_colliding_position = surface.find_non_colliding_position(target_name, target_position, radius, 5)

	if not non_colliding_position then
		-- TODO: add localization
		player.print("It's not possible to teleport you because there's not enough space for your character")
		return false
	end

	if is_vehicle then
		if vehicle.type == "spider-vehicle" then
			target.stop_spider()
		else
			target.speed = 0
		end
	end
	target.teleport(non_colliding_position, surface)
	return true
end


---@param player LuaPlayer
function player_util.delete_character(player)
	local character = player.character
	if character and character.valid then
		character.destroy({raise_destroy=true})
	end
end

---@param player LuaPlayer
---@param character_name string? # "character" by default
function player_util.create_new_character(player, character_name)
	--TODO: improve
	character_name = character_name or "character"

	-- Delete old character
	player_util.delete_character(player)

	-- Create new character (perhaps, it should be improved)
	character = player.surface.create_entity{
		name=character_name, force = player.force, position = player.position
	}
	player.set_controller({
		type = defines.controllers.character,
		character = character
	})
	player.spectator = false
end


---@param players table<any, LuaPlayer> | LuaCustomTable<any, LuaPlayer>? # game.players by default
---@param surface LuaSurface
---@param position MapPosition
---@return boolean
function player_util.teleport_players(players, surface, position)
	players = players or game.players
	if position == nil then
		return false
	end
	if not (surface and surface.valid) then
		return false
	end

	for _, player in pairs(players) do
		if not player.valid then
			goto continue
		end
		local target = player
		local character = player.character
		if character and character.valid then
			local vehicle = character.vehicle
			if vehicle and vehicle.valid and not vehicle.train
				and vehicle.get_driver() == character
				and vehicle.get_passenger() == nil
			then
				target = vehicle
			end
		end
		target.teleport(position, surface)
		:: continue ::
	end
	return true
end


---@param players table<any, LuaPlayer> | LuaCustomTable<any, LuaPlayer>? # game.players by default
---@param surface LuaSurface
---@param position MapPosition
---@return boolean
function player_util.teleport_players_safely(players, surface, position)
	players = players or game.players
	if position == nil then
		return false
	end
	if not (surface and surface.valid) then
		return false
	end

	for _, player in pairs(players) do
		if player.valid then
			player_util.teleport_safely(player, surface, position)
		end
	end
	return true
end


---@param players table<any, LuaPlayer> | LuaCustomTable<any, LuaPlayer>? # game.players by default
---@param message table|string
---@param color table?
---@return boolean
function player_util.print_to_players(players, message, color)
	players = players or game.players
	if message == nil then
		return false
	end

	for _, player in pairs(players) do
		if player.valid then
			player.print(message, color)
		end
	end
	return true
end


---@param player LuaPlayer
---@param message string
---@param is_log boolean?
---@param is_tag_include boolean? # true by default
---@return string?
function player_util.emulate_message_to_server(player, message, is_log, is_tag_include)
	if type(message) ~= "string" then return end

	if is_tag_include == nil then
		is_tag_include = true
	end

	local _message
	local tag = player.tag
	if is_tag_include and tag and tag ~= "" then
		_message = "0000-00-00 00:00:00 [CHAT] " .. player.name .. " " .. player.tag .. ": " .. _message
	else
		_message = "0000-00-00 00:00:00 [CHAT] " .. player.name .. ": " .. _message
	end

	if is_log then
		log("\r\n" .. _message)
	else
		print(_message)
	end

	return _message
end


---@param players table<any, LuaPlayer> | LuaCustomTable<any, LuaPlayer>? # game.players by default
---@param source_gui_name string
---@param gui_name string
function player_util.delete_gui_for_players(players, source_gui_name, gui_name)
	players = players or game.players
	for _, player in pairs(players) do
		if player.valid then
			local prev_gui = player.gui[source_gui_name]
			if prev_gui and prev_gui.valid then
				local gui = prev_gui[gui_name]
				if gui and gui.valid then
					gui.destroy()
				end
			end
		end
	end
end


---@param players table<any, LuaPlayer> | LuaCustomTable<any, LuaPlayer>? # game.connected_players by default
---@param position MapPosition
---@return LuaPlayer?, uint? # player, distance
function player_util.find_closest_player_to_position(players, position)
	players = players or game.connected_players
	local min_distance
	local closest_player
	for _, player in pairs(players) do
		if player.valid then
			local pos = player.position
			local stop_x = position.x or position[1]
			local stop_y = position.y or position[2]
			local xdiff = pos.x - stop_x
			local ydiff = pos.y - stop_y
			local distance = (xdiff * xdiff + ydiff * ydiff)^0.5
			if min_distance == nil or min_distance < distance then
				min_distance = distance --[[@as uint]]
				closest_player = player
			end
		end
	end
	return closest_player, min_distance
end


---@param players table<any, LuaPlayer> | LuaCustomTable<any, LuaPlayer>?? # game.connected_players by default
---@param position MapPosition
---@return LuaPlayer[]
function player_util.find_players_in_radius(players, position, radius)
	players = players or game.connected_players
	local players_in_radius = {}
	for _, player in pairs(players) do
		if player.valid then
			local pos = player.position
			local stop_x = position.x or position[1]
			local stop_y = position.y or position[2]
			local xdiff = pos.x - stop_x
			local ydiff = pos.y - stop_y
			local distance = (xdiff * xdiff + ydiff * ydiff)^0.5
			if distance <= radius then
				players_in_radius[#players_in_radius+1] = player
			end
		end
	end
	return players_in_radius
end


---@param players table<any, LuaPlayer> | LuaCustomTable<any, LuaPlayer>? # game.connected_players by default
---@param position MapPosition
---@return boolean
function player_util.is_there_player_in_radius(players, position, radius)
	players = players or game.connected_players
	for _, player in pairs(players) do
		if player.valid then
			local pos = player.position
			local stop_x = position.x or position[1]
			local stop_y = position.y or position[2]
			local xdiff = pos.x - stop_x
			local ydiff = pos.y - stop_y
			local distance = (xdiff * xdiff + ydiff * ydiff)^0.5
			if distance <= radius then
				return true
			end
		end
	end
	return false
end


---@param player LuaPlayer
---@param item_requests table<string, uint> | SimpleItemStack[] | ItemStackDefinition[]
---@param is_return_rest_by_missing_items nil # false then return items that found
---@return boolean
---@overload fun(player: LuaPlayer,  item_requests: table<string, uint> | SimpleItemStack[] | ItemStackDefinition[], is_return_missing_items: boolean): boolean, table<string, uint>?
function player_util.has_all_items(player, item_requests, is_return_rest_by_missing_items)
	local get_item_count = player.get_item_count

	if #item_requests <= 0 then
		---@cast item_requests table<string, uint>
		if is_return_rest_by_missing_items == nil then
			for item_name, need_count in pairs(item_requests) do
				local current_count = get_item_count(item_name)
				if current_count <= need_count then
					return false
				end
			end

			return true
		elseif is_return_rest_by_missing_items then
			local has_missing_items = false
			local missing_items
			for item_name, existing_count in pairs(item_requests) do
				local current_count = get_item_count(item_name)
				if current_count <= existing_count then
					missing_items = missing_items or {}
					missing_items[item_name] = existing_count - current_count
				end
			end

			return has_missing_items, missing_items
		else
			local has_found_items = false
			local found_items
			for item_name, existing_count in pairs(item_requests) do
				local current_count = get_item_count(item_name)
				if current_count > existing_count then
					found_items = found_items or {}
					found_items[item_name] = current_count
				end
			end

			return has_found_items, found_items
		end
	end


	---@cast item_requests SimpleItemStack[] | ItemStackDefinition[]
	if is_return_rest_by_missing_items == nil then
		for _, item in pairs(item_requests) do
			local current_count = get_item_count(item.name)
			if current_count <= (item.count or 1) then
				return false
			end
		end

		return true
	elseif is_return_rest_by_missing_items then
		local has_missing_items = false
		local missing_items
		for _, item in pairs(item_requests) do
			local need_count = (item.count or 1)
			local name = item.name
			local existing_count = get_item_count(name)
			if existing_count <= need_count then
				missing_items = missing_items or {}
				missing_items[name] = need_count - existing_count
			end
		end

		return has_missing_items, missing_items
	else
		local has_found_items = false
		local found_items
		for _, item in pairs(item_requests) do
			local need_count = (item.count or 1)
			local name = item.name
			local current_count = get_item_count(name)
			if current_count > need_count then
				found_items = found_items or {}
				found_items[name] = current_count
			end
		end

		return has_found_items, found_items
	end
end


---@param player LuaPlayer
---@param item_requests table<string, uint> | SimpleItemStack[] | ItemStackDefinition[]
---@return boolean
function player_util.has_any_item(player, item_requests)
	local get_item_count = player.get_item_count


	if #item_requests <= 0 then
		---@cast item_requests table<string, uint>
		for item_name, need_count in pairs(item_requests) do
			local current_count = get_item_count(item_name)
			if current_count >= need_count then
				return true
			end
		end

		return false
	end

	---@cast item_requests SimpleItemStack[] | ItemStackDefinition[]
	for _, item in pairs(item_requests) do
		local current_count = get_item_count(item.name)
		if current_count >= (item.count or 1) then
			return true
		end
	end

	return false
end


return player_util
