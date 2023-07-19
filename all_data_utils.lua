---@class ZOdata_utils
local zo_utils = {}


do
	local util
	util = require("lualibs/locale")
	zo_utils.array_to_locale = util.array_to_locale
	zo_utils.merge_locales = util.merge_locales
	zo_utils.merge_locales_as_new = util.merge_locales_as_new
	zo_utils.locale_to_array = util.locale_to_array
	zo_utils.array_to_locale_as_new = util.array_to_locale_as_new
	util = require("lualibs/time-util")
	zo_utils.ticks_to_game_mm_ss = util.ticks_to_game_mm_ss
	util = require("lualibs/lauxlib")
	zo_utils.count_levels = util.count_levels
	zo_utils.get_first_lua_func_info = util.get_first_lua_func_info
	util = require("lualibs/number-util")
	zo_utils.format_number = util.format_number
	util = require("lualibs/coordinates-util")
	zo_utils.random_position_in_radius = util.random_position_in_radius
	zo_utils.get_distance = util.get_distance
end
zo_utils.build = 5


return zo_utils

