---@class ZOcontrol_utils
local zo_utils = {}


do
	local util_pathes = {
		"force-util", "locale", "entity-util", "player-util",
		"market-util", "time-util", "lauxlib", "inventory-util",
		"surface-util"
	}
	for _, path in ipairs(util_pathes) do
		for k, v in pairs(require(path)) do
			zo_utils[k] = v
		end
	end
end


return zo_utils
