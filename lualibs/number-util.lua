---@class ZOnumber_util
local number_util = {build = 1}


--[[
number_util.format_number(number): string
]]


local format = string.format


-- TODO: add localization
---@param number number
---@return string
function number_util.format_number(number)
	if number < 1e3 then
		return tostring(number)
	elseif number < 1e6 then
		return format("%.1fK", number / 1e3)
	elseif number < 1e9 then
		return format("%.1fM", number / 1e6)
	elseif number < 1e12 then
		return format("%.1fB", number / 1e9)
	end
	return format("%.1fT", number / 1e12)
end


return number_util
