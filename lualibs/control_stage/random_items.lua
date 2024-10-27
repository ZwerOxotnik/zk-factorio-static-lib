-- WARNING! This script doesn't support multi-teams yet
-- And also requires a few more tests

---@class ZOrandom_items
local random_items = {build = 4}


--[[
random_items.insert_random_item(receiver, count?)
random_items.on_init()
random_items.on_load()
random_items.on_configuration_changed()
]]


local random_items_list
local random = math.random


local function link_data()
	random_items_list = storage.random_items
end

local function check_global_data()
	storage.random_items = storage.random_items or {}
	link_data()
end


-- Finds most player items and save their names into storage.random_items
local function check_items()
	local BLACKLISTED_NAMES = {
		["artillery-targeting-remote"] = true
	}
	local BLACKLISTED_TYPES = {
		["deconstruction-item"] = true,
		["rts-tool"] = true,
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
	storage.random_items = {}
	link_data()
	for name, item in pairs(prototypes.item) do
		if not (
				item.hidden
				or BLACKLISTED_TYPES[item.type]
				or BLACKLISTED_NAMES[name]
				or name:find("creative") -- for https://mods.factorio.com/mod/creative-mode etc
				or name:find("hidden")
				or name:find("infinity")
				or name:find("cheat")
				or name:find("[xX]%d+_") -- for https://mods.factorio.com/mod/X100_assembler etc
				or name:find("^osp_") -- for mods.factorio.com/mod/m-spell-pack
				or name:find("^ee%-") -- for https://mods.factorio.com/mod/EditorExtensions
			)
		then
			random_items_list[#random_items_list+1] = name
		end
	end
end


---@param receiver LuaEntity
---@param count? number
function random_items.insert_random_item(receiver, count)
	if count == nil then
		receiver.insert{name = random_items_list[random(#random_items_list)]}
		return
	end

	local data = {name = ''}
	local insert = receiver.insert
	for _=1, count do
		data.name = random_items_list[random(#random_items_list)]
		insert(data)
	end
end


function random_items.on_init()
	check_global_data()
	check_items()
end

function random_items.on_load()
	link_data()
end

function random_items.on_configuration_changed()
	check_items()
end


return random_items
