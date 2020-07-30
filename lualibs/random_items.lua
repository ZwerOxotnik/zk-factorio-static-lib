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

-- WARNING! This script doesn't support multi-teams yet
-- And also requires a few more tests

local module = {}
local random_items

local function check_global_data()
	global.random_items = global.random_items or {}
end

-- Finds all items, clearing cheat items, broken items to save rest names of items in global.random_items
local function check_items()
	global.random_items = {}
	for name, item in pairs(game.item_prototypes) do
		if not (name:find("creative") or name:find("hidden") or name:find("infinity")
			or name:find("infinity") or name:find("cheat"))and item.type ~= "mining-tool"
			and not item.has_flag("hidden") then
			table.insert(global.random_items, name)
		end
	end
	random_items = global.random_items
end

module.insert_random_item = function(receiver, count)
	if count == nil then count = 1 end
	for i=1, count do
		receiver.insert{name = random_items[math.random(#random_items)]}
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
