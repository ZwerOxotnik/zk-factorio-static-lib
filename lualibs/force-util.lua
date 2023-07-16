---@class ZOforce
local force_util = {}


---@param force LuaForce
---@param techs string[]
---@param value any
force_util.change_techs_safely = function(force, techs, field_name, value)
	local technologies = force.technologies
	for i=1, #techs do
		local tech_name = techs[i]
		local tech = technologies[tech_name]
		if tech then
			tech[field_name] = value
		end
	end
end


---@param force LuaForce
---@param techs string[]
force_util.research_techs_safely = function(force, techs)
	local technologies = force.technologies
	for i=1, #techs do
		local tech_name = techs[i]
		local tech = technologies[tech_name]
		if tech then
			tech.researched = true
		end
	end
end


return force_util
