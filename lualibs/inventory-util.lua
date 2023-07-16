---@class ZOinventory
local inventory_util = {}


---@param source_inventory LuaInventory
---@param reciever_inventory LuaInventory
---@return boolean
inventory_util.copy_inventory_items_safely = function(source_inventory, reciever_inventory)
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
inventory_util.copy_inventory_items = function(source_inventory, reciever_inventory)
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
inventory_util.copy_inventory_items_to_player = function(source_inventory, player)
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
	for i=1, #source_inventory do
		---@type LuaItemStack
		local stack = source_inventory[i]
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


---@param reciever LuaInventory|LuaEntity
---@param items table[]
inventory_util.insert_items_safely = function(reciever, items)
	local item_prototypes = game.item_prototypes
	for i=1, #items do
		local item_data = items[i]
		if item_prototypes[item_data.name] then
			reciever.insert(item_data)
		end
	end
end


---@param reciever LuaInventory|LuaEntity
---@param items table[]
inventory_util.remove_items_safely = function(reciever, items)
	local item_prototypes = game.item_prototypes
	for i=1, #items do
		local item_data = items[i]
		if item_prototypes[item_data.name] then
			reciever.remove(item_data)
		end
	end
end


return inventory_util
