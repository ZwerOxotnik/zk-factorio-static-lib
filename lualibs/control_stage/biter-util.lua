---@class ZObiter_util
local biter_util = {build = 2}


--[[
biter_util.use_default_evolution()
biter_util.set_default_evolution(evolution_factor)
]]


function biter_util.use_default_evolution()
	local enemy = game.forces.enemy
	if settings.global["EAPI_start-evolution"] then
		enemy.evolution_factor = settings.global["EAPI_start-evolution"].value / 100
		return
	end

	if global.zo_default_settings then
		enemy.evolution_factor = global.zo_default_settings.default_evolution_factor or 0
		return
	end

	enemy.evolution_factor = 0
end


---@param evolution_factor double
function biter_util.set_default_evolution(evolution_factor)
	-- For https://mods.factorio.com/mod/EasyAPI
	if settings.global["EAPI_start-evolution"] then
		settings.global["EAPI_start-evolution"] = {
			value = evolution_factor * 100
		}

		local default_settings = global.zo_default_settings
		if default_settings and default_settings.default_evolution_factor then
			default_settings.default_evolution_factor = evolution_factor
		end
		return
	end

	global.zo_default_settings = global.zo_default_settings or {}
	global.zo_default_settings.default_evolution_factor = evolution_factor
end


return biter_util
