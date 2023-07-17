
---@class ZOcoordinates_util
local coordinates_util = {build = 1}


--[[
coordinates_util.random_position_in_radius(position, radius): MapPosition
coordinates_util.get_distance(start, stop): number
]]


local random = math.random
local sqrt = math.sqrt
local cos = math.cos
local sin = math.sin
local pi2 = math.pi * 2


---@param position MapPosition
---@param radius number
---@return MapPosition
function coordinates_util.random_position_in_radius(position, radius)
	local p_x = position.x or position[1]
	local p_y = position.y or position[2]
	local pt_angle = random() * pi2
	local pt_radius_sq = random() * radius * radius
	local pt_x = sqrt(pt_radius_sq) * cos(pt_angle)
	local pt_y = sqrt(pt_radius_sq) * sin(pt_angle)
	return {x = pt_x + p_x, y = pt_y + p_y}
end


---@param start MapPosition
---@param stop MapPosition
---@return number
function coordinates_util.get_distance(start, stop)
	local start_x = start.x or start[1]
	local start_y = start.y or start[2]
	local stop_x = stop.x or stop[1]
	local stop_y = stop.y or stop[2]
	local xdiff = start_x - stop_x
	local ydiff = start_y - stop_y
	return (xdiff * xdiff + ydiff * ydiff)^0.5
end


return coordinates_util
