---@class ZOdata_utils
local zo_utils = {builds = {}}


do
	local util
	util = require("lualibs/locale")
	zo_utils.builds["locale"] = 1
	zo_utils.locale_to_array = util.locale_to_array
	zo_utils.array_to_locale = util.array_to_locale
	zo_utils.merge_locales_as_new = util.merge_locales_as_new
	zo_utils.array_to_locale_as_new = util.array_to_locale_as_new
	zo_utils.merge_locales = util.merge_locales
	util = require("lualibs/time-util")
	zo_utils.builds["time-util"] = 1
	zo_utils.ticks_to_game_mm_ss = util.ticks_to_game_mm_ss
	util = require("lualibs/lauxlib")
	zo_utils.builds["lauxlib"] = 1
	zo_utils.get_first_lua_func_info = util.get_first_lua_func_info
	zo_utils.count_levels = util.count_levels
	util = require("lualibs/number-util")
	zo_utils.builds["number-util"] = 1
	zo_utils.format_number = util.format_number
	util = require("lualibs/coordinates-util")
	zo_utils.builds["coordinates-util"] = 1
	zo_utils.get_distance = util.get_distance
	zo_utils.random_position_in_radius = util.random_position_in_radius
	util = require("lualibs/rich-text-util")
	zo_utils.builds["rich-text-util"] = 1
	zo_utils.find_achievement = util.find_achievement
	zo_utils.find_tile = util.find_tile
	zo_utils.find_item_group = util.find_item_group
	zo_utils.find_virtual_signal = util.find_virtual_signal
	zo_utils.find_recipe = util.find_recipe
	zo_utils.find_tooltip = util.find_tooltip
	zo_utils.find_gui = util.find_gui
	zo_utils.find_armor = util.find_armor
	zo_utils.find_gps = util.find_gps
	zo_utils.find_color = util.find_color
	zo_utils.find_font = util.find_font
	zo_utils.find_train = util.find_train
	zo_utils.find_fluid = util.find_fluid
	zo_utils.find_technology = util.find_technology
	zo_utils.find_special_item = util.find_special_item
	zo_utils.find_train_stop = util.find_train_stop
	zo_utils.find_item = util.find_item
end
zo_utils.build = 6


return zo_utils

