---@class ZOcontrol_utils
local zo_utils = {builds = {}}


do
	local util
	util = require("lualibs/number-util")
	zo_utils.builds["number-util"] = 1
	zo_utils.format_number = util.format_number
	util = require("lualibs/locale")
	zo_utils.builds["locale"] = 1
	zo_utils.merge_locales = util.merge_locales
	zo_utils.array_to_locale_as_new = util.array_to_locale_as_new
	zo_utils.merge_locales_as_new = util.merge_locales_as_new
	zo_utils.array_to_locale = util.array_to_locale
	zo_utils.locale_to_array = util.locale_to_array
	util = require("lualibs/time-util")
	zo_utils.builds["time-util"] = 1
	zo_utils.ticks_to_game_mm_ss = util.ticks_to_game_mm_ss
	util = require("lualibs/lauxlib")
	zo_utils.builds["lauxlib"] = 1
	zo_utils.count_levels = util.count_levels
	zo_utils.get_first_lua_func_info = util.get_first_lua_func_info
	util = require("lualibs/coordinates-util")
	zo_utils.builds["coordinates-util"] = 1
	zo_utils.get_distance = util.get_distance
	zo_utils.random_position_in_radius = util.random_position_in_radius
	util = require("lualibs/control_stage/force-util")
	zo_utils.builds["control_stage/force-util"] = 5
	zo_utils.make_force_ally = util.make_force_ally
	zo_utils.research_techs_by_items = util.research_techs_by_items
	zo_utils.make_force_enemy = util.make_force_enemy
	zo_utils.research_enabled_techs_by_items = util.research_enabled_techs_by_items
	zo_utils.print_to_forces = util.print_to_forces
	zo_utils.research_techs_safely = util.research_techs_safely
	zo_utils.change_techs_safely = util.change_techs_safely
	zo_utils.make_force_neutral = util.make_force_neutral
	zo_utils.get_diplomacy_stance = util.get_diplomacy_stance
	zo_utils.count_techs = util.count_techs
	zo_utils.research_enabled_techs_safely = util.research_enabled_techs_safely
	zo_utils.change_enabled_techs_safely = util.change_enabled_techs_safely
	zo_utils.research_enabled_techs_by_regex = util.research_enabled_techs_by_regex
	zo_utils.research_techs_by_regex = util.research_techs_by_regex
	util = require("lualibs/control_stage/entity-util")
	zo_utils.builds["control_stage/entity-util"] = 3
	zo_utils.check_entity_shield = util.check_entity_shield
	zo_utils.disconnect_not_friendly_wires = util.disconnect_not_friendly_wires
	zo_utils.disconnect_wires = util.disconnect_wires
	zo_utils.disconnect_not_own_wires = util.disconnect_not_own_wires
	zo_utils.pick_random_entity_with_heath = util.pick_random_entity_with_heath
	zo_utils.transfer_items = util.transfer_items
	util = require("lualibs/control_stage/player-util")
	zo_utils.builds["control_stage/player-util"] = 2
	zo_utils.get_resource_position_for_player = util.get_resource_position_for_player
	zo_utils.teleport_players = util.teleport_players
	zo_utils.delete_gui_for_players = util.delete_gui_for_players
	zo_utils.teleport_safely = util.teleport_safely
	zo_utils.print_to_players = util.print_to_players
	zo_utils.get_new_resource_position_by_player_resource = util.get_new_resource_position_by_player_resource
	zo_utils.create_new_character = util.create_new_character
	zo_utils.teleport_players_safely = util.teleport_players_safely
	zo_utils.emulate_message_to_server = util.emulate_message_to_server
	zo_utils.delete_character = util.delete_character
	util = require("lualibs/control_stage/market-util")
	zo_utils.builds["control_stage/market-util"] = 1
	zo_utils.validation_rules = util.validation_rules
	zo_utils.add_offers_safely = util.add_offers_safely
	zo_utils.add_offer_safely = util.add_offer_safely
	zo_utils.add_offers = util.add_offers
	util = require("lualibs/control_stage/inventory-util")
	zo_utils.builds["control_stage/inventory-util"] = 1
	zo_utils.copy_inventory_items = util.copy_inventory_items
	zo_utils.copy_inventory_items_to_player = util.copy_inventory_items_to_player
	zo_utils.remove_items_safely = util.remove_items_safely
	zo_utils.copy_inventory_items_safely = util.copy_inventory_items_safely
	zo_utils.insert_items_safely = util.insert_items_safely
	util = require("lualibs/control_stage/surface-util")
	zo_utils.builds["control_stage/surface-util"] = 1
	zo_utils.flip_entities_horizontally = util.flip_entities_horizontally
	zo_utils.flip_entities_vertically_and_horizontally = util.flip_entities_vertically_and_horizontally
	zo_utils.flip_entities_vertically = util.flip_entities_vertically
	zo_utils.flip_tiles_horizontally = util.flip_tiles_horizontally
	zo_utils.fill_box_with_resources = util.fill_box_with_resources
	zo_utils.flip_tiles_vertically = util.flip_tiles_vertically
	zo_utils.fill_box_with_tiles = util.fill_box_with_tiles
	zo_utils.fill_horizontal_line_with_tiles = util.fill_horizontal_line_with_tiles
	zo_utils.fill_box_with_resources_safely = util.fill_box_with_resources_safely
	zo_utils.flip_tiles_vertically_and_horizontally = util.flip_tiles_vertically_and_horizontally
end
zo_utils.build = 18


return zo_utils

