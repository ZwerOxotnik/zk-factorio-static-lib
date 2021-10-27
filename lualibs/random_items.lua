--[[
Copyright 2019-2021 ZwerOxotnik <zweroxotnik@gmail.com>

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

-- WARNING! This script doesn't support multi-teams yet
-- And also requires a few more tests

local module = {}
local random_items
local random = math.random
local tinsert = table.insert
local BLACKLISTED_NAMES = {
	["artillery-targeting-remote"] = true
}
local BLACKLISTED_TYPES = {
	["deconstruction-item"] = true,
	["spidertron-remote"] = true,
	["copy-paste-tool"] = true,
	["selection-tool"] = true,
	["blueprint-book"] = true,
	["upgrade-item"] = true,
	["rail-planner"] = true,
	["mining-tool"] = true,
	["blueprint"] = true,
	["item-with-inventory"] = true, -- perhaps, I shouldn't do that
	["item-with-label"] = true,
	["item-with-tags"] = true,
	["tool"] = true -- it seems almost fine in general
}

local function check_global_data()
	global.random_items = global.random_items or {}
end

-- Finds most player items and save their names into global.random_items
local function check_items()
	global.random_items = {}
	random_items = global.random_items
	for name, item in pairs(game.item_prototypes) do
		if not (
				BLACKLISTED_TYPES[item.type] or BLACKLISTED_NAMES[name]
				or name:find("creative") or name:find("hidden")
				or name:find("infinity") or name:find("cheat")
			)
			and not item.has_flag("hidden")
		then
				tinsert(random_items, name)
		end
	end
end

---@param receiver LuaEntity
---@param count? number
module.insert_random_item = function(receiver, count)
	if count == nil then
		receiver.insert{name = random_items[random(#random_items)]}
		return
	end

	local data = {name = ''}
	local insert = receiver.insert
	for _=1, count do
		data.name = random_items[random(#random_items)]
		insert(data)
	end
end

module.on_init = function()
	check_global_data()
	check_items()
end

module.on_load = function()
	random_items = global.random_items
end

module.on_configuration_changed = function()
	check_items()
end

return module
