---@class ZOitem_util
local item_util = {build = 1}


--[[
item_util.items_into_dictionary(items): table<string, uint>
item_util.items_into_dictionary(items, dictionary)
item_util.items_into_SimpleItemStacks(items): SimpleItemStack[]
item_util.items_into_SimpleItemStacks(items, SimpleItemStacks)
item_util.remove_not_existing_items(items)
]]


local tremove = table.remove
local type, pairs = type, pairs


---@param items LuaItemStack[] | SimpleItemStack[]
---@param dictionary table<string, uint>
---@overload fun(items): table<string, uint>
function item_util.items_into_dictionary(items, dictionary)
	if not dictionary then
		dictionary = {}

		for _, item in pairs(items) do
			dictionary[item.name] = (item.count or 1)
		end

		return dictionary
	end

	if #dictionary <= 0 then
		for _, item in pairs(items) do
			dictionary[item.name] = (item.count or 1)
		end
	else
		for _, item in pairs(items) do
			local name = item.name
			dictionary[name] = (dictionary[name] or 0) + (item.count or 1)
		end
	end
end


---@param items LuaItemStack[] | table<string, uint>
---@param SimpleItemStacks SimpleItemStack[]
---@overload fun(items): SimpleItemStack[]
function item_util.items_into_SimpleItemStacks(items, SimpleItemStacks)
	local is_items_LuaItemPrototype = type(items[1]) ~= "number"

	local is_arg2_empty = false
	if not SimpleItemStacks then
		is_arg2_empty = true
		SimpleItemStacks = {}
	end

	local i = 0
	if is_items_LuaItemPrototype then
		---@cast items LuaItemStack[]
		for _, item in pairs(items) do
			i = i + 1
			SimpleItemStacks[i] = {name = item.name, count = (item.count or 1)}
		end
	else
		---@cast items table<string, uint>
		for name, count in pairs(items) do
			i = i + 1
			SimpleItemStacks[i] = {name = name, count = count}
		end
	end

	if is_arg2_empty then
		return SimpleItemStacks
	end
end


---@param items SimpleItemStack[] | table<string, uint>
function item_util.remove_not_existing_items(items)
	local is_SimpleItemStack = (type(items) == "table")

	local item_prototypes = game.item_prototypes
	if is_SimpleItemStack then
		---@cast items SimpleItemStack[]
		for i, item in pairs(items) do
			if not item_prototypes[item.name] then
				tremove(items, i)
			end
		end
	else
		---@cast items table<string, uint>
		for name in pairs(items) do
			if not item_prototypes[name] then
				items[name] = nil
			end
		end
	end
end


return item_util
