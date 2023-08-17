---@class ZOentity_util
local entity_util = {build = 5}


--[[
entity_util.transfer_items(source, items, destination): integer
entity_util.pick_random_entity_with_heath(entities, tries): LuaEntity?
entity_util.check_entity_shield(entity): integer?, integer?, number? -- shield, max_shield, shield_ratio
entity_util.disconnect_not_own_wires(entity)
entity_util.disconnect_not_friendly_wires(entity)
entity_util.find_entities(filter_param, surfaces?, surface_blacklist?): table<uint, LuaEntity[]>
entity_util.count_entities(filter_param, surfaces?, surface_blacklist?): integer
entity_util.destroy_entities(filter_param, surfaces?, surface_blacklist?)
]]


---@type LuaEntity.destroy_param
local DESTROY_PARAM = {raise_destroy = true}
local random = math.random


-- the items must have count
---@return integer
function entity_util.transfer_items(source, items, destination)
    local items_amount = items.count or items.amount
    local count = source.get_item_count(items.name)
    if items_amount > count then
        if count == 0 then return 0 end
        if items.count then items.count = count end
        if items.amount then items.amount = count end
    end
    if not destination.can_insert(items) then return 0 end
    local inserted_items_count = destination.insert(items)
    source.remove_item(items)
    return inserted_items_count
end


---@param entities LuaEntity[]
---@param tries integer? # 10 by default
---@return LuaEntity?
function entity_util.pick_random_entity_with_heath(entities, tries)
	tries = tries or 10
	for _ = 1, tries do
		local entity = entities[random(1, #entities)]
		if entity.health and entity.destructible then
			return entity
		end
	end
end


---@param entity LuaEntity
---@return integer?, integer?, number? # shield, max_shield, shield_ratio
function entity_util.check_entity_shield(entity)
	if entity.grid == nil then
		return
	end

	local shield = 0
	local max_shield = 0
	for _, item in pairs(entity.grid.equipment) do
		--if item.max_shield and item.shield then
			shield = shield + item.shield
			max_shield = max_shield + item.max_shield
		--end
	end
	if shield == 0 then
		return 0, 0, 0
	end

	return shield, max_shield, shield / max_shield
end


---@param entity LuaEntity
function entity_util.disconnect_not_own_wires(entity)
	local force = entity.force
	local neighbours = entity.neighbours["copper"]
	local disconnect_neighbour = entity.disconnect_neighbour
	for i=1, #neighbours do
		local neighbour = neighbours[i]
		if force ~= neighbour.force then
			disconnect_neighbour(neighbour)
		end
	end
end


---@param entity LuaEntity
function entity_util.disconnect_not_friendly_wires(entity)
	local force = entity.force
	local neighbours = entity.neighbours["copper"]
	local disconnect_neighbour = entity.disconnect_neighbour
	local friendly_relations = {}
	for i=1, #neighbours do
		local neighbour = neighbours[i]
		local neighbour_force = neighbour.force
		if force ~= neighbour_force then
			local is_friendly = friendly_relations[neighbour_force]
			if is_friendly == false then
				disconnect_neighbour(neighbour)
			elseif is_friendly == nil then
				if force.get_cease_fire(neighbour_force) and
					neighbour_force.get_cease_fire(force) and
					force.get_friend(neighbour_force) and
					neighbour_force.get_friend(force)
				then
					friendly_relations[neighbour_force] = true
				else
					disconnect_neighbour(neighbour)
					friendly_relations[neighbour_force] = false
				end
			end
		end
	end
end


---@param filter_param LuaSurface.find_entities_filtered_param
---@param surfaces LuaCustomTable<any, LuaSurface> | table<any, LuaSurface>? # game.surfaces by default
---@param surface_blacklist table<LuaSurface, any>?
---@return table<uint, LuaEntity[]>
function entity_util.find_entities(filter_param, surfaces, surface_blacklist)
	surfaces = surfaces or game.surfaces
	local group_entities = {}

	if surface_blacklist == nil then
		for _, surface in pairs(surfaces) do
			if not surface.valid then goto continue end
			local entities = surface.find_entities_filtered(filter_param)
			if #entities > 0 then
				group_entities[#group_entities+1] = entities
			end
			::continue::
		end
	else
		for _, surface in pairs(surfaces) do
			if not surface.valid then goto continue end
			if surface_blacklist[surface] then goto continue end
			local entities = surface.find_entities_filtered(filter_param)
			if #entities > 0 then
				group_entities[#group_entities+1] = entities
			end
			::continue::
		end
	end

	return group_entities
end


---@param filter_param LuaSurface.find_entities_filtered_param
---@param surfaces LuaCustomTable<any, LuaSurface> | table<any, LuaSurface>? # game.surfaces by default
---@param surface_blacklist table<LuaSurface, any>?
---@return integer
function entity_util.count_entities(filter_param, surfaces, surface_blacklist)
	surfaces = surfaces or game.surfaces
	local count = 0

	if surface_blacklist == nil then
		for _, surface in pairs(surfaces) do
			if not surface.valid then goto continue end
			local entities = surface.find_entities_filtered(filter_param)
			count = count + #entities
			::continue::
		end
	else
		for _, surface in pairs(surfaces) do
			if not surface.valid then goto continue end
			if surface_blacklist[surface] then goto continue end
			local entities = surface.find_entities_filtered(filter_param)
			count = count + #entities
			::continue::
		end
	end

	return count
end


---@param filter_param LuaSurface.find_entities_filtered_param
---@param surfaces LuaCustomTable<any, LuaSurface> | table<any, LuaSurface>? # game.surfaces by default
---@param surface_blacklist table<LuaSurface, any>?
function entity_util.destroy_entities(filter_param, surfaces, surface_blacklist)
	surfaces = surfaces or game.surfaces
	local group_entities = {}

	if surface_blacklist == nil then
		for _, surface in pairs(surfaces) do
			if not surface.valid then goto continue end
			local entities = surface.find_entities_filtered(filter_param)
			for i = #entities, 1, -1 do
				entities[i].destroy(DESTROY_PARAM)
			end
			::continue::
		end
	else
		for _, surface in pairs(surfaces) do
			if not surface.valid then goto continue end
			if surface_blacklist[surface] then goto continue end
			local entities = surface.find_entities_filtered(filter_param)
			for i = #entities, 1, -1 do
				entities[i].destroy(DESTROY_PARAM)
			end
			::continue::
		end
	end

	return group_entities
end


return entity_util
