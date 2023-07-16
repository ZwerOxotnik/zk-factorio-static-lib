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


---@param force LuaForce
---@return integer, integer, number # researched_techs, total_techs, tech_ratio
force_util.count_techs = function(force, techs)
	local researched_techs = 0
	local total_techs = 0

	local technologies = force.technologies
	for _, tech in pairs(technologies) do
		if tech.research_unit_count_formula == nil and not tech.upgrade then
			total_techs = total_techs + 1
			if tech.researched then
				researched_techs = researched_techs + 1
			end
		end
	end

	return researched_techs, total_techs, researched_techs / total_techs
end


return force_util
