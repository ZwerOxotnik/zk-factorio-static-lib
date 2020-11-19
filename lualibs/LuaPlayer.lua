local module = {}

module.get_new_resource_position_by_player_resource = function(player, resource)
	local resource_reach_distance = player.resource_reach_distance
	if resource_reach_distance > 40 then
		resource_reach_distance = 40
	end

	local settings = {position = player.position, radius = resource_reach_distance, name = resource.name, limit = 2}
	local resources = player.surface.find_entities_filtered(settings)
	for _, new_resource in pairs(resources) do
		if resource ~= new_resource then
			return new_resource.position
		end
	end
	return
end

module.get_resource_position_for_player = function(player)
	local resource_reach_distance = player.resource_reach_distance
	if resource_reach_distance > 40 then
		resource_reach_distance = 40
	end

	local settings = {position = player.position, radius = resource_reach_distance, type = "resource", limit = 1}
	local new_resource = player.surface.find_entities_filtered(settings)[1]
	if new_resource then
        return new_resource.position
    else
        return
	end
end

return module
