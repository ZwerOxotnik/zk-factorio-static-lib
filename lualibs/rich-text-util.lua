---@class ZOrichtext
local richtext_util = {build = 1}


--[[
richtext_util.find_gui(text): start: integer?, end: number?, image_name: string?, is_valid_image: boolean?
richtext_util.find_item(text): start: integer?, end: number?, item_name: string?, LuaItemPrototype?
richtext_util.find_technology(text): start: integer?, end: number?, technology_name: string?, LuaTechnologyPrototype?
richtext_util.find_recipe(text): start: integer?, end: number?, recipe_name: string?, LuaRecipePrototype?
richtext_util.find_item_group(text): start: integer?, end: number?, item_group_name: string?, LuaGroup?
richtext_util.find_fluid(text): start: integer?, end: number?, fluid_name: string?, LuaFluidPrototype?
richtext_util.find_tile(text): start: integer?, end: number?, tile_name: string?, LuaTilePrototype?
richtext_util.find_virtual_signal(text): start: integer?, end: number?, signal_name: string?, LuaVirtualSignalPrototype?
richtext_util.find_achievement(text): start: integer?, end: number?, achievement_name: string, LuaAchievementPrototype?
richtext_util.find_gps(text): start: integer?, end: number?, x: number?, y: number?, surface_name: string?, is_valid: boolean
richtext_util.find_special_item(text): start: integer?, end: integer?, blueprint: string?
richtext_util.find_armor(text): start: integer?, end: integer?, player_name: string?, LuaPlayer?
richtext_util.find_train(text): start: integer?, end: integer?, train: integer?, LuaTrain?
richtext_util.find_train_stop(text): start: integer?, end: integer?, train_stop: integer?
richtext_util.find_tooltip(text): start: integer?, end: integer?, text: string?, locale_key: string?
richtext_util.find_font(text): start: integer?, end: integer?, LuaFontPrototype?
richtext_util.find_color(text): start: integer?, end: integer?, r: integer?, g: integer?, b: integer?, a: integer?
]]


---@param text string
---@return integer?, integer?, string?, boolean?
function richtext_util.find_gui(text)
	local start, _end, image_name = text:find("%[img=(.+)%]")
	if image_name and game and game.is_valid_sprite_path then
		return start, _end, image_name, game.is_valid_sprite_path(image_name)
	else
		return start, _end, image_name
	end
end


---@param text string
---@return integer?, integer?, string?, LuaItemPrototype?
function richtext_util.find_item(text)
	local start, _end, item_name = text:find("%[item=(.+)%]")
	if item_name and game and game.item_prototypes then
		return start, _end, item_name, game.item_prototypes[item_name]
	else
		return start, _end, item_name
	end
end


---@param text string
---@return integer?, integer?, string?, LuaTechnologyPrototype?
function richtext_util.find_technology(text)
	local start, _end, technology_name = text:find("%[technology=(.+)%]")
	if technology_name and game and game.technology_prototypes then
		return start, _end, technology_name, game.technology_prototypes[technology_name]
	else
		return start, _end, technology_name
	end
end


---@param text string
---@return integer?, integer?, string?, LuaRecipePrototype?
function richtext_util.find_recipe(text)
	local start, _end, recipe_name = text:find("%[recipe=(.+)%]")
	if recipe_name and game and game.recipe_prototypes then
		return start, _end, recipe_name, game.recipe_prototypes[recipe_name]
	else
		return start, _end, recipe_name
	end
end


---@param text string
---@return integer?, integer?, string?, LuaGroup?
function richtext_util.find_item_group(text)
	local start, _end, item_group_name = text:find("%[item%-group=(.+)%]")
	if item_group_name and game and game.item_group_prototypes then
		return start, _end, item_group_name, game.item_group_prototypes[item_group_name]
	else
		return start, _end, item_group_name
	end
end


---@param text string
---@return integer?, integer?, string?, LuaFluidPrototype?
function richtext_util.find_fluid(text)
	local start, _end, fluid_name = text:find("%[fluid=(.+)%]")
	if fluid_name and game and game.fluid_prototypes then
		return start, _end, fluid_name, game.fluid_prototypes[fluid_name]
	else
		return start, _end, fluid_name
	end
end


---@param text string
---@return integer?, integer?, string?, LuaTilePrototype?
function richtext_util.find_tile(text)
	local start, _end, tile_name = text:find("%[tile=(.+)%]")
	if tile_name and game and game.tile_prototypes then
		return start, _end, tile_name, game.tile_prototypes[tile_name]
	else
		return start, _end, tile_name
	end
end


---@param text string
---@return integer?, integer?, string?, LuaVirtualSignalPrototype?
function richtext_util.find_virtual_signal(text)
	local start, _end, signal_name = text:find("%[virtual%-signal=(.+)%]")
	if signal_name and game and game.virtual_signal_prototypes then
		return start, _end, signal_name, game.virtual_signal_prototypes[signal_name]
	else
		return start, _end, signal_name
	end
end


---@param text string
---@return integer?, integer?, string?, LuaAchievementPrototype?
function richtext_util.find_achievement(text)
	local start, _end, achievement_name = text:find("%[achievement=(.+)%]")
	if achievement_name and game and game.achievement_prototypes then
		return start, _end, achievement_name, game.achievement_prototypes[achievement_name]
	else
		return start, _end, achievement_name
	end
end


---@param text string
---@return integer?, integer?, number?, number?, string?, boolean
function richtext_util.find_gps(text)
	local start, _end, x, y, surface_name = text:find("%[gps=(.+),(.+),(.+)%]")
	if start == nil then
		start, _end, x, y, surface_name = text:find("%[gps=(.+),(.+)%]")
	end
	x = tonumber(x)
	y = tonumber(y)
	local is_valid = false
	if x and y then
		is_valid = true
	end
	return start, _end, x, y, surface_name, is_valid
end


---@param text string
---@return integer?, integer?, string?
function richtext_util.find_special_item(text)
	return text:find("%[special%-item=(.+)%]")
end


---@param text string
---@return integer?, integer?, string?, LuaPlayer?
function richtext_util.find_armor(text)
	local start, _end, player_name = text:find("%[armor=(.+)%]")
	if not (game and game.get_player) then
		return start, _end, player_name
	end

	local player = game.get_player(player_name)
	if player and not player.valid then
		player = nil
	end
	return start, _end, player_name, player
end


---@param text string
---@return integer?, integer?, integer?, LuaTrain?
function richtext_util.find_train(text)
	local start, _end, train_number = text:find("%[train=(%d+)%]")
	train_number = tonumber(train_number)
	if not (game and game.get_train_by_id) then
		return start, _end, train_number
	end

	local train = game.get_train_by_id(train_number)
	if train and not train.valid then
		train = nil
	end
	return start, _end, train_number, train
end


---@param text string
---@return integer?, integer?, integer?
function richtext_util.find_train_stop(text)
	local start, _end, train_stop_number = text:find("%[train-stop=(.+)%]")
	train_stop_number = tonumber(train_stop_number)
	return start, _end, train_stop_number
	--- Improve? https://lua-api.factorio.com/latest/classes/LuaGameScript.html#get_train_stops
end


---@param text string
---@return integer?, integer?, string?, string?
function richtext_util.find_tooltip(text)
	return text:find("%[tooltip=(.+),(.+)%]")
end


---@param text string
---@return integer?, integer?, string?, LuaFontPrototype?
function richtext_util.find_font(text)
	local start, _end, font_name = text:find("%[font=(.+)%].*%[[%./]font%]")
	local font
	if game and game.font_prototypes then
		font = game.font_prototypes[font_name]
	end
	return start, _end, font_name, font
end


---@param text string
---@return integer?, integer?, integer?, integer?, integer?, integer?
function richtext_util.find_color(text)
	local start, _end, r, g, b = text:find("%[gps=(%d+),(%d+),(.+)%].*%[[%./]color%]")
	if start then
		r = tonumber(r)
		g = tonumber(g)
		b = tonumber(b)
		return start, _end, r, g, b
	end

	local start, _end, color = text:find("%[color=(.+)%].*%[[%./]color%]")
	if not color and not (#color == 6 or
		(#color == 7 and color:sub(1, 1) == "#")
		(#color == 9 and color:sub(1, 1) == "#")
		)
	then
		return
	end

	local a
	local start_index = #color == 6 and 1 or 2
	if #color == 9 then
		start_index = 4
	end
	r = tonumber(color:sub(start_index, start_index + 1), 16)
	start_index = start_index + 2
	g = tonumber(color:sub(start_index, start_index + 1), 16)
	start_index = start_index + 2
	b = tonumber(color:sub(start_index, start_index + 1), 16)
	if #color == 9 then
		a = tonumber(color:sub(2, 3), 16)
	end

	return start, _end, r, g, b, a
end


return richtext_util
