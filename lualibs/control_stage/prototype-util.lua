---@class ZOprototype_util
local prototype_util = {build = 2}


--[[
prototype_util.get_first_valid_prototype(prototypes, names): string?
prototype_util.get_recipes_by_item_ingredient(item_name): LuaCustomTable<string, LuaRecipePrototype>?
prototype_util.get_recipes_by_item_product(item_name): LuaCustomTable<string, LuaRecipePrototype>?
prototype_util.get_recipes_by_fluid_ingredient(ingredient_name): LuaCustomTable<string, LuaRecipePrototype>?
prototype_util.get_recipes_by_fluid_product(ingredient_name): LuaCustomTable<string, LuaRecipePrototype>?
prototype_util.get_result_recipes_by_entity_name(entity_name): LuaCustomTable<string, LuaRecipePrototype>?
]]


---@param prototypes table
---@param names string[]
---@return string?
function prototype_util.get_first_valid_prototype(prototypes, names)
	for _, name in pairs(names) do
		if prototypes[name] then
			return name
		end
	end
end


---@param item_name string
---@return LuaCustomTable<string, LuaRecipePrototype>?
function prototype_util.get_recipes_by_item_ingredient(item_name)
	local elem_filters = {
		{filter = "name", name = item_name}
	}

	return game.get_filtered_recipe_prototypes{{filter = "has-ingredient-item",  elem_filters = elem_filters}}
end


---@param fluid_name string
---@return LuaCustomTable<string, LuaRecipePrototype>?
function prototype_util.get_recipes_by_fluid_ingredient(fluid_name)
	local elem_filters = {
		{filter = "name", name = fluid_name}
	}

	return game.get_filtered_recipe_prototypes{{filter = "has-ingredient-fluid",  elem_filters = elem_filters}}
end


---@param fluid_name string
---@return LuaCustomTable<string, LuaRecipePrototype>?
function prototype_util.get_recipes_by_fluid_product(fluid_name)
	local elem_filters = {
		{filter = "name", name = fluid_name}
	}

	return game.get_filtered_recipe_prototypes{{filter = "has-product-fluid", elem_filters = elem_filters}}
end


---@param item_name string
---@return LuaCustomTable<string, LuaRecipePrototype>?
function prototype_util.get_recipes_by_item_product(item_name)
	local elem_filters = {
		{filter = "name", name = item_name}
	}

	return game.get_filtered_recipe_prototypes{{filter = "has-product-item", elem_filters = elem_filters}}
end


---@param entity_name string
---@return LuaCustomTable<string, LuaRecipePrototype>
function prototype_util.get_result_recipes_by_entity_name(entity_name)
	local elem_filters = {
		{filter = "name", name = entity_name}
	}

	return game.get_filtered_recipe_prototypes{{
		filter = "has-product-item", elem_filters = {{filter = "place-result", elem_filters = elem_filters}}
	}}
end


return prototype_util
