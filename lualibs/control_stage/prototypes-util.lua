---@class ZOprototype_util
local prototype_util = {build = 1}


--[[
prototype_util.get_first_valid_prototype(prototypes, names): string?
]]


---@return string?
function prototype_util.get_first_valid_prototype(prototypes, names)
	for _, name in pairs(names) do
		if prototypes[name] then
			return name
		end
	end
end


return prototype_util
