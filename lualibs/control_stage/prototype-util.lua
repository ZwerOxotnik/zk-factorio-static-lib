---@class ZOprototype_util
local prototype_util = {build = 8}


--[[
prototype_util.get_first_valid_prototype(prototypes, names): string?
prototype_util.get_recipes_by_product(Product|Ingredient|table): LuaCustomTable<string, LuaRecipePrototype>
prototype_util.get_recipes_by_ingredient(Product|Ingredient|table): LuaCustomTable<string, LuaRecipePrototype>
prototype_util.get_recipes_by_item_ingredient(item_name): LuaCustomTable<string, LuaRecipePrototype>
prototype_util.get_recipes_by_item_product(item_name): LuaCustomTable<string, LuaRecipePrototype>
prototype_util.get_recipes_by_fluid_ingredient(ingredient_name): LuaCustomTable<string, LuaRecipePrototype>
prototype_util.get_recipes_by_fluid_product(ingredient_name): LuaCustomTable<string, LuaRecipePrototype>
prototype_util.get_recipes_successors(  LuaRecipe|LuaRecipePrototype|table, depth=1): LuaRecipePrototype[]
prototype_util.get_recipes_predecessors(LuaRecipe|LuaRecipePrototype|table, depth=1): LuaRecipePrototype[]
prototype_util.get_recipes_and_its_successors_by_ingredient(Product|Ingredient|table, depth=1): LuaRecipePrototype[]
prototype_util.get_recipes_and_its_predecessors_by_product( Product|Ingredient|table, depth=1): LuaRecipePrototype[]
prototype_util.get_result_recipes_by_entity_name(entity_name): LuaCustomTable<string, LuaRecipePrototype>
prototype_util.find_min_max_turret_range(prototypes?): uint, uint -- min, max
prototype_util.find_biggest_chest(prototypes?):  LuaEntityPrototype?, uint? -- prototype, inventory_size
prototype_util.find_smallest_chest(prototypes?): LuaEntityPrototype?, uint? -- prototype, inventory_size
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
---@return LuaCustomTable<string, LuaRecipePrototype>
function prototype_util.get_recipes_by_item_ingredient(item_name)
	local elem_filters = {
		{filter = "name", name = item_name}
	}

	return prototypes.get_recipe_filtered{{filter = "has-ingredient-item", elem_filters = elem_filters}}
end


---@param fluid_name string
---@return LuaCustomTable<string, LuaRecipePrototype>
function prototype_util.get_recipes_by_fluid_ingredient(fluid_name)
	local elem_filters = {
		{filter = "name", name = fluid_name}
	}

	return prototypes.get_recipe_filtered{{filter = "has-ingredient-fluid", elem_filters = elem_filters}}
end


---@param fluid_name string
---@return LuaCustomTable<string, LuaRecipePrototype>
function prototype_util.get_recipes_by_fluid_product(fluid_name)
	local elem_filters = {
		{filter = "name", name = fluid_name}
	}

	return prototypes.get_recipe_filtered{{filter = "has-product-fluid", elem_filters = elem_filters}}
end


---@param item_name string
---@return LuaCustomTable<string, LuaRecipePrototype>
function prototype_util.get_recipes_by_item_product(item_name)
	local elem_filters = {
		{filter = "name", name = item_name}
	}

	return prototypes.get_recipe_filtered{{filter = "has-product-item", elem_filters = elem_filters}}
end


---@param product Product|Ingredient|table
---@return LuaCustomTable<string, LuaRecipePrototype>
function prototype_util.get_recipes_by_product(product)
	if product.type == "fluid" then
		return prototype_util.get_recipes_by_fluid_product(product.name)
	else -- item
		return prototype_util.get_recipes_by_item_product(product.name)
	end
end


---@param ingredient Product|Ingredient|table
---@return LuaCustomTable<string, LuaRecipePrototype>
function prototype_util.get_recipes_by_ingredient(ingredient)
	if ingredient.type == "fluid" then
		return prototype_util.get_recipes_by_fluid_ingredient(ingredient.name)
	else -- item
		return prototype_util.get_recipes_by_item_ingredient(ingredient.name)
	end
end


---@param recipe LuaRecipe|LuaRecipePrototype|table
---@param depth integer? # 1 by default
---@return LuaRecipePrototype[]
function prototype_util.get_recipes_successors(recipe, depth)
	depth = depth or 1

	local get_recipes_by_ingredient = prototype_util.get_recipes_by_ingredient
	local result_recipes = {nil}
	local products = recipe.products
	for _, product in pairs(products) do
		recipes = get_recipes_by_ingredient(product)
		for _, _recipe in pairs(recipes) do
			if _recipe ~= recipe then
				for _, result_recipe in pairs(result_recipes) do
					if _recipe == result_recipe then
						goto continuei2
					end
				end
				result_recipes[#result_recipes+1] = _recipe
				:: continuei2 ::
			end
		end
	end

	for _ = 1, depth-1 do
		for _, _recipe in pairs(recipes) do
			if _recipe ~= recipe then
				local _products = _recipe.products
				for j = 1, #_products do
					recipes = prototype_util.get_recipes_by_ingredient(_products[j])
					for _, __recipe in pairs(recipes) do
						for j2 = 1, #result_recipes do
							if __recipe == result_recipes[j2] then
								goto continuei2
							end
						end
						result_recipes[#result_recipes+1] = __recipe
						:: continuei2 ::
					end
				end
			end
		end
	end

	return result_recipes
end


---@param recipe LuaRecipe|LuaRecipePrototype|table
---@param depth integer? # 1 by default
---@return LuaRecipePrototype[]
function prototype_util.get_recipes_predecessors(recipe, depth)
	depth = depth or 1

	local get_recipes_by_product = prototype_util.get_recipes_by_product
	local result_recipes = {nil}
	local ingredients = recipe.ingredients
	for _, ingredient in pairs(ingredients) do
		recipes = get_recipes_by_product(ingredient)
		for _, _recipe in pairs(recipes) do
			if _recipe ~= recipe then
				for _, result_recipe in pairs(result_recipes) do
					if _recipe == result_recipe then
						goto continuei2
					end
				end
				result_recipes[#result_recipes+1] = _recipe
				:: continuei2 ::
			end
		end
	end

	for _ = 1, depth-1 do
		for _, _recipe in pairs(recipes) do
			if _recipe ~= recipe then
				local _ingredients = _recipe.ingredients
				for j = 1, #_ingredients do
					recipes = prototype_util.get_recipes_by_product(_ingredients[j])
					for _, __recipe in pairs(recipes) do
						for j2 = 1, #result_recipes do
							if __recipe == result_recipes[j2] then
								goto continuei2
							end
						end
						result_recipes[#result_recipes+1] = __recipe
						:: continuei2 ::
					end
				end
			end
		end
	end

	return result_recipes
end


---@param ingredient Product|Ingredient|table
---@param depth integer? # 1 by default
---@return LuaRecipePrototype[]
function prototype_util.get_recipes_and_its_successors_by_ingredient(ingredient, depth)
	depth = depth or 1

	local recipes = prototype_util.get_recipes_by_ingredient(ingredient)
	local result_recipes = {nil}
	for _, recipe in pairs(recipes) do
		result_recipes[#result_recipes+1] = recipe
	end

	for _ = 1, depth do
		for _, recipe in pairs(recipes) do
			local products = recipe.products
			for j = 1, #products do
				recipes = prototype_util.get_recipes_by_ingredient(products[j])
				for _, _recipe in pairs(recipes) do
					for j2 = 1, #result_recipes do
						if _recipe == result_recipes[j2] then
							goto continuei2
						end
					end
					result_recipes[#result_recipes+1] = _recipe
					:: continuei2 ::
				end
			end
		end
	end

	return result_recipes
end


---@param product Product|Ingredient|table
---@param depth integer? # 1 by default
---@return LuaRecipePrototype[]
function prototype_util.get_recipes_and_its_predecessors_by_product(product, depth)
	depth = depth or 1

	local recipes = prototype_util.get_recipes_by_product(product)
	local result_recipes = {nil}
	for _, recipe in pairs(recipes) do
		result_recipes[#result_recipes+1] = recipe
	end

	for _ = 1, depth do
		for _, recipe in pairs(recipes) do
			local ingredients = recipe.ingredients
			for j = 1, #ingredients do
				recipes = prototype_util.get_recipes_by_product(ingredients[j])
				for _, _recipe in pairs(recipes) do
					for j2 = 1, #result_recipes do
						if _recipe == result_recipes[j2] then
							goto continuei2
						end
					end
					result_recipes[#result_recipes+1] = _recipe
					:: continuei2 ::
				end
			end
		end
	end

	return result_recipes
end


---@param entity_name string
---@return LuaCustomTable<string, LuaRecipePrototype>
function prototype_util.get_result_recipes_by_entity_name(entity_name)
	local elem_filters = {
		{filter = "name", name = entity_name}
	}

	return prototypes.get_recipe_filtered{{
		filter = "has-product-item", elem_filters = {{filter = "place-result", elem_filters = elem_filters}}
	}}
end


---@param prototypes LuaCustomTable<any, LuaEntityPrototype> | table<any, LuaEntityPrototype>?
---@return uint, uint # min, max
function prototype_util.find_min_max_turret_range(prototypes)
	local max_turret_range = 0
	local min_turret_range
	prototypes = prototypes or prototypes.get_entity_filtered{
		{filter="turret"}
	}

	for _, prototype in pairs(prototypes) do
		if prototype.turret_range > max_turret_range then
			max_turret_range = prototype.turret_range --[[@as uint]]
		end
		if min_turret_range == nil or prototype.turret_range < min_turret_range then
			min_turret_range = prototype.turret_range --[[@as uint]]
		end
	end

	return (min_turret_range or 0), max_turret_range
end


-- TODO: improve with mods
---@param prototypes LuaCustomTable<any, LuaEntityPrototype> | table<any, LuaEntityPrototype>?
---@return LuaEntityPrototype?, uint? # prototype?, size?
function prototype_util.find_biggest_chest(prototypes)
	local result_prototype
	local max_inventory_size = 0
	prototypes = prototypes or prototypes.get_entity_filtered{
		{filter="type", type="container"}
	}

	for _, prototype in pairs(prototypes) do
		if not prototype.selectable_in_game then goto continue end
		local inventory_size = prototype.get_inventory_size(defines.inventory.chest)
		if inventory_size > max_inventory_size then
			result_prototype = prototype
			max_inventory_size = inventory_size --[[@as uint]]
		end
		::continue::
	end

	if result_prototype then
		return result_prototype, max_inventory_size
	end
end


-- TODO: improve with mods
---@param prototypes LuaCustomTable<any, LuaEntityPrototype> | table<any, LuaEntityPrototype>?
---@return LuaEntityPrototype?, uint? # prototype?, size?
function prototype_util.find_smallest_chest(prototypes)
	local result_prototype
	local min_inventory_size
	prototypes = prototypes or prototypes.get_entity_filtered{
		{filter="type", type="container"}
	}

	for _, prototype in pairs(prototypes) do
		if not prototype.selectable_in_game then goto continue end
		local inventory_size = prototype.get_inventory_size(defines.inventory.chest)
		if inventory_size ~= 0 and inventory_size < min_inventory_size then
			result_prototype = prototype
			min_inventory_size = inventory_size --[[@as uint]]
		end
		::continue::
	end

	return result_prototype, min_inventory_size
end


return prototype_util
