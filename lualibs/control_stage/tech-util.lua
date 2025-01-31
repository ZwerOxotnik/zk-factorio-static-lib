---@class ZOtech_util
local tech_util = {build = 2}


--[[
tech_util.remove_invalid_techs(techs)
]]


---@param techs string[]
function tech_util.remove_invalid_techs(techs)
	local technology_prototypes = prototypes.technology

	for _, tech_name in pairs(techs) do
		if not technology_prototypes[tech_name] then
			techs[tech_name] = nil
		end
	end
end


return tech_util
