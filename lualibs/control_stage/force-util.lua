---@class ZOforce_util
local force_util = {build = 10}


--[[
force_util.get_forces_by_relations(target_force): LuaForce[], LuaForce[], LuaForce[] -- enemy forces, neutral forces, ally forces
force_util.get_enemy_forces(force)
force_util.change_techs_safely(force, techs, field_name, value)
force_util.change_enabled_techs_safely(force, techs, field_name, value)
force_util.has_researched_all(force, techs): boolean
force_util.has_researched_all(force, techs, is_return_rest_by_not_researched_techs): boolean, rest_techs?
force_util.has_researched_any(force, techs): boolean
force_util.research_techs_safely(force, techs)
force_util.research_enabled_techs_safely(force, techs)
force_util.research_techs_by_regex(force, regex)
force_util.research_enabled_techs_by_regex(force, regex)
force_util.research_techs_by_items(force, items, max_research_unit_count?)
force_util.research_enabled_techs_by_items(force, items, max_research_unit_count?)
force_util.count_techs(force): integer, integer, number
force_util.print_to_forces(forces, message, color?): boolean
force_util.get_diplomacy_stance(force, other_force): 1|0|-1
force_util.make_force_neutral(force, other_force)
force_util.make_force_enemy(force, other_force)
force_util.make_force_ally(force, other_force)
]]


---@param target_force LuaForce
---@return LuaForce[], LuaForce[], LuaForce[] # enemy forces, neutral forces, ally forces
function force_util.get_forces_by_relations(target_force)
	---@type LuaForce[]
	local enemy_forces = {nil}
	---@type LuaForce[]
	local neutral_forces = {nil}
	---@type LuaForce[]
	local ally_forces = {}

	for _, force in pairs(game.forces) do
		if not (force.valid and target_force ~= force) then
			goto continue
		end
		if target_force.is_enemy(force) then
			enemy_forces[#enemy_forces+1] = force
		elseif target_force.get_friend(force) then -- tricky case
			ally_forces[#ally_forces+1] = force
		else
			neutral_forces[#neutral_forces+1] = force
		end
	    ::continue::
	end

	return enemy_forces, neutral_forces, ally_forces
end


---@param target_force LuaForce
---@return LuaForce[]
function force_util.get_enemy_forces(target_force)
	local enemy_forces = {}

	for _, force in pairs(game.forces) do
		if not (force.valid and target_force ~= force) then
			goto continue
		end
		if target_force.is_enemy(force) then
			enemy_forces[#enemy_forces+1] = force
		end
	    ::continue::
	end

	return enemy_forces
end


---@param force LuaForce
---@param techs string[]
---@param value any
function force_util.change_techs_safely(force, techs, field_name, value)
	local technologies = force.technologies
	for _, tech_name in pairs(techs) do
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
	for _, tech_name in pairs(techs) do
		local tech = technologies[tech_name]
		if tech and tech.enabled then
			tech[field_name] = value
		end
	end
end


---@param force LuaForce
---@param techs string[]
---@return boolean
---@overload fun(force: LuaForce, techs: string[], is_return_rest_by_not_researched_techs: boolean): boolean, string[]
function force_util.has_researched_all(force, techs, is_return_rest_by_not_researched_techs)
	local technologies = force.technologies

	if is_return_rest_by_not_researched_techs == nil then
		for _, tech_name in pairs(techs) do
			local tech = technologies[tech_name]
			if not (tech and tech.enabled) then
				return false
			end
		end

		return true
	end

	if is_return_rest_by_not_researched_techs then
		local has_researched_all = true
		local not_researched_techs
		for _, tech_name in pairs(techs) do
			local tech = technologies[tech_name]
			if not (tech and tech.enabled) then
				not_researched_techs = not_researched_techs or {}
				not_researched_techs[#not_researched_techs+1] = tech_name
				has_researched_all = false
			end
		end

		return has_researched_all, not_researched_techs
	else
		local has_researched_all = true
		local researched_techs
		for _, tech_name in pairs(techs) do
			local tech = technologies[tech_name]
			if not (tech and tech.enabled) then
				researched_techs = researched_techs or {}
				researched_techs[#researched_techs+1] = tech_name
				has_researched_all = false
			end
		end

		return has_researched_all, researched_techs
	end
end


---@param force LuaForce
---@param techs string[]
---@return boolean
function force_util.has_researched_any(force, techs)
	local technologies = force.technologies
	for _, tech_name in pairs(techs) do
		local tech = technologies[tech_name]
		if tech and tech.enabled then
			return true
		end
	end

	return false
end


---@param force LuaForce
---@param techs string[]
function force_util.research_techs_safely(force, techs)
	local technologies = force.technologies
	for _, tech_name in pairs(techs) do
		local tech = technologies[tech_name]
		if tech then
			tech.researched = true
		end
	end
end


---@param force LuaForce
---@param techs string[]
function force_util.research_enabled_techs_safely(force, techs)
	local technologies = force.technologies
	for _, tech_name in pairs(techs) do
		local tech = technologies[tech_name]
		if tech and tech.enabled then
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
		if tech.name:find(regex) and tech.enabled then
			tech.researched = true
		end
	end
end


---@param force LuaForce
---@param items string[]
---@param max_research_unit_count integer?
function force_util.research_techs_by_items(force, items, max_research_unit_count)
	for _, tech in pairs(force.technologies) do
		-- If this technology has no ingredients and has a research trigger, don't research it.
		-- A technology that has a research trigger may get researched later by using research_recursive().
		if #tech.research_unit_ingredients == 0 and tech.prototype.research_trigger ~= nil then
			goto skip_tech
		end
		for _, ingredient in pairs(tech.research_unit_ingredients) do
			if not (ingredient.type == nil or ingredient.type == "item") then
				goto skip_tech
			end
			local is_valid = false
			local ingredient_name = ingredient.name
			local unit_count = tech.research_unit_count
			for _, item_name in pairs(items) do
				if item_name == ingredient_name and (max_research_unit_count == nil or unit_count <= max_research_unit_count) then
					is_valid = true
					break
				end
			end
			if not is_valid then
				goto skip_tech
			end
		end
		tech.research_recursive()
		:: skip_tech ::
	end
end


---@param force LuaForce
---@param items string[]
---@param max_research_unit_count integer?
function force_util.research_enabled_techs_by_items(force, items, max_research_unit_count)
	for _, tech in pairs(force.technologies) do
		-- If this technology has no ingredients and has a research trigger, don't research it.
		-- A technology that has a research trigger may get researched later by using research_recursive().
		if #tech.research_unit_ingredients == 0 and tech.prototype.research_trigger ~= nil then
			goto skip_tech
		end
		if tech.enabled then
			for _, ingredient in pairs(tech.research_unit_ingredients) do
				if not (ingredient.type == nil or ingredient.type == "item") then
					goto skip_tech
				end
				local is_valid = false
				local ingredient_name = ingredient.name
				local unit_count = tech.research_unit_count
				for _, item_name in pairs(items) do
					if item_name == ingredient_name and (max_research_unit_count == nil or unit_count <= max_research_unit_count) then
						is_valid = true
						break
					end
				end
				if not is_valid then
					goto skip_tech
				end
			end
			tech.research_recursive()
			:: skip_tech ::
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
		total_techs = total_techs + 1
		if tech.researched then
			researched_techs = researched_techs + 1
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
