---@class ZOforce_util
local force_util = {build = 4}


--[[
force_util.change_techs_safely(force, techs, field_name, value)
force_util.change_enabled_techs_safely(force, techs, field_name, value)
force_util.research_techs_safely(force, techs)
force_util.research_enabled_techs_safely(force, techs)
force_util.research_techs_by_regex(force, regex)
force_util.research_enabled_techs_by_regex(force, regex)
force_util.count_techs(force): integer, integer, number
force_util.print_to_forces(forces, message, color?): boolean
force_util.get_diplomacy_stance(force, other_force): 1|0|-1
force_util.make_force_neutral(force, other_force)
force_util.make_force_enemy(force, other_force)
force_util.make_force_ally(force, other_force)
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
---@param value any
function force_util.change_enabled_techs_safely(force, techs, field_name, value)
	local technologies = force.technologies
	for i=1, #techs do
		local tech_name = techs[i]
		local tech = technologies[tech_name]
		if tech and tech.enabled then
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
---@param regex string
function force_util.research_techs_by_regex(force, regex)
	for _, tech in pairs(force.technologies) do
		if tech.name:find(regex) then
			tech.researched = true
		end
	end
end


---@param force LuaForce
---@param regex string
function force_util.research_enabled_techs_by_regex(force, regex)
	for _, tech in pairs(force.technologies) do
		if tech.name:find(regex) then
			tech.researched = true
		end
	end
end


---@param force LuaForce
---@param techs string[]
function force_util.research_enabled_techs_safely(force, techs)
	local technologies = force.technologies
	for i=1, #techs do
		local tech_name = techs[i]
		local tech = technologies[tech_name]
		if tech and tech.enabled then
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


---@param force LuaForce
---@param other_force LuaForce
---@return integer # 1: ally; 0: neutral; -1: enemy
function force_util.get_diplomacy_stance(force, other_force)
	if force.get_friend(other_force) then
		return 1
	elseif force.get_cease_fire(other_force) then
		return 0
	else
		return -1
	end
end


---@param force LuaForce
---@param other_force LuaForce
function force_util.make_force_neutral(force, other_force)
	force.set_friend(other_force, false)
	force.set_cease_fire(other_force, true)
	other_force.set_friend(force, false)
	other_force.set_cease_fire(force, true)
end


---@param force LuaForce
---@param other_force LuaForce
function force_util.make_force_enemy(force, other_force)
	force.set_friend(other_force, false)
	force.set_cease_fire(other_force, false)
	other_force.set_friend(force, false)
	other_force.set_cease_fire(force, false)
end


---@param force LuaForce
---@param other_force LuaForce
function force_util.make_force_ally(force, other_force)
	force.set_friend(other_force, true)
	force.set_cease_fire(other_force, true)
	other_force.set_friend(force, true)
	other_force.set_cease_fire(force, true)
end


return force_util
