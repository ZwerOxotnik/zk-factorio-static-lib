---@class ZOtime
local time_util = {build = 1}


--[[
time_util.ticks_to_game_mm_ss(ticks, format="mm:ss"): string
]]


local floor = math.floor


---@param ticks integer
---@param format string? # "mm:ss" by default
---@return string
function time_util.ticks_to_game_mm_ss(ticks, format)
	format = format or "%s:%s"
	local ticks_in_1_second = 60 * game.speed
	local ticks_in_1_minute = 60 * ticks_in_1_second
	local mins = floor(ticks / ticks_in_1_minute)
	local seconds = floor((ticks - (mins * ticks_in_1_minute)) / ticks_in_1_second)

	if mins < 10 then
		if mins == 0 then
			mins = "00"
		else
			mins = "0" .. mins
		end
	end

	if seconds < 10 then
		if seconds == 0 then
			seconds = "00"
		else
			seconds = "0" .. seconds
		end
	end

	return string.format(format, mins, seconds)
end


return time_util
