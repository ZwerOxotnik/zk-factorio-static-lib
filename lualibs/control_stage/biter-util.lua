---@class ZObiter_util
local biter_util = {build = 3}


--[[
biter_util.use_default_evolution(surface=1)
biter_util.set_default_evolution(evolution_factor)
]]


---@param surface LuaSurface | uint
function biter_util.use_default_evolution(surface)
	local enemy = game.forces.enemy
	if settings.global["EAPI_start-evolution"] then
		enemy.set_evolution_factor(settings.global["EAPI_start-evolution"].value / 100, surface)
		return
	end

	if storage.zo_default_settings then
		enemy.set_evolution_factor((storage.zo_default_settings.default_evolution_factor or 0), surface)
		return
	end

	enemy.set_evolution_factor(0, surface)
end


---@param evolution_factor double
function biter_util.set_default_evolution(evolution_factor)
	-- For https://mods.factorio.com/mod/EasyAPI
	if settings.global["EAPI_start-evolution"] then
		settings.global["EAPI_start-evolution"] = {
			value = evolution_factor * 100
		}

		local default_settings = storage.zo_default_settings
		if default_settings and default_settings.default_evolution_factor then
			default_settings.default_evolution_factor = evolution_factor
		end
		return
	end

	storage.zo_default_settings = storage.zo_default_settings or {}
	storage.zo_default_settings.default_evolution_factor = evolution_factor
end


return biter_util
