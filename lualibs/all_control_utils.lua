---@class ZOcontrol_utils
local zo_utils = {}


do
	local util_pathes = {
		"number-util", "locale", "time-util", "lauxlib", "coordinates-util",
		"control_stage/force-util", "control_stage/entity-util",
		"control_stage/player-util", "control_stage/market-util",
		"control_stage/inventory-util", "control_stage/surface-util"
	}
	for _, path in ipairs(util_pathes) do
		for k, v in pairs(require(path)) do
			zo_utils[k] = v
		end
	end
end


return zo_utils
