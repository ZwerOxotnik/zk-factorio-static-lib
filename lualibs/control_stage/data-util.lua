---@class ZOdata_util
local data_util = {build = 2}


--[[
data_util.remove_invalid_prototypes(valid_prototypes, target)
data_util.get_invalid_prototypes(valid_prototypes, target): string[]
data_util.get_valid_prototypes(all_valid_prototypes, target): string[]
]]


local tremove = table.remove


---@param valid_prototypes LuaCustomTable<string, any> | table<string, any>
---@param target table<any, string> | table<string, any>
function data_util.remove_invalid_prototypes(valid_prototypes, target)
	local k1, v1
	for k, v in pairs(target) do
		k1, v1 = k, v
		break
	end

	if type(k1) == "string" then
		for name in pairs(target) do
			if not valid_prototypes[name] then
				target[name] = nil
			end
		end
	elseif type(v1) == "string" then
		if type(k1) == "number" then
			for i, name in pairs(target) do
				if not valid_prototypes[name] then
					tremove(target, i)
				end
			end
		else
			for k, name in pairs(target) do
				if not valid_prototypes[name] then
					target[k] = nil
				end
			end
		end
	end
end


---@param valid_prototypes LuaCustomTable<string, any> | table<string, any>
---@param target table<any, string> | table<string, any>
---@return string[]
function data_util.get_invalid_prototypes(valid_prototypes, target)
	---@type string[]
	local invalid_prototypes = {}

	local k1, v1
	for k, v in pairs(target) do
		k1, v1 = k, v
		break
	end

	if type(k1) == "string" then
		for name in pairs(target) do
			if not valid_prototypes[name] then
				invalid_prototypes[#invalid_prototypes+1] = name
			end
		end
	elseif type(v1) == "string" then
		for _, name in pairs(target) do
			if not valid_prototypes[name] then
				invalid_prototypes[#invalid_prototypes+1] = name
			end
		end
	end

	return invalid_prototypes
end


---@param all_valid_prototypes LuaCustomTable<string, any> | table<string, any>
---@param target table<any, string> | table<string, any>
---@return string[]
function data_util.get_valid_prototypes(all_valid_prototypes, target)
	---@type string[]
	local valid_prototypes = {}

	local k1, v1
	for k, v in pairs(target) do
		k1, v1 = k, v
		break
	end

	if type(k1) == "string" then
		for name in pairs(target) do
			if all_valid_prototypes[name] then
				valid_prototypes[#valid_prototypes+1] = name
			end
		end
	elseif type(v1) == "string" then
		for _, name in pairs(target) do
			if all_valid_prototypes[name] then
				valid_prototypes[#valid_prototypes+1] = name
			end
		end
	end

	return valid_prototypes
end


return data_util
