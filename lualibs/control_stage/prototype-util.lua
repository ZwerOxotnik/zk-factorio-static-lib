---@class ZOprototype_util
local prototype_util = {build = 3}


--[[
prototype_util.get_first_valid_prototype(prototypes, names): string?
prototype_util.get_recipes_by_product(Product|Ingredient): LuaCustomTable<string, LuaRecipePrototype>
prototype_util.get_recipes_by_ingredient(Product|Ingredient): LuaCustomTable<string, LuaRecipePrototype>
prototype_util.get_recipes_by_item_ingredient(item_name): LuaCustomTable<string, LuaRecipePrototype>
prototype_util.get_recipes_by_item_product(item_name): LuaCustomTable<string, LuaRecipePrototype>
prototype_util.get_recipes_by_fluid_ingredient(ingredient_name): LuaCustomTable<string, LuaRecipePrototype>
prototype_util.get_recipes_by_fluid_product(ingredient_name): LuaCustomTable<string, LuaRecipePrototype>
prototype_util.get_recipes_by_ingredient_and_its_successors(Product|Ingredient, depth=1): LuaRecipePrototype[]
prototype_util.get_recipes_by_product_and_its_predecessors(Product|Ingredient,  depth=1): LuaRecipePrototype[]
prototype_util.get_result_recipes_by_entity_name(entity_name): LuaCustomTable<string, LuaRecipePrototype>
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

	return game.get_filtered_recipe_prototypes{{filter = "has-ingredient-item", elem_filters = elem_filters}}
end


---@param fluid_name string
---@return LuaCustomTable<string, LuaRecipePrototype>
function prototype_util.get_recipes_by_fluid_ingredient(fluid_name)
	local elem_filters = {
		{filter = "name", name = fluid_name}
	}

	return game.get_filtered_recipe_prototypes{{filter = "has-ingredient-fluid", elem_filters = elem_filters}}
end


---@param fluid_name string
---@return LuaCustomTable<string, LuaRecipePrototype>
function prototype_util.get_recipes_by_fluid_product(fluid_name)
	local elem_filters = {
		{filter = "name", name = fluid_name}
	}

	return game.get_filtered_recipe_prototypes{{filter = "has-product-fluid", elem_filters = elem_filters}}
end


---@param item_name string
---@return LuaCustomTable<string, LuaRecipePrototype>
function prototype_util.get_recipes_by_item_product(item_name)
	local elem_filters = {
		{filter = "name", name = item_name}
	}

	return game.get_filtered_recipe_prototypes{{filter = "has-product-item", elem_filters = elem_filters}}
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


---@param ingredient Product|Ingredient|table
---@param depth integer # 1 by default
---@return LuaRecipePrototype[]
function prototype_util.get_recipes_by_ingredient_and_its_successors(ingredient, depth)
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
						if _recipe == result_recipes[j2] then -- TODO: test
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
---@param depth integer # 1 by default
---@return LuaRecipePrototype[]
function prototype_util.get_recipes_by_product_and_its_predecessors(product, depth)
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
						if _recipe == result_recipes[j2] then -- TODO: test
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

	return game.get_filtered_recipe_prototypes{{
		filter = "has-product-item", elem_filters = {{filter = "place-result", elem_filters = elem_filters}}
	}}
end


return prototype_util
