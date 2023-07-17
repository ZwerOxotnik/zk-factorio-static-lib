---@class ZOdata_utils
local zo_utils = {}


do
	local util_paths = {
		"locale", "time-util", "lauxlib", "number-util", "coordinates-util"
	}
	for i, path in ipairs(util_paths) do
		util_paths[i] = "lualibs/" .. path
	end
	for _, path in ipairs(util_paths) do
		for k, v in pairs(require(path)) do
			zo_utils[k] = v
		end
	end
end


return zo_utils
