---@class ZOdata_utils
local zo_utils = {}


do
	local util_pathes = {
		"locale", "time-util", "lauxlib", "number-util", "coordinates-util"
	}
	for _, path in ipairs(util_pathes) do
		for k, v in pairs(require(path)) do
			zo_utils[k] = v
		end
	end
end


return zo_utils
