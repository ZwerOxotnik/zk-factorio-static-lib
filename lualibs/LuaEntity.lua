--[[
Copyright 2019-2020 ZwerOxotnik <zweroxotnik@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]--

-- check: https://lua-api.factorio.com/latest/LuaInventory.html
-- https://lua-api.factorio.com/latest/Concepts.html#SimpleItemStack

local entity_util = {}


local random = math.random


-- the items must have count
entity_util.transfer_items = function(source, items, destination)
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
entity_util.pick_random_entity_with_heath = function(entities, tries)
	tries = tries or 10
	for _ = 1, tries do
		local entity = entities[random(1, #entities)]
		if entity.health and entity.destructible then
			return entity
		end
	end
end


return entity_util
