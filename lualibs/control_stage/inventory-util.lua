---@class ZOinventory_util
local inventory_util = {build = 2}


--[[
inventory_util.copy_inventory_items_safely(source_inventory, reciever_inventory): boolean
inventory_util.copy_inventory_items(source_inventory, reciever_inventory): boolean
inventory_util.copy_inventory_items_to_player(source_inventory, player): boolean
inventory_util.insert_items_safely(reciever, items)
inventory_util.remove_items_safely(reciever, items)
inventory_util.add_items(reciever, items)
inventory_util.add_items(reciever, items, is_return_rest_by_missing_items): table<string, uint>?
inventory_util.has_all_items(reciever, item_requests): boolean
inventory_util.has_all_items(reciever, item_requests, is_return_rest_by_missing_items): boolean, rest_items?
TODO: inventory_util.get_all_items(reciever, item_requests): ItemStack[]
TODO: inventory_util.get_all_items(reciever, item_requests, is_return_rest_by_missing_items): ItemStack[], rest_items?
inventory_util.has_any_item(reciever, item_requests): boolean
TODO: inventory_util.get_any_item(reciever, item_requests): item
]]


---@param source_inventory LuaInventory
---@param reciever_inventory LuaInventory
---@return boolean
function inventory_util.copy_inventory_items_safely(source_inventory, reciever_inventory)
	if not (source_inventory and source_inventory.valid) then
		return false
	end
	if not (reciever_inventory and reciever_inventory.valid) then
		return false
	end

	for i = 1, #source_inventory do
		---@type LuaItemStack
		local stack = source_inventory[i]
		if not stack.valid_for_read then
			goto continue
		end
		if source_inventory.can_insert(stack) then
			reciever_inventory.insert(stack)
		end
		:: continue ::
	end
	return true
end


---@param source_inventory LuaInventory
---@param reciever_inventory LuaInventory
---@return boolean
function inventory_util.copy_inventory_items(source_inventory, reciever_inventory)
	if not (source_inventory and source_inventory.valid) then
		return false
	end
	if not (reciever_inventory and reciever_inventory.valid) then
		return false
	end

	for i = 1, #source_inventory do
		---@type LuaItemStack
		local stack = source_inventory[i]
		if stack.valid_for_read then
			reciever_inventory.insert(stack)
		end
	end
	return true
end


---@param source_inventory LuaInventory
---@param player LuaPlayer
---@return boolean
function inventory_util.copy_inventory_items_to_player(source_inventory, player)
	if not (source_inventory and source_inventory.valid) then
		return false
	end
	if not (player and player.valid) then
		return false
	end
	local player_inv = player.get_main_inventory()
	if not (player_inv and player_inv.valid) then
		return false
	end

	local spill_item_stack = player.surface.spill_item_stack
	local player_position = player.position
	for _, stack in pairs(source_inventory) do --TODO: recheck
		---@cast stack LuaItemStack
		if not stack.valid_for_read then
			goto continue
		end

		if player_inv.can_insert(stack) then
			player_inv.insert(stack)
		else
			spill_item_stack(player_position, stack, true, nil, false) -- lootable, can't be spilled onto belts
		end
		:: continue ::
	end
	return true
end


---@param reciever LuaInventory | LuaEntity | LuaControl | LuaTrain | LuaLogisticNetwork
---@param items table<string, uint> | SimpleItemStack[] | LuaItemStack[]
function inventory_util.insert_items_safely(reciever, items)
	local _, v = next(items)
	local is_items_dictionary = (type(v) == "number")
	local item_prototypes = game.item_prototypes
	local insert = reciever.insert

	if is_items_dictionary then
		---@cast items table<string, uint>

		---@type SimpleItemStack
		local stack = {name = "", count = 1}
		for name, count in pairs(items) do
			if item_prototypes[name] then
				stack.name = name
				stack.count = count
				insert(stack)
			end
		end
		return
	end

	---@cast items SimpleItemStack[] | LuaItemStack[]
	for _, item_data in pairs(items) do
		if item_prototypes[item_data.name] then
			insert(item_data)
		end
	end
end


---@param reciever LuaInventory | LuaEntity | LuaControl | LuaTrain | LuaLogisticNetwork
---@param items table<string, uint> | SimpleItemStack[] | LuaItemStack[]
function inventory_util.remove_items_safely(reciever, items)
	local _, v = next(items)
	local is_items_dictionary = (type(v) == "number")
	local item_prototypes = game.item_prototypes
	local remove = reciever.remove

	if is_items_dictionary then
		---@cast items table<string, uint>

		---@type SimpleItemStack
		local stack = {name = "", count = 1}
		for name, count in pairs(items) do
			if item_prototypes[name] then
				stack.name = name
				stack.count = count
				remove(stack)
			end
		end
		return
	end

	---@cast items SimpleItemStack[] | LuaItemStack[]
	for _, item_data in pairs(items) do
		if item_prototypes[item_data.name] then
			remove(item_data)
		end
	end
end


---@param reciever LuaInventory | LuaEntity | LuaControl | LuaTrain | LuaLogisticNetwork
---@param items table<string, uint> | SimpleItemStack[] | LuaItemStack[]
---@param is_return_rest_by_missing_items boolean
---@return table<string, uint>
---@overload fun(reciever: LuaInventory | LuaEntity | LuaControl | LuaTrain | LuaLogisticNetwork, items: table<string, uint> | SimpleItemStack[] | LuaItemStack[])
function inventory_util.add_items(reciever, items, is_return_rest_by_missing_items)
	local _, v = next(items)
	local is_items_dictionary = (type(v) == "number")
	local is_items_SimpleItemStack = (type(v) == "table")

	local insert = reciever.insert
	if is_items_dictionary then
		---@cast items table<string, uint>

		if is_return_rest_by_missing_items == nil then
			---@type SimpleItemStack
			local stack = {name = "", count = 1}
			for name, count in pairs(items) do
				stack.name = name
				stack.count = count
				insert(stack)
			end

			return
		end

		if is_return_rest_by_missing_items then
			local not_added_items
			---@type SimpleItemStack
			local stack = {name = "", count = 1}
			for name, count in pairs(items) do
				stack.name = name
				stack.count = count
				local rest_count = count - insert(stack)
				if rest_count > 0 then
					not_added_items[name] = rest_count
				end
			end

			return not_added_items
		else
			local added_items
			---@type SimpleItemStack
			local stack = {name = "", count = 1}
			for name, count in pairs(items) do
				stack.name = name
				stack.count = count
				local added_count = insert(stack)
				if added_count > 0 then
					added_items[name] = added_count
				end
			end

			return added_items
		end
	end

	if is_items_SimpleItemStack then
		---@cast items SimpleItemStack[]

		if is_return_rest_by_missing_items == nil then
			for _, item in pairs(items) do
				insert(item)
			end
			return
		end

		if is_return_rest_by_missing_items then
			local not_added_items
			for _, item in pairs(items) do
				local rest_count = item.count - insert(item)
				if rest_count > 0 then
					not_added_items[item.name] = rest_count
				end
			end

			return not_added_items
		else
			local added_items
			for _, item in pairs(items) do
				local added_count = insert(item)
				if added_count > 0 then
					added_items[item.name] = added_count
				end
			end

			return added_items
		end
	end

	---@cast items LuaItemStack[]

	if is_return_rest_by_missing_items == nil then
		for _, item in pairs(items) do
			insert(item)
		end
		return
	end

	if is_return_rest_by_missing_items then
		local not_added_items
		for _, item in pairs(items) do
			local rest_count = item.count - insert(item)
			if rest_count > 0 then
				local name = item.name
				not_added_items[name] = (not_added_items[name] or 0) + rest_count
			end
		end

		return not_added_items
	else
		local added_items
		for _, item in pairs(items) do
			local added_count = insert(item)
			if added_count > 0 then
				local name = item.name
				added_items[name] = (added_items[name] or 0) + added_count
			end
		end

		return added_items
	end
end


---@param reciever LuaInventory | LuaEntity | LuaControl | LuaTrain | LuaLogisticNetwork
---@param item_requests table<string, uint> | SimpleItemStack[] | LuaItemStack[]
---@param is_return_rest_by_missing_items nil # false then return items that found
---@return boolean
---@overload fun(reciever: LuaInventory | LuaEntity | LuaControl | LuaTrain | LuaLogisticNetwork, item_requests: table<string, uint> | SimpleItemStack[] | LuaItemStack[], is_return_missing_items: boolean): boolean, table<string, uint>?
function inventory_util.has_all_items(reciever, item_requests, is_return_rest_by_missing_items)
	local get_item_count = reciever.get_item_count

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


	---@cast item_requests SimpleItemStack[] | LuaItemStack[]
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


---@param reciever LuaInventory | LuaEntity | LuaControl | LuaTrain | LuaLogisticNetwork
---@param item_requests table<string, uint> | SimpleItemStack[] | LuaItemStack[]
---@return boolean
function inventory_util.has_any_item(reciever, item_requests)
	local get_item_count = reciever.get_item_count

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

	---@cast item_requests SimpleItemStack[] | LuaItemStack[]
	for _, item in pairs(item_requests) do
		local current_count = get_item_count(item.name)
		if current_count >= (item.count or 1) then
			return true
		end
	end

	return false
end


return inventory_util
