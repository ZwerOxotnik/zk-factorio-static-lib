---@class ZOforce_util
local force_util = {build = 1}


--[[
force_util.change_techs_safely(force, techs, field_name, value)
force_util.research_techs_safely(force, techs)
force_util.count_techs(force): integer, integer, number
force_util.print_to_forces(forces, message, color?): boolean
]]


---@param force LuaForce
---@param techs string[]
---@param value any
function force_util.change_techs_safely(force, techs, field_name, value)
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
function force_util.research_techs_safely(force, techs)
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
function force_util.count_techs(force)
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



---@param forces table<any, LuaForce>
---@param message table|string
---@param color table?
---@return boolean
function force_util.print_to_forces(forces, message, color)
	if message == nil then
		return false
	end

	for _, force in pairs(forces) do
		if force.valid then
			force.print(message, color)
		end
	end
	return true
end


return force_util
