--- Quite simple semi-agnostic library to handle GUIs in almost data-driven manner, fixing missing sprites, styles, same names.
--- Turn zk-lib on to get better icons, functions, styles.
--- It doesn't use "global" yet.
--- WARNING: events "on_*" as fields for "children" weren't implemented yet
--- WARNING: DO NOT CREATE/CHANGE TEMPLATES DURING RUNTIME!!!


--[[
GuiTemplater.create(init_data: ZOGuiTemplater.data): ZOGuiTemplate
GuiTemplater.create_expander_template(init_data: ZOGuiTemplater.data, expander_name: string, caption: string|table, is_collapsed=false): ZOGuiExpanderTemplate
GuiTemplater.create_screen_window(player: LuaPlayer, frame_name: string?, title: string|table?): content_frameLuaGuiElement, main_frame: LuaGuiElement, top_flow: LuaGuiElement
GuiTemplater.create_hollow_screen_window(player: LuaPlayer, frame_name: string?, title: string|table?): content_flow: LuaGuiElement, main_frame: LuaGuiElement, top_flow: LuaGuiElement
GuiTemplater.create_screen_frame(player: LuaPlayer, frame_name: string?, title: string|table?): content_frameLuaGuiElement, main_frame: LuaGuiElement, top_flow: LuaGuiElement
GuiTemplater.create_hollow_screen_frame(player: LuaPlayer, frame_name: string?, title: string|table?): content_flow: LuaGuiElement, main_frame: LuaGuiElement, top_flow: LuaGuiElement
GuiTemplater.make_table_as_list(tableGUI: LuaGuiElement, minimal_column_width: integer?): LuaGuiElement
GuiTemplater.create_top_relative_frame(gui: LuaGuiElement, name: string?, anchor: GuiAnchor):   LuaGuiElement, LuaGuiElement
GuiTemplater.create_left_relative_frame(gui: LuaGuiElement, name: string?, anchor: GuiAnchor):  LuaGuiElement, LuaGuiElement
GuiTemplater.create_right_relative_frame(gui: LuaGuiElement, name: string?, anchor: GuiAnchor): LuaGuiElement, LuaGuiElement
GuiTemplater.create_slot_button(gui: LuaGuiElement, sprite_path: string, name: string?): LuaGuiElement
GuiTemplater.create_menu(player: LuaPlayer?, trigger_gui: LuaGuiElement, frame_name: string, offset=30): LuaGuiElement?
GuiTemplater.create_GUI_safely(gui: LuaGuiElement, element: LuaGuiElement.add_param, player: LuaPlayer?): boolean, LuaGuiElement|string
GuiTemplater.get_location_by_percentage(player: LuaPlayer, x: number, y: number, offset_x: number?, offset_y: number?): GuiLocation.0
GuiTemplater.get_location_by_percentage_with_offset(player: LuaPlayer, x: number, y: number, offset_x: number?, offset_y: number?): GuiLocation.0


--Requires zk-lib!
GuiTemplater.create_horizontal_transparent_frame(player: LuaPlayer, frame_name: string?, location: GuiLocation?): transparent_frame: LuaGuiElement, top_frame: LuaGuiElement
GuiTemplater.create_vertical_transparent_frame(player: LuaPlayer, frame_name: string?, location: GuiLocation?): transparent_frame: LuaGuiElement, top_frame: LuaGuiElement
--Requires zk-lib >= 0.15.7!
GuiTemplater.create_counter_gui(gui: LuaGuiElement, name: string, value: number|string?, allow_decimal=false, allow_negative=false): textfield: LuaGuiElement
GuiTemplater.create_nerd_action_button24(gui: LuaGuiElement, symbol: string?, name: string?): LuaGuiElement
GuiTemplater.create_nerd_action_button40(gui: LuaGuiElement, symbol: string?, name: string?): LuaGuiElement
]]


local GuiTemplater = {build = 27}

---@type table<integer, table<string, ZOGuiTemplate.event_func>>
GuiTemplater.events_GUIs = {
	[defines.events.on_gui_click] = {
		[script.mod_name .. "_close"] = function(element, player, event)
			element.parent.parent.destroy()
		end
	}
}
local __events_GUIs = GuiTemplater.events_GUIs
local __on_click_GUIs = __events_GUIs[defines.events.on_gui_click]

-- WARNING: DO NOT CHANGE "raise_error" DURING RUNTIME!!!
GuiTemplater.raise_error = false
-- Prevents crashes during events\
-- WARNING: DO NOT CHANGE "safe_mode" DURING RUNTIME!!!
GuiTemplater.safe_mode   = true
GuiTemplater.print_errors_to_admins = true
---@type table<uint, fun(event: EventData)>
GuiTemplater.events = {
	---@param event EventData.on_player_created
	[defines.events.on_player_created] = function(event)
		local player = game.get_player(event.player_index)
		if not (player and player.valid) then return end

		local templates_for_new_players = GuiTemplater.templates_for_new_players
		for _, template in pairs(templates_for_new_players) do
			local gui = player.gui[template.create_for_new_players]
			template.createGUIs(gui)
		end
	end,
	---@param event EventData.on_player_joined_game
	[defines.events.on_player_joined_game] = function(event)
		local player = game.get_player(event.player_index)
		if not (player and player.valid) then return end

		local templates_for_joined_players = GuiTemplater.templates_for_joined_players
		for _, template in pairs(templates_for_joined_players) do
			local gui = player.gui[template.create_for_joined_players]
			template.createGUIs(gui)
		end
	end,
	---@param event EventData.on_player_left_game
	[defines.events.on_player_left_game] = function(event)
		local player = game.get_player(event.player_index)
		if not (player and player.valid) then return end

		local templates_for_left_players = GuiTemplater.templates_for_left_players
		for _, template in pairs(templates_for_left_players) do
			local gui = player.gui[template.destroy_for_left_players]
			template.destroyGUIs(gui)
		end
	end,
	---@param event EventData.on_gui_click
	[defines.events.on_gui_click] = function(event)
		local element = event.element
		if not (element and element.valid) then return end

		local f = __on_click_GUIs[element.name]
		if f then
			local player = game.get_player(event.player_index)
			if not GuiTemplater.safe_mode then
				f(element, player, event)
			else
				local is_ok, result = pcall(f, element, player, event)
				if not is_ok then
					GuiTemplater._log(result, player)
				end
			end
		end
	end,
}
---@type ZOGuiTemplate[]
GuiTemplater.templates_for_new_players = {}
---@type ZOGuiTemplate[]
GuiTemplater.templates_for_joined_players = {}
---@type ZOGuiTemplate[]
GuiTemplater.templates_for_left_players = {}


---@alias ZOGuiTemplate.event_func fun(element: LuaGuiElement, player: LuaPlayer, event: EventData)


---@class ZOGuiTemplater.event: table
---@field [1] string|uint # event id/name
---@field [2] ZOGuiTemplate.event_func


---@alias rootGUIname
---| "top"
---| "left"
---| "center"
---| "goal"
---| "screen"


---@class ZOGuiTemplater.data: table
---@field element LuaGuiElement.add_param
---@field on_create? fun(gui: LuaGuiElement) # WARNING: works only for top element
---@field on_finish? fun(gui: LuaGuiElement) # WARNING: works only for top element
---@field on_pre_destroy? fun(gui: LuaGuiElement) # WARNING: works only for top element
---@field on_pre_clear?   fun(gui: LuaGuiElement) # WARNING: works only for top element
---@field event?  ZOGuiTemplater.event
---@field events? ZOGuiTemplater.event[]
---@field children? ZOGuiTemplater.child_data[]
---@field style? table<string, any> # see https://lua-api.factorio.com/latest/classes/LuaStyle.html
---@field admin_only?  boolean # Creates GUI if player is admin
---@field raise_error? boolean
---@field create_for_new_players?    rootGUIname # WARNING: works only for top element
---@field create_for_joined_players? rootGUIname # WARNING: works only for top element
---@field destroy_for_left_players?  rootGUIname # WARNING: works only for top element
---@field on_gui_selection_state_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_selection_state_changed)
---@field on_gui_checked_state_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_checked_state_changed)
---@field on_gui_click? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_click)
---@field on_gui_closed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_closed)
---@field on_gui_confirmed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_confirmed)
---@field on_gui_elem_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_elem_changed)
---@field on_gui_hover? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_hover)
---@field on_gui_leave? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_leave)
---@field on_gui_location_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_location_changed)
---@field on_gui_opened? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_opened)
---@field on_gui_selected_tab_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_selected_tab_changed)
---@field on_gui_switch_state_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_switch_state_changed)
---@field on_gui_text_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_text_changed)
---@field on_gui_value_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_value_changed)


---@class ZOGuiTemplater.child_data: ZOGuiTemplater.data
---@field on_create      nil
---@field on_finish      nil
---@field on_pre_destroy nil
---@field on_pre_clear   nil


---@class ZOGuiTemplater.collapse_data: table
---@field element LuaGuiElement.add_param?
---@field on_create? fun(gui: LuaGuiElement) # WARNING: works only for top element
---@field on_finish? fun(gui: LuaGuiElement) # WARNING: works only for top element
---@field on_pre_destroy? fun(gui: LuaGuiElement) # WARNING: works only for top element
---@field on_pre_clear?   fun(gui: LuaGuiElement) # WARNING: works only for top element
---@field event?  ZOGuiTemplater.event
---@field events? ZOGuiTemplater.event[]
---@field children? ZOGuiTemplater.collapse_child_data[]
---@field style? table<string, any> # see https://lua-api.factorio.com/latest/classes/LuaStyle.html
---@field admin_only?  boolean # Creates GUI if player is admin
---@field raise_error? boolean
---@field on_gui_selection_state_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_selection_state_changed)
---@field on_gui_checked_state_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_checked_state_changed)
---@field on_gui_click? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_click)
---@field on_gui_closed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_closed)
---@field on_gui_confirmed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_confirmed)
---@field on_gui_elem_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_elem_changed)
---@field on_gui_hover? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_hover)
---@field on_gui_leave? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_leave)
---@field on_gui_location_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_location_changed)
---@field on_gui_opened? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_opened)
---@field on_gui_selected_tab_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_selected_tab_changed)
---@field on_gui_switch_state_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_switch_state_changed)
---@field on_gui_text_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_text_changed)
---@field on_gui_value_changed? ZOGuiTemplate.event_func # [Documentation](https://lua-api.factorio.com/latest/events.html#on_gui_value_changed)


---@class ZOGuiTemplater.collapse_child_data: ZOGuiTemplater.collapse_data
---@field element LuaGuiElement.add_param
---@field on_create      nil
---@field on_finish      nil
---@field on_pre_destroy nil
---@field on_pre_clear   nil


---@class ZOGuiTemplate: ZOGuiTemplater.data
---@field createGUIs  fun(gui: LuaGuiElement?): boolean
---@field destroyGUIs fun(gui: LuaGuiElement?): boolean -- WARNING: It doesn't trigger child events yet
---@field clear       fun(gui: LuaGuiElement?): boolean -- WARNING: It doesn't trigger child events yet


---@class ZOGuiExpanderTemplate: ZOGuiTemplater.data
---@field createGUIs  fun(gui: LuaGuiElement?): boolean


GuiTemplater.drag_handler  = {type = "empty-widget", style = "draggable_space"}
GuiTemplater.empty_widget  = {type = "empty-widget"}
GuiTemplater.flow          = {type = "flow", direction = "horizontal"}
GuiTemplater.vertical_flow = {type = "flow", direction = "vertical"}

GuiTemplater.buttons = {
	confirm_button = {style = "confirm_button", caption = {"gui.confirm"}},
	new_game_header_list_box_item = {style = "new_game_header_list_box_item"},
	menu_button_continue = {style = "menu_button_continue"},
	cancel_button  = {caption = {"gui-mod-settings.cancel"}},
	rounded_button = {style = "rounded_button"},
	mini_tool_button_red = {style = "mini_tool_button_red"},
	red_back_button = {style = "red_back_button"},
	red_button = {style = "red_button"},
	tool_button = {style = "tool_button"},
	back_button = {style = "back_button"},
	plus = {style = "frame_action_button"}, -- from zk-lib
	missing_icon = {sprite = "utility/missing_icon"},
	cross_select = {sprite = "utility/cross_select"},
	crafting_machine_recipe_not_unlocked = {sprite = "utility/crafting_machine_recipe_not_unlocked"},
	prohibit = {sprite = "utility/crafting_machine_recipe_not_unlocked"},
	favourite_server_icon = {sprite = "utility/favourite_server_icon"},
	factorio_icon = {sprite = "utility/favourite_server_icon"},
	custom_tag_in_map_view = {sprite = "utility/custom_tag_in_map_view"},
	yellow_arrow_up = {sprite = "utility/rail_planner_indication_arrow_too_far"},
	green_arrow_up  = {sprite = "utility/rail_planner_indication_arrow"},
	blue_arrow_up   = {sprite = "utility/fluid_indication_arrow"},
	questionmark = {sprite = "utility/questionmark"},
	waiting_icon = {sprite = "utility/multiplayer_waiting_icon"},
	scripting_editor_icon = {sprite = "utility/scripting_editor_icon"},
	clone_editor_icon   = {sprite = "utility/clone_editor_icon"},
	upgrade_blueprint   = {sprite = "utility/upgrade_blueprint"},
	deconstruction_mark = {sprite = "utility/deconstruction_mark"},
	quantity_multiplier = {sprite = "quantity-multiplier"},
	too_far_from_roboport_icon = {sprite = "utility/too_far_from_roboport_icon"},
	destroyed_icon   = {sprite = "utility/destroyed_icon"},
	recharge_icon    = {sprite = "utility/recharge_icon"},
	electricity_icon = {sprite = "utility/electricity_icon"},
	change_recipe    = {sprite = "utility/change_recipe"},
	gears            = {sprite = "utility/change_recipe"},
	thin_right_arrow = {sprite = "utility/right_arrow"},
	thin_left_arrow  = {sprite = "utility/left_arrow"},
	variations_tool  = {sprite = "utility/variations_tool_icon"},
	equipment_grid   = {sprite = "utility/equipment_grid"},
	not_available    = {sprite = "utility/not_available"},
	restart_required = {sprite = "restart_required"},
	player       = {sprite = "utility/player_force_icon"},
	too_far      = {sprite = "utility/too_far"},
	danger_icon  = {sprite = "utility/danger_icon"},
	warning_icon = {sprite = "utility/warning_icon"},
	fluid_icon   = {sprite = "utility/fluid_icon"},
	ammo_icon    = {sprite = "utility/ammo_icon"},
	fuel_icon    = {sprite = "utility/fuel_icon"},
	time_editor  = {sprite = "utility/time_editor_icon"},
	surfaces     = {sprite = "utility/surface_editor_icon"},
	resources    = {sprite = "utility/resource_editor_icon"},
	sync_mods    = {sprite = "utility/sync_mods"},
	tiles        = {sprite = "utility/tile_editor_icon"},
	paint_bucket = {sprite = "utility/paint_bucket_icon"},
	go_to_arrow  = {sprite = "utility/go_to_arrow"},
	export_slot  = {sprite = "utility/export_slot"},
	tick_once    = {sprite = "utility/tick_once"},
	tick_sixty   = {sprite = "utility/tick_sixty"},
	tick_custom  = {sprite = "utility/tick_custom"},
	speed_down   = {sprite = "utility/speed_down"},
	speed_up     = {sprite = "utility/speed_up"},
	book         = {sprite = "utility/custom_tag_icon"},
	gps_map      = {sprite = "utility/gps_map_icon"},
	rename       = {sprite = "utility/rename_icon_normal"},
	preset       = {sprite = "utility/preset"},
	center       = {sprite = "utility/center"},
	play         = {sprite = "utility/play"},
	pause        = {sprite = "utility/pause"},
	brush        = {sprite = "utility/brush_icon"},
	clone        = {sprite = "utility/clone"},
	spray        = {sprite = "utility/spray_icon"},
	enter        = {sprite = "utility/enter"},
	clock        = {sprite = "utility/clock"},
	area         = {sprite = "utility/area_icon"},
	fire         = {sprite = "utility/heat_exchange_indication"},
	add          = {sprite = "utility/add"},
	map          = {sprite = "utility/map"},
	status_not_working = {style = "frame_action_button", sprite = "utility/status_not_working"},
	status_working = {style = "frame_action_button", sprite = "utility/status_working"},
	status_yellow  = {style = "frame_action_button", sprite = "utility/status_yellow"},
	alert_arrow    = {style = "frame_action_button", sprite = "utility/alert_arrow"},
	notification   = {style = "frame_action_button", sprite = "utility/notification"},
	color_picker   = {style = "frame_action_button", sprite = "utility/color_picker"},
	close_fat      = {style = "frame_action_button", sprite = "utility/close_fat"},
	downloading    = {style = "frame_action_button", sprite = "utility/downloading_white"},
	dropdown       = {style = "frame_action_button", sprite = "utility/dropdown"},
	shuffle        = {style = "frame_action_button", sprite = "utility/shuffle"},
	copy           = {style = "frame_action_button", sprite = "utility/copy"},
	reassign       = {style = "frame_action_button", sprite = "utility/reassign"},
	list_view      = {style = "frame_action_button", sprite = "utility/list_view"},
	grid_view      = {style = "frame_action_button", sprite = "utility/grid_view"},
	bookmark       = {style = "frame_action_button", sprite = "utility/bookmark"},
	export         = {style = "frame_action_button", sprite = "utility/export"},
	refresh        = {style = "frame_action_button", sprite = "refresh"},
	not_played_yet_dark_green = {style = "frame_action_button", sprite = "utility/not_played_yet_dark_green"},
	not_played_yet_green  = {style = "frame_action_button", sprite = "utility/not_played_yet_green"},
	close_map_preview     = {style = "frame_action_button", sprite = "utility/close_map_preview"},
	check_mark_green      = {style = "frame_action_button", sprite = "utility/check_mark_green"},
	check_mark_dark_green = {style = "frame_action_button", sprite = "utility/check_mark_dark_green"},
	_close = {
		sprite = "utility/close",
		hovered_sprite = "utility/close_black",
		clicked_sprite = "utility/close_black",
		style = "frame_action_button",
		name = script.mod_name .. "_close"
	},
	close = {
		sprite = "utility/close",
		hovered_sprite = "utility/close_black",
		clicked_sprite = "utility/close_black",
		style = "frame_action_button",
		type = "sprite-button"
	},
	confirm = { -- TODO: improve style
		style = "frame_action_button",
		sprite = "utility/confirm_slot",
	},
	side_menu_menu = {
		sprite = "utility/side_menu_menu_icon",
		hovered_sprite = "utility/side_menu_menu_hover_icon",
		clicked_sprite = "utility/side_menu_menu_hover_icon",
		style = "slot_button"
	},
	hand = {
		style = "slot_button",
		sprite = "utility/hand",
		hovered_sprite = "utility/hand_black",
		clicked_sprite = "utility/hand_black"
	},
	search = {
		sprite = "utility/search",
		hovered_sprite = "utility/search",
		clicked_sprite = "utility/search"
	},
	trash = {
		style = "frame_action_button",
		sprite = "utility/trash_white",
		hovered_sprite = "utility/trash",
		clicked_sprite = "utility/trash"
	},
	map_exchange_string = { -- white sprite from zk-lib
		style = "frame_action_button",
		hovered_sprite = "utility/map_exchange_string",
		clicked_sprite = "utility/map_exchange_string"
	},
	lua_snippet_tool = {
		style = "frame_action_button",
		sprite = "lua_snippet_tool_icon_white",
		hovered_sprite = "utility/lua_snippet_tool_icon",
		clicked_sprite = "utility/lua_snippet_tool_icon"
	},
	import = {
		sprite = "utility/import",
		tooltip = {"gui-blueprint-library.import-string"},
		style = "frame_action_button"
	},
	import_slot = {
		sprite = "utility/import_slot",
		tooltip = {"gui-blueprint-library.import-string"},
		style = "frame_action_button"
	},
	reset = {
		style = "frame_action_button",
		sprite = "utility/reset_white",
		hovered_sprite = "utility/reset",
		clicked_sprite = "utility/reset"
	},
	warning = { -- TODO: find similar style to "frame_action_button"
		sprite = "utility/warning_white",
		hovered_sprite = "utility/warning",
		clicked_sprite = "utility/warning"
	},
	select = {
		style = "frame_action_button",
		sprite = "utility/select_icon_white",
		hovered_sprite = "utility/select_icon_black",
		clicked_sprite = "utility/select_icon_black"
	},
	technology = {
		sprite = "utility/technology_white",
		hovered_sprite = "utility/technology_black",
		clicked_sprite = "utility/technology_black"
	},
	slot_icon_module = {
		sprite = "utility/slot_icon_module",
		hovered_sprite = "utility/slot_icon_module_black",
		clicked_sprite = "utility/slot_icon_module_black"
	},
	slot_icon_armor = {
		sprite = "utility/slot_icon_armor",
		hovered_sprite = "utility/slot_icon_armor_black",
		clicked_sprite = "utility/slot_icon_armor_black"
	},
	gun = {
		style = "frame_action_button",
		sprite = "utility/slot_icon_gun",
		hovered_sprite = "utility/slot_icon_gun_black",
		clicked_sprite = "utility/slot_icon_gun_black"
	},
	fuel = { -- TODO: find similar style to "frame_action_button"
		sprite = "utility/slot_icon_fuel",
		hovered_sprite = "utility/slot_icon_fuel_black",
		clicked_sprite = "utility/slot_icon_fuel_black"
	},
	robot = {
		style = "frame_action_button",
		sprite = "utility/slot_icon_robot",
		hovered_sprite = "utility/slot_icon_robot_black",
		clicked_sprite = "utility/slot_icon_robot_black"
	},
	slot_icon_robot_material = {
		sprite = "utility/slot_icon_robot_material",
		hovered_sprite = "utility/slot_icon_robot_material_black",
		clicked_sprite = "utility/slot_icon_robot_material_black"
	},
	slot_icon_inserter_hand = {
		sprite = "utility/slot_icon_inserter_hand",
		hovered_sprite = "utility/slot_icon_inserter_hand_black",
		clicked_sprite = "utility/slot_icon_inserter_hand_black"
	},
	circuit_network_panel = {
		style = "frame_action_button",
		sprite = "utility/circuit_network_panel_white",
		hovered_sprite = "utility/circuit_network_panel_black",
		clicked_sprite = "utility/circuit_network_panel_black"
	},
	logistic_network_panel = {
		style = "frame_action_button",
		sprite = "utility/logistic_network_panel_white",
		hovered_sprite = "utility/logistic_network_panel_black",
		clicked_sprite = "utility/logistic_network_panel_black"
	},
	small_rename = {
		style = "frame_action_button",
		sprite = "utility/rename_icon_small_white",
		hovered_sprite = "utility/rename_icon_small_black",
		clicked_sprite = "utility/rename_icon_small_black"
	},
	downloaded = {
		style = "frame_action_button",
		sprite = "utility/downloaded_white",
		hovered_sprite = "utility/downloaded",
		clicked_sprite = "utility/downloaded"
	},
	expand_dots = {
		style = "frame_action_button",
		sprite = "utility/expand_dots_white",
		hovered_sprite = "utility/expand_dots",
		clicked_sprite = "utility/expand_dots"
	},
	mod_dependency_arrow = { -- right arrow, TODO: add white sprite
		style = "frame_action_button",
		sprite = "utility/mod_dependency_arrow",
	},
	played_green = { -- right arrow
		style = "frame_action_button",
		sprite = "utility/played_green",
	},
	played_dark_green = { -- right arrow
		style = "frame_action_button",
		sprite = "utility/played_dark_green",
	},
	check_mark = {
		style = "frame_action_button",
		sprite = "utility/check_mark_white",
		hovered_sprite = "utility/check_mark",
		clicked_sprite = "utility/check_mark"
	},
	collapse = {
		style = "frame_action_button",
		sprite = "utility/collapse",
		hovered_sprite = "utility/collapse_dark",
		clicked_sprite = "utility/collapse_dark"
	},
	expand = {
		style = "frame_action_button",
		sprite = "utility/expand",
		hovered_sprite = "utility/expand_dark",
		clicked_sprite = "utility/expand_dark"
	},
	underground_remove_pipes = { -- red square with cornerns
		style = "frame_action_button",
		sprite = "utility/underground_remove_pipes",
	},
	stop = { --TODO: add tooltip
		sprite = "utility/stop",
	},
}
if script.active_mods["zk-lib"] then
	GuiTemplater.buttons.map_exchange_string.sprite = "map_exchange_string_white"
	GuiTemplater.buttons.plus.sprite = "plus_white"
	GuiTemplater.buttons.plus.hovered_sprite = "plus"
	GuiTemplater.buttons.plus.clicked_sprite = "plus"
	GuiTemplater.buttons.confirm.sprite = "confirm_white"
	GuiTemplater.buttons.confirm.hovered_sprite = "utility/confirm_slot"
	GuiTemplater.buttons.confirm.clicked_sprite = "utility/confirm_slot"
	GuiTemplater.buttons.bookmark.sprite = "bookmark_white"
	GuiTemplater.buttons.bookmark.hovered_sprite = "utility/bookmark"
	GuiTemplater.buttons.bookmark.clicked_sprite = "utility/bookmark"
	GuiTemplater.buttons.brush.sprite = "brush_icon_white"
	GuiTemplater.buttons.brush.hovered_sprite = "utility/brush_icon"
	GuiTemplater.buttons.brush.clicked_sprite = "utility/brush_icon"
	GuiTemplater.buttons.center.sprite = "center_white"
	GuiTemplater.buttons.center.hovered_sprite = "utility/center"
	GuiTemplater.buttons.center.clicked_sprite = "utility/center"
	GuiTemplater.buttons.change_recipe.sprite = "change_recipe_white"
	GuiTemplater.buttons.change_recipe.hovered_sprite = "utility/change_recipe"
	GuiTemplater.buttons.change_recipe.clicked_sprite = "utility/change_recipe"
	GuiTemplater.buttons.gears.sprite = "change_recipe_white"
	GuiTemplater.buttons.gears.hovered_sprite = "utility/change_recipe"
	GuiTemplater.buttons.gears.clicked_sprite = "utility/change_recipe"
	GuiTemplater.buttons.clone.sprite = "clone_white"
	GuiTemplater.buttons.clone.hovered_sprite = "utility/clone"
	GuiTemplater.buttons.clone.clicked_sprite = "utility/clone"
	GuiTemplater.buttons.add.sprite = "add_white"
	GuiTemplater.buttons.add.hovered_sprite = "utility/add"
	GuiTemplater.buttons.add.clicked_sprite = "utility/add"
	GuiTemplater.buttons.close_fat.sprite = "close_fat_white"
	GuiTemplater.buttons.close_fat.hovered_sprite = "utility/close_fat"
	GuiTemplater.buttons.close_fat.clicked_sprite = "utility/close_fat"
	GuiTemplater.buttons.close_map_preview.sprite = "close_map_preview_white"
	GuiTemplater.buttons.close_map_preview.hovered_sprite = "utility/close_map_preview"
	GuiTemplater.buttons.close_map_preview.clicked_sprite = "utility/close_map_preview"
	GuiTemplater.buttons.color_picker.sprite = "color_picker_white"
	GuiTemplater.buttons.color_picker.hovered_sprite = "utility/color_picker"
	GuiTemplater.buttons.color_picker.clicked_sprite = "utility/color_picker"
	GuiTemplater.buttons.confirm.sprite = "confirm_slot_white"
	GuiTemplater.buttons.confirm.hovered_sprite = "utility/confirm_slot"
	GuiTemplater.buttons.confirm.clicked_sprite = "utility/confirm_slot"
	GuiTemplater.buttons.dropdown.sprite = "dropdown_white"
	GuiTemplater.buttons.dropdown.hovered_sprite = "utility/dropdown"
	GuiTemplater.buttons.dropdown.clicked_sprite = "utility/dropdown"
	GuiTemplater.buttons.tick_custom.sprite = "tick_custom_white"
	GuiTemplater.buttons.tick_custom.hovered_sprite = "utility/tick_custom"
	GuiTemplater.buttons.tick_custom.clicked_sprite = "utility/tick_custom"
	GuiTemplater.buttons.tick_once.sprite = "tick_once_white"
	GuiTemplater.buttons.tick_once.hovered_sprite = "utility/tick_once"
	GuiTemplater.buttons.tick_once.clicked_sprite = "utility/tick_once"
	GuiTemplater.buttons.tick_sixty.sprite = "tick_sixty_white"
	GuiTemplater.buttons.tick_sixty.hovered_sprite = "utility/tick_sixty"
	GuiTemplater.buttons.tick_sixty.clicked_sprite = "utility/tick_sixty"
	GuiTemplater.buttons.enter.sprite = "enter_white"
	GuiTemplater.buttons.enter.hovered_sprite = "utility/enter"
	GuiTemplater.buttons.enter.clicked_sprite = "utility/enter"
	GuiTemplater.buttons.export.sprite = "export_white"
	GuiTemplater.buttons.export.hovered_sprite = "utility/export"
	GuiTemplater.buttons.export.clicked_sprite = "utility/export"
	GuiTemplater.buttons.go_to_arrow.sprite = "go_to_arrow_white"
	GuiTemplater.buttons.go_to_arrow.hovered_sprite = "utility/go_to_arrow"
	GuiTemplater.buttons.go_to_arrow.clicked_sprite = "utility/go_to_arrow"
	GuiTemplater.buttons.mod_dependency_arrow.sprite = "mod_dependency_arrow_white"
	GuiTemplater.buttons.mod_dependency_arrow.hovered_sprite = "utility/mod_dependency_arrow"
	GuiTemplater.buttons.mod_dependency_arrow.clicked_sprite = "utility/mod_dependency_arrow"
	GuiTemplater.buttons.grid_view.sprite = "grid_view_white"
	GuiTemplater.buttons.grid_view.hovered_sprite = "utility/grid_view"
	GuiTemplater.buttons.grid_view.clicked_sprite = "utility/grid_view"
	GuiTemplater.buttons.import.sprite = "import_white"
	GuiTemplater.buttons.import.hovered_sprite = "utility/import"
	GuiTemplater.buttons.import.clicked_sprite = "utility/import"
	GuiTemplater.buttons.import_slot.sprite = "import_slot_white"
	GuiTemplater.buttons.import_slot.hovered_sprite = "utility/import_slot"
	GuiTemplater.buttons.import_slot.clicked_sprite = "utility/import_slot"
	GuiTemplater.buttons.thin_left_arrow.sprite = "left_arrow_white"
	GuiTemplater.buttons.thin_left_arrow.hovered_sprite = "utility/left_arrow"
	GuiTemplater.buttons.thin_left_arrow.clicked_sprite = "utility/left_arrow"
	GuiTemplater.buttons.list_view.sprite = "list_view_white"
	GuiTemplater.buttons.list_view.hovered_sprite = "utility/list_view"
	GuiTemplater.buttons.list_view.clicked_sprite = "utility/list_view"
	GuiTemplater.buttons.map.sprite = "map_white"
	GuiTemplater.buttons.map.hovered_sprite = "utility/map"
	GuiTemplater.buttons.map.clicked_sprite = "utility/map"
	GuiTemplater.buttons.paint_bucket.sprite = "paint_bucket_icon_white"
	GuiTemplater.buttons.paint_bucket.hovered_sprite = "utility/paint_bucket_icon"
	GuiTemplater.buttons.paint_bucket.clicked_sprite = "utility/paint_bucket_icon"
	GuiTemplater.buttons.pause.sprite = "pause_white"
	GuiTemplater.buttons.pause.hovered_sprite = "utility/pause"
	GuiTemplater.buttons.pause.clicked_sprite = "utility/pause"
	GuiTemplater.buttons.play.sprite = "play_white"
	GuiTemplater.buttons.play.hovered_sprite = "utility/play"
	GuiTemplater.buttons.play.clicked_sprite = "utility/play"
	GuiTemplater.buttons.preset.sprite = "preset_white"
	GuiTemplater.buttons.preset.hovered_sprite = "utility/preset"
	GuiTemplater.buttons.preset.clicked_sprite = "utility/preset"
	GuiTemplater.buttons.refresh.sprite = "refresh_white"
	GuiTemplater.buttons.refresh.hovered_sprite = "utility/refresh"
	GuiTemplater.buttons.refresh.clicked_sprite = "utility/refresh"
	GuiTemplater.buttons.rename.sprite = "rename_icon_normal_white"
	GuiTemplater.buttons.rename.hovered_sprite = "utility/rename_icon_normal"
	GuiTemplater.buttons.rename.clicked_sprite = "utility/rename_icon_normal"
	GuiTemplater.buttons.thin_right_arrow.sprite = "right_arrow_white"
	GuiTemplater.buttons.thin_right_arrow.hovered_sprite = "utility/right_arrow"
	GuiTemplater.buttons.thin_right_arrow.clicked_sprite = "utility/right_arrow"
	GuiTemplater.buttons.area.sprite = "area_icon_white"
	GuiTemplater.buttons.area.hovered_sprite = "utility/area_icon"
	GuiTemplater.buttons.area.clicked_sprite = "utility/area_icon"
	GuiTemplater.buttons.shuffle.sprite = "shuffle_white"
	GuiTemplater.buttons.shuffle.hovered_sprite = "utility/shuffle"
	GuiTemplater.buttons.shuffle.clicked_sprite = "utility/shuffle"
	GuiTemplater.buttons.speed_down.sprite = "speed_down_white"
	GuiTemplater.buttons.speed_down.hovered_sprite = "utility/speed_down"
	GuiTemplater.buttons.speed_down.clicked_sprite = "utility/speed_down"
	GuiTemplater.buttons.speed_up.sprite = "speed_up_white"
	GuiTemplater.buttons.speed_up.hovered_sprite = "utility/speed_up"
	GuiTemplater.buttons.speed_up.clicked_sprite = "utility/speed_up"
	GuiTemplater.buttons.spray.sprite = "spray_icon_white"
	GuiTemplater.buttons.spray.hovered_sprite = "utility/spray_icon"
	GuiTemplater.buttons.spray.clicked_sprite = "utility/spray_icon"
	GuiTemplater.buttons.stop.sprite = "stop_white"
	GuiTemplater.buttons.stop.hovered_sprite = "utility/stop"
	GuiTemplater.buttons.stop.clicked_sprite = "utility/stop"
	GuiTemplater.buttons.sync_mods.sprite = "sync_mods_white"
	GuiTemplater.buttons.sync_mods.hovered_sprite = "utility/sync_mods"
	GuiTemplater.buttons.sync_mods.clicked_sprite = "utility/sync_mods"
	GuiTemplater.buttons.questionmark.sprite = "questionmark_white"
	GuiTemplater.buttons.questionmark.hovered_sprite = "utility/questionmark"
	GuiTemplater.buttons.questionmark.clicked_sprite = "utility/questionmark"
	GuiTemplater.buttons.missing_icon.sprite = "questionmark_white"
	GuiTemplater.buttons.missing_icon.hovered_sprite = "utility/questionmark"
	GuiTemplater.buttons.missing_icon.clicked_sprite = "utility/questionmark"
	GuiTemplater.buttons.variations_tool.sprite = "variations_tool_icon_white"
	GuiTemplater.buttons.variations_tool.hovered_sprite = "utility/variations_tool_icon"
	GuiTemplater.buttons.variations_tool.clicked_sprite = "utility/variations_tool_icon"
	GuiTemplater.buttons.copy.sprite = "copy_white"
	GuiTemplater.buttons.copy.hovered_sprite = "utility/copy"
	GuiTemplater.buttons.copy.clicked_sprite = "utility/copy"
	GuiTemplater.buttons.export_slot.sprite = "export_slot_white"
	GuiTemplater.buttons.export_slot.hovered_sprite = "utility/export_slot"
	GuiTemplater.buttons.export_slot.clicked_sprite = "utility/export_slot"
	--- Requires zk-lib >= 0.15.7
	GuiTemplater.buttons.ZO_nerd_action_button24 = {
		style = "ZO_nerd_action_button24"
	}
	GuiTemplater.buttons.ZO_nerd_action_button40 = {
		style = "ZO_nerd_action_button40"
	}
	GuiTemplater.buttons["nf-fa-sort_amount_asc"] = {
		caption = "[font=SymbolsNerdFont32][/font]",
		style   = "ZO_nerd_action_button40"
	}
	GuiTemplater.buttons["nf-fa-sort_amount_desc"] = {
		caption = "[font=SymbolsNerdFont32][/font]",
		style   = "ZO_nerd_action_button40"
	}
	GuiTemplater.buttons["nf-md-translate"] = {
		caption = "[font=SymbolsNerdFont32]󰗊[/font]",
		style   = "ZO_nerd_action_button40"
	}
	GuiTemplater.buttons["nf-md-picture_in_picture_top_right"] = {
		caption = "[font=SymbolsNerdFont32]󰹙[/font]",
		style   = "ZO_nerd_action_button40"
	}
	GuiTemplater.buttons["nf-md-map_marker_plus_outline"] = {
		caption = "[font=SymbolsNerdFont32]󱋸[/font]",
		style   = "ZO_nerd_action_button40"
	}
	GuiTemplater.buttons["nf-md-format_annotation_minus"] = {
		caption = "[font=SymbolsNerdFont32]󰪼[/font]",
		style   = "ZO_nerd_action_button40"
	}
	GuiTemplater.buttons["nf-md-format_annotation_plus"] = {
		caption = "[font=SymbolsNerdFont32]󰙆[/font]",
		style   = "ZO_nerd_action_button40"
	}
	GuiTemplater.buttons["nf-fa-arrows_alt"] = {
		caption = "[font=SymbolsNerdFont32][/font]",
		style   = "ZO_nerd_action_button40"
	}
	GuiTemplater.buttons["nf-cod-check_all"] = {
		caption = "[font=SymbolsNerdFont32][/font]",
		style   = "ZO_nerd_action_button40"
	}
	GuiTemplater.buttons["nf-cod-checklist"] = {
		caption = "[font=SymbolsNerdFont32][/font]",
		style   = "ZO_nerd_action_button40"
	}
	GuiTemplater.buttons["nf-fa-github"] = {
		caption = "[font=SymbolsNerdFont32][/font]",
		style   = "ZO_nerd_action_button40"
	}
	GuiTemplater.buttons["nf-md-text_box_edit"] = {
		caption = "[font=SymbolsNerdFont32]󱩼[/font]",
		style   = "ZO_nerd_action_button40"
	}
end
for _, button in pairs(GuiTemplater.buttons) do
	if button.type == nil then
		if button.sprite or button.clicked_sprite or button.hovered_sprite then
			button.type = "sprite-button"
		else
			button.type = "button"
		end
	end
end


GuiTemplater.frames = {
	negative_subheader_frame = {style = "negative_subheader_frame"},
	subfooter_frame = {style = "subfooter_frame"},
	frame          = {style = "frame", direction = "horizontal"},
	vertical_frame = {style = "frame", direction = "vertical"},
	borderless_frame     = {style = "tips_and_tricks_notification_frame"},
	inside_shallow_frame = {style = "inside_shallow_frame", direction = "vertical"},
	subheader_frame      = {style = "subheader_frame"},
	subpanel_frame       = {style = "subpanel_frame"},
}
if script.active_mods["zk-lib"] then
	GuiTemplater.frames.zk_transparent_frame      = {style = "zk_transparent_frame"}
	GuiTemplater.frames.zk_dark_transparent_frame = {style = "zk_dark_transparent_frame"}
end
for _, data in pairs(GuiTemplater.frames) do
	data.type = "frame"
end


GuiTemplater.tables = {
	graphics_settings_table = {style = "graphics_settings_table"},
}
for _, data in pairs(GuiTemplater.tables) do
	data.type = "table"
end


GuiTemplater.labels = {
	graphics_settings_table = {style = "caption_label"},
	bold_label = {style = "bold_label"},
}
for _, data in pairs(GuiTemplater.labels) do
	data.type = "label"
end


---@param template_data ZOGuiTemplater.data | ZOGuiTemplater.child_data | ZOGuiTemplater.collapse_data | ZOGuiTemplater.collapse_child_data
local function _checkCommonEvents(template_data)
	local is_valid = true
	if template_data.element.name == nil then
		is_valid = false
		GuiTemplater._log("There's no name for GuiElement")
	end

	for k, v in pairs(template_data) do
		if k:find("^on_gui_") then
			template_data.events = template_data.events or {}
			template_data.events[#template_data.events+1] = {k, v}
		end
	end

	if is_valid and (template_data.events or template_data.event) then
		for _, event_data in ipairs(template_data.events or {template_data.event}) do
			local event = event_data[1]
			if type(event) == "string" then
				local event_id = defines.events[event]
				if event_id then
					event = defines.events[event]
					event_data[1] = event
				else
					local hidden_event = GuiTemplater.__events[event]
					if hidden_event then
						template_data[event] = event_data[2]
					end
					goto continue
				end
			end
			GuiTemplater.events_GUIs[event] = GuiTemplater.events_GUIs[event] or {}
			local events_GUIs = GuiTemplater.events_GUIs[event]
			if GuiTemplater.safe_mode then
				GuiTemplater.events[event] = GuiTemplater.events[event] or
					---@param e EventData
					function(e)
					local element = e.element
					if not (element and element.valid) then return end
					local f = events_GUIs[element.name]
					if f then
						local player = game.get_player(e.player_index)
						local is_ok, result = pcall(f, element, player, e)
						if not is_ok then
							GuiTemplater._log(result, player)
						end
					end
				end
			else
				GuiTemplater.events[event] = GuiTemplater.events[event] or
					---@param e EventData
					function(e)
					local element = e.element
					if not (element and element.valid) then return end
					local f = events_GUIs[element.name]
					if f then
						f(element, game.get_player(e.player_index), e)
					end
				end
			end
			events_GUIs[template_data.element.name] = event_data[2]
		    ::continue::
		end
	end
end


---@param template_data ZOGuiTemplater.data | ZOGuiTemplater.child_data
local function _checkEvents(template_data)
	_checkCommonEvents(template_data)

	if template_data.create_for_new_players then
		local tempalates = GuiTemplater.templates_for_new_players
		tempalates[#tempalates+1] = template_data
	end
	if template_data.create_for_joined_players then
		local tempalates = GuiTemplater.templates_for_joined_players
		tempalates[#tempalates+1] = template_data
	end
	if template_data.destroy_for_left_players then
		local tempalates = GuiTemplater.templates_for_left_players
		tempalates[#tempalates+1] = template_data
	end

	local children = template_data.children
	if not children then return end
	for _, child in pairs(children) do
		_checkEvents(child)
	end
end


---@param template_data ZOGuiTemplater.collapse_data | ZOGuiTemplater.collapse_child_data
local function _checkExpanderEvents(template_data)
	if template_data.element then
		_checkCommonEvents(template_data)
	end

	local children = template_data.children
	if not children then return end
	for _, child in pairs(children) do
		_checkExpanderEvents(child)
	end
end


---@param init_data ZOGuiTemplater.data
---@return ZOGuiTemplate
function GuiTemplater.create(init_data)
	---@class ZOGuiTemplate
	local template = init_data

	_checkEvents(template)

	template.createGUIs = function(gui, template_data, player)
		---@cast template_data ZOGuiTemplater.data | ZOGuiTemplater.child_data?
		---@cast player LuaPlayer?
		if not (gui and gui.valid) then return false end
		---@type LuaPlayer
		player = player or game.get_player(gui.player_index)

		template_data = template_data or init_data

		if template_data.admin_only and not player.admin then return false end

		local is_ok, newGui, result
		local element = template_data.element
		if template_data.raise_error or (GuiTemplater.raise_error and template_data.raise_error ~= false) then
			newGui = gui.add(element)
		else
			is_ok, newGui = GuiTemplater.create_GUI_safely(gui, element, player)
			if not is_ok then
				return false
			end
		end
		---@cast newGui LuaGuiElement

		if template_data.style then
			local style = newGui.style
			for k, v in pairs(template_data.style) do
				style[k] = v
			end
		end

		if template_data.on_create then
			if template_data.raise_error or (GuiTemplater.raise_error and template_data.raise_error ~= false) then
				template_data.on_create(newGui)
			else
				is_ok, result = pcall(template_data.on_create, newGui)
				if not is_ok then
					GuiTemplater._log(result, player)
					return false
				end
			end
		end

		if not newGui.valid then return false end

		local children = template_data.children
		if children then
			for _, child in pairs(children) do
				is_ok, result = template.createGUIs(newGui, child, player)
				if not is_ok then
					GuiTemplater._log(result, player)
					return false
				end
			end
		end

		if template_data.on_finish then
			if template_data.raise_error or (GuiTemplater.raise_error and template_data.raise_error ~= false) then
				template_data.on_finish(newGui)
			else
				is_ok = pcall(template_data.on_finish, newGui)
				if not is_ok then return false end
			end
		end

		return true
	end

	template.destroyGUIs = function(gui)
		if not (gui and gui.valid) then return false end

		local targetGui = gui[init_data.element.name]
		if targetGui and targetGui.valid then
			local is_ok = true
			if init_data.on_pre_destroy then
				if init_data.raise_error or (GuiTemplater.raise_error and init_data.raise_error ~= false) then
					init_data.on_pre_destroy(targetGui)
				else
					is_ok = pcall(init_data.on_pre_destroy, targetGui)
				end
			end

			targetGui.destroy()
			return is_ok
		end
		return false
	end

	---@param gui LuaGuiElement
	template.clear = function(gui)
		if not (gui and gui.valid) then return false end

		local targetGui = gui[init_data.element.name]
		if targetGui and targetGui.valid then
			local is_ok = true
			if init_data.on_pre_clear then
				if init_data.raise_error or (GuiTemplater.raise_error and init_data.raise_error ~= false) then
					init_data.on_pre_clear(targetGui)
				else
					is_ok = pcall(init_data.on_pre_clear, targetGui)
				end
			end

			targetGui.clear()
			return is_ok
		end
		return false
	end

	return template
end


---@param init_data ZOGuiTemplater.collapse_data
---@param expander_name string
---@param caption string|table
---@param is_collapsed boolean?
---@return ZOGuiExpanderTemplate
function GuiTemplater.create_expander_template(init_data, expander_name, caption, is_collapsed)
	---@class ZOGuiTemplate
	local template = init_data

	_checkExpanderEvents(template)

	local on_click_event = defines.events.on_gui_click
	GuiTemplater.events_GUIs[on_click_event] = GuiTemplater.events_GUIs[on_click_event] or {}
	local events_GUIs = GuiTemplater.events_GUIs[on_click_event]
	events_GUIs[expander_name] = function(element, player, event)
		local parent = element.parent
		---@cast parent LuaGuiElement
		local index, check_element
		if parent.type == "flow" and
			(parent.direction == nil or parent.direction ~= "vertical")
		then
			check_element = parent
			parent = parent.parent
		else
			check_element = element
		end

		local children = parent.children
		for i, child in pairs(children) do
			if child == check_element then
				index = i
			end
		end

		if element.sprite == GuiTemplater.buttons.collapse.sprite then
			element.sprite         = GuiTemplater.buttons.expand.sprite
			element.hovered_sprite = GuiTemplater.buttons.expand.hovered_sprite
			element.clicked_sprite = GuiTemplater.buttons.expand.clicked_sprite
			local frame = parent.children[index+1]
			frame.clear()
		else
			element.sprite         = GuiTemplater.buttons.collapse.sprite
			element.hovered_sprite = GuiTemplater.buttons.collapse.hovered_sprite
			element.clicked_sprite = GuiTemplater.buttons.collapse.clicked_sprite
			local frame = parent.children[index+1]
			template.createGUIs(frame, init_data)
		end
	end

	--- Perhaps I should refactor it (see _checkCommonEvents)
	if GuiTemplater.safe_mode then
		GuiTemplater.events[on_click_event] = GuiTemplater.events[on_click_event] or
			---@param e EventData.on_gui_click
			function(e)
			local element = e.element
			if not (element and element.valid) then return end
			local f = events_GUIs[element.name]
			if f then
				local player = game.get_player(e.player_index)
				local is_ok, result = pcall(f, element, player, e)
				if not is_ok then
					GuiTemplater._log(result, player)
				end
			end
		end
	else
		GuiTemplater.events[on_click_event] = GuiTemplater.events[on_click_event] or
			---@param e EventData.on_gui_click
			function(e)
			local element = e.element
			if not (element and element.valid) then return end
			local f = events_GUIs[element.name]
			if f then
				f(element, game.get_player(e.player_index), e)
			end
		end
	end

	template.createGUIs = function(main_gui, template_data, player)
		---@cast template_data ZOGuiTemplater.collapse_child|ZOGuiTemplater.collapse_child_data?
		---@cast player LuaPlayer?
		if not (main_gui and main_gui.valid) then return false end
		---@type LuaPlayer
		player = player or game.get_player(main_gui.player_index)

		local button
		if template_data == nil then
			if (main_gui.type ~= "frame" and main_gui ~= "flow") or
				((main_gui.type == "frame" or main_gui == "flow") and main_gui.direction ~= "vertical")
			then
				main_gui = main_gui.add(GuiTemplater.vertical_flow)
			end

			local expander
			button = (is_collapsed and GuiTemplater.buttons.expand) or GuiTemplater.buttons.collapse
			if not caption then
				expander = flow.add(button)
			else
				local flow = main_gui.add(GuiTemplater.flow)
				expander = flow.add(button)
				flow.add(GuiTemplater.labels.bold_label).caption = caption
			end
			expander.name = expander_name

			-- TODO: improve \/
			main_gui = main_gui.add(GuiTemplater.frames.inside_shallow_frame)
		end

		if button and button == GuiTemplater.buttons.expand then
			return true
		end

		local is_init_data = (template_data == nil)
		template_data = template_data or init_data
		if template_data.admin_only and not player.admin then return false end

		local is_ok, newGui, result
		local element = template_data.element
		if not (not is_init_data and element) then
			newGui = main_gui
			is_ok  = true
		else
			if template_data.raise_error or (GuiTemplater.raise_error and template_data.raise_error ~= false) then
				newGui = main_gui.add(element)
			else
				is_ok, newGui = GuiTemplater.create_GUI_safely(main_gui, element, player)
				if not is_ok then
					return false
				end
			end
			---@cast newGui LuaGuiElement

			if template_data.style then
				local style = newGui.style
				for k, v in pairs(template_data.style) do
					style[k] = v
				end
			end

			if template_data.on_create then
				if template_data.raise_error or (GuiTemplater.raise_error and template_data.raise_error ~= false) then
					template_data.on_create(newGui)
				else
					is_ok, result = pcall(template_data.on_create, newGui)
					if not is_ok then
						GuiTemplater._log(result, player)
						return false
					end
				end
			end

			if not newGui.valid then return false end
		end

		local children = template_data.children
		if children then
			for _, child in pairs(children) do
				is_ok, result = template.createGUIs(newGui, child, player)
				if not is_ok then
					GuiTemplater._log(result, player)
					return false
				end
			end
		end

		if template_data.on_finish then
			if template_data.raise_error or (GuiTemplater.raise_error and template_data.raise_error ~= false) then
				template_data.on_finish(newGui)
			else
				is_ok = pcall(template_data.on_finish, newGui)
				if not is_ok then return false end
			end
		end

		return true
	end

	return template
end


---@param player LuaPlayer
---@param frame_name string?
---@param title string|table?
---@return LuaGuiElement, LuaGuiElement, LuaGuiElement # content_frame, main_frame, top_flow
GuiTemplater.create_screen_window = function(player, frame_name, title)
	local screen = player.gui.screen
	local prev_location
	if frame_name and screen[frame_name] then
		prev_location = screen[frame_name].location
		screen[frame_name].destroy()
	end

	local main_frame = screen.add(GuiTemplater.frames.vertical_frame)
	if frame_name then
		main_frame.name = frame_name
	end
	-- main_frame.style.horizontal_spacing = 0 -- it doesn't work, probably
	main_frame.style.padding = 4

	local top_flow = main_frame.add(GuiTemplater.flow)
	top_flow.style.horizontal_spacing = 0
	if title then
		top_flow.add{
			type = "label",
			style = "frame_title",
			caption = title,
			ignored_by_interaction = true
		}
	end
	local drag_handler = top_flow.add(GuiTemplater.drag_handler)
	drag_handler.drag_target = main_frame
	drag_handler.style.horizontally_stretchable = true
	drag_handler.style.vertically_stretchable   = true
	drag_handler.style.minimal_width = 20
	drag_handler.style.margin = 0
	top_flow.add(GuiTemplater.buttons._close)

	local shallow_frame = main_frame.add(GuiTemplater.frames.inside_shallow_frame)
	shallow_frame.style.padding = 8

	if prev_location then
		main_frame.location = prev_location
	end

	return shallow_frame, main_frame, top_flow
end


---@param player LuaPlayer
---@param frame_name string
---@param title string|table?
---@return LuaGuiElement, LuaGuiElement, LuaGuiElement # content_flow, main_frame, top_flow
GuiTemplater.create_hollow_screen_window = function(player, frame_name, title)
	local screen = player.gui.screen
	local prev_location
	if screen[frame_name] then
		prev_location = screen[frame_name].location
		screen[frame_name].destroy()
	end

	local main_frame = screen.add(GuiTemplater.frames.vertical_frame)
	main_frame.name = frame_name
	-- main_frame.style.horizontal_spacing = 0 -- it doesn't work, probably
	main_frame.style.padding = 4

	local top_flow = main_frame.add(GuiTemplater.flow)
	top_flow.style.horizontal_spacing = 0
	if title then
		top_flow.add{
			type = "label",
			style = "frame_title",
			caption = title,
			ignored_by_interaction = true
		}
	end
	local drag_handler = top_flow.add(GuiTemplater.drag_handler)
	drag_handler.drag_target = main_frame
	drag_handler.style.horizontally_stretchable = true
	drag_handler.style.vertically_stretchable   = true
	drag_handler.style.minimal_width = 20
	drag_handler.style.margin = 0
	top_flow.add(GuiTemplater.buttons._close)

	local vertical_flow = main_frame.add(GuiTemplater.vertical_flow)
	vertical_flow.style.padding = 2

	if prev_location then
		main_frame.location = prev_location
	end

	return vertical_flow, main_frame, top_flow
end

---@param player LuaPlayer
---@param frame_name string?
---@param title string|table?
---@return LuaGuiElement, LuaGuiElement, LuaGuiElement # content_frame, main_frame, top_flow
GuiTemplater.create_screen_frame = function(player, frame_name, title)
	local screen = player.gui.screen
	local prev_location
	if frame_name and screen[frame_name] then
		prev_location = screen[frame_name].location
		screen[frame_name].destroy()
	end

	local main_frame = screen.add(GuiTemplater.frames.vertical_frame)
	if frame_name then
		main_frame.name = frame_name
	end
	-- main_frame.style.horizontal_spacing = 0 -- it doesn't work, probably
	main_frame.style.padding = 4

	local top_flow = main_frame.add(GuiTemplater.flow)
	top_flow.style.horizontal_spacing = 0
	if title then
		top_flow.add{
			type = "label",
			style = "frame_title",
			caption = title,
			ignored_by_interaction = true
		}
	end
	local drag_handler = top_flow.add(GuiTemplater.drag_handler)
	drag_handler.drag_target = main_frame
	drag_handler.style.horizontally_stretchable = true
	drag_handler.style.vertically_stretchable   = true
	drag_handler.style.minimal_width = 20
	drag_handler.style.margin = 0

	local shallow_frame = main_frame.add(GuiTemplater.frames.inside_shallow_frame)
	shallow_frame.style.padding = 8

	if prev_location then
		main_frame.location = prev_location
	end

	return shallow_frame, main_frame, top_flow
end


---@param player LuaPlayer
---@param frame_name string
---@param title string|table?
---@return LuaGuiElement, LuaGuiElement, LuaGuiElement # content_flow, main_frame, top_flow
GuiTemplater.create_hollow_screen_frame = function(player, frame_name, title)
	local screen = player.gui.screen
	local prev_location
	if screen[frame_name] then
		prev_location = screen[frame_name].location
		screen[frame_name].destroy()
	end

	local main_frame = screen.add(GuiTemplater.frames.vertical_frame)
	main_frame.name = frame_name
	-- main_frame.style.horizontal_spacing = 0 -- it doesn't work, probably
	main_frame.style.padding = 4

	local top_flow = main_frame.add(GuiTemplater.flow)
	top_flow.style.horizontal_spacing = 0
	if title then
		top_flow.add{
			type = "label",
			style = "frame_title",
			caption = title,
			ignored_by_interaction = true
		}
	end
	local drag_handler = top_flow.add(GuiTemplater.drag_handler)
	drag_handler.drag_target = main_frame
	drag_handler.style.horizontally_stretchable = true
	drag_handler.style.vertically_stretchable   = true
	drag_handler.style.minimal_width = 20
	drag_handler.style.margin = 0

	local vertical_flow = main_frame.add(GuiTemplater.vertical_flow)
	vertical_flow.style.padding = 2

	if prev_location then
		main_frame.location = prev_location
	end

	return vertical_flow, main_frame, top_flow
end


---@param tableGUI LuaGuiElement
---@param minimal_column_width integer?
---@return LuaGuiElement
function GuiTemplater.make_table_as_list(tableGUI, minimal_column_width)
	local style = tableGUI.style
	style.horizontal_spacing = 16
	style.vertical_spacing = 8
	style.top_margin = -16 -- perhaps wrong without minimal_width
	local column_alignments = style.column_alignments

	local EMPTY_WIDGET = GuiTemplater.empty_widget
	for i = 1, tableGUI.column_count do
		column_alignments[i] = "center"
		if minimal_column_width then
			local dummy = tableGUI.add(EMPTY_WIDGET)
			local _style = dummy.style
			_style.horizontally_stretchable = true
			_style.minimal_width = minimal_column_width
		end
	end
	tableGUI.draw_horizontal_lines = true
	tableGUI.draw_vertical_lines = true

	return tableGUI
end


---@param gui LuaGuiElement
---@param name string?
---@param anchor GuiAnchor
---@return LuaGuiElement, LuaGuiElement
function GuiTemplater.create_top_relative_frame(gui, name, anchor)
	local main_frame = gui.add{type = "frame", name = name, anchor = anchor}
	local style = main_frame.style
	style.vertical_align = "center"
	style.horizontally_stretchable = false
	style.bottom_margin = -14
	local frame = main_frame.add(GuiTemplater.frames.inside_shallow_frame)
	frame.style.right_padding = 6

	return frame, main_frame
end


---@param gui LuaGuiElement
---@param name string?
---@param anchor GuiAnchor
---@return LuaGuiElement, LuaGuiElement
function GuiTemplater.create_left_relative_frame(gui, name, anchor)
	local main_frame = gui.add{type = "frame", name = name, anchor = anchor}
	main_frame.style.right_margin = -14
	local frame = main_frame.add(GuiTemplater.frames.inside_shallow_frame)

	return frame, main_frame
end


---@param gui LuaGuiElement
---@param name string?
---@param anchor GuiAnchor
---@return LuaGuiElement, LuaGuiElement
function GuiTemplater.create_right_relative_frame(gui, name, anchor)
	local main_frame = gui.add{type = "frame", name = name, anchor = anchor}
	main_frame.style.left_margin = -14
	local frame = main_frame.add(GuiTemplater.frames.inside_shallow_frame)

	return frame, main_frame
end


---@param player LuaPlayer?
---@param trigger_gui LuaGuiElement
---@param frame_name string
---@param offset integer?
---@return LuaGuiElement?
function GuiTemplater.create_menu(player, trigger_gui, frame_name, offset)
	player = player or game.get_player(trigger_gui.player_index)
	local screen = player.gui.screen
	if screen[frame_name] then
		screen[frame_name].destroy()
	end

	local frame_location = trigger_gui.location
	local target_y = frame_location.y + ((offset or 30) * player.display_scale)
	if player.display_resolution.height <= target_y then
		return
	end

	local main_frame = screen.add(GuiTemplater.frames.vertical_frame)
	main_frame.name = frame_name
	main_frame.location = {x = frame_location.x, y = target_y}

	return main_frame
end


---@param gui LuaGuiElement
---@param sprite_path string
---@param name string?
---@return LuaGuiElement
function GuiTemplater.create_slot_button(gui, sprite_path, name)
	local button = gui.add(GuiTemplater.buttons.slot_button)
	if name then
		button.name = name
	end

	if helpers.is_valid_sprite_path(sprite_path) then
		button.sprite = sprite_path
	else
		GuiTemplater._log("Unknown sprite: " .. sprite_path, game.get_player(gui.player_index))
		button.sprite = "utility/missing_icon" -- or utility/missing_mod_icon
	end

	return button
end


---@param gui LuaGuiElement
---@param name string
---@param value number|string?
---@param allow_decimal boolean?
---@param allow_negative boolean?
---@return LuaGuiElement
function GuiTemplater.create_counter_gui(gui, name, value, allow_decimal, allow_negative)
	local flow = gui.add(GuiTemplater.flow)

	GuiTemplater.create_nerd_action_button24(flow, "", name .. "_less")
	local input = flow.add{
		type = "textfield",
		name = name,
		numeric = true,
		allow_decimal  = allow_decimal,
		allow_negative = allow_negative,
		text = value and tostring(value)
	}
	input.style.width = 50
	GuiTemplater.create_nerd_action_button24(flow, "", name .. "_more")

	return input
end


---@param player LuaPlayer
---@param x number
---@param y number
---@param offset_x number? # left offset
---@param offset_y number? # top offset
---@param min_x number? # left minimum
---@param min_y number? # top  minimum
---@param max_x number? # left maximum
---@param max_y number? # top  maximum
---@return GuiLocation.0
function GuiTemplater.get_location_by_percentage(player, x, y, offset_x, offset_y, min_x, min_y, max_x, max_y)
	if x > 100 then x = 1 end
	if y > 100 then y = 1 end
	if x > 1 then x = x / 100 end
	if y > 1 then y = y / 100 end

	local resolution = player.display_resolution
	x = resolution.width * x + (offset_x or 0)
	y = resolution.height * y + (offset_y or 0)

	if x < (min_x or 0) then
		x = (min_x or 0)
	elseif x > (max_x or (resolution.width - 20)) then
		x = (max_x or (resolution.width - 20))
	end

	if y < (min_y or 0) then
		y = (min_y or 0)
	elseif y > (max_y or (resolution.height - 20)) then
		y = (max_y or (resolution.height - 20))
	end

	return {x = x, y = y}
end
GuiTemplater.get_location_by_percentage_with_offset = GuiTemplater.get_location_by_percentage


if script.active_mods["zk-lib"] then
	---WARNING: Requires zk-lib!
	---@param player LuaPlayer
	---@param frame_name string?
	---@param location GuiLocation?
	---@return LuaGuiElement, LuaGuiElement #transparent_frame, top_frame
	function GuiTemplater.create_horizontal_transparent_frame(player, frame_name, location)
		local screen = player.gui.screen
		local prev_location
		if frame_name and screen[frame_name] then
			prev_location = screen[frame_name].location
			screen[frame_name].destroy()
		end

		local top_frame = screen.add(GuiTemplater.frames.borderless_frame)
		top_frame.location = location or prev_location or {x=55, y=55}
		if frame_name then
			top_frame.name = frame_name
		end

		GuiTemplater.frames.zk_transparent_frame.direction = "horizontal"
		local transparent_frame = top_frame.add(GuiTemplater.frames.zk_transparent_frame)
		GuiTemplater.frames.zk_transparent_frame.direction = nil

		local drag_handler = top_frame.add(GuiTemplater.drag_handler)
		drag_handler.drag_target = top_frame
		local style = drag_handler.style
		style.horizontally_stretchable = false
		style.vertically_stretchable   = false
		style.margin = 0
		style.width  = 19
		style.height = 25

		return transparent_frame, top_frame
	end


	---WARNING: Requires zk-lib!
	---@param player LuaPlayer
	---@param frame_name string?
	---@param location GuiLocation?
	---@return LuaGuiElement, LuaGuiElement #transparent_frame, top_frame
	function GuiTemplater.create_vertical_transparent_frame(player, frame_name, location)
		local screen = player.gui.screen
		local prev_location
		if frame_name and screen[frame_name] then
			prev_location = screen[frame_name].location
			screen[frame_name].destroy()
		end

		GuiTemplater.frames.borderless_frame.direction = "vertical"
		local top_frame = screen.add(GuiTemplater.frames.borderless_frame)
		GuiTemplater.frames.borderless_frame.direction = nil
		top_frame.location = location or prev_location or {x=55, y=55}
		if frame_name then
			top_frame.name = frame_name
		end

		local flow = top_frame.add(GuiTemplater.flow)
		flow.add(GuiTemplater.empty_widget).style.horizontally_stretchable = true

		local drag_handler = flow.add(GuiTemplater.drag_handler)
		drag_handler.drag_target = top_frame
		local style = drag_handler.style
		style.horizontally_stretchable = false
		style.vertically_stretchable   = false
		style.margin = 0
		style.width  = 28
		style.height = 16

		GuiTemplater.frames.zk_transparent_frame.direction = "vertical"
		local transparent_frame = top_frame.add(GuiTemplater.frames.zk_transparent_frame)
		GuiTemplater.frames.zk_transparent_frame.direction = nil

		return transparent_frame, top_frame
	end


	---Creates a button with style for font: "SymbolsNerdFont16", which looks like a sprite-button with size 16 + 8
	---WARNING: Requires zk-lib >= 0.15.7!
	---@param gui LuaGuiElement
	---@param symbol string?
	---@param name string?
	---@return LuaGuiElement
	function GuiTemplater.create_nerd_action_button24(gui, symbol, name)
		local new_gui = gui.add(GuiTemplater.buttons.ZO_nerd_action_button24)
		if name then
			new_gui.name = gui.name
		end

		if symbol then
			new_gui.caption = "[font=SymbolsNerdFont16]" .. symbol .. "[/font]"
		end

		return gui
	end


	---Creates a button with style for font: "SymbolsNerdFont32", which looks like a sprite-button with size 32 + 8
	---WARNING: Requires zk-lib >= 0.15.7!
	---@param gui LuaGuiElement
	---@param symbol string?
	---@param name string?
	---@return LuaGuiElement
	function GuiTemplater.create_nerd_action_button40(gui, symbol, name)
		local new_gui = gui.add(GuiTemplater.buttons.ZO_nerd_action_button40)
		if name then
			new_gui.name = gui.name
		end

		if symbol then
			new_gui.caption = "[font=SymbolsNerdFont32]" .. symbol .. "[/font]"
		end

		return gui
	end
end


-- It'll try to create gui and fix buttons, styles, same names when an error occurs
---@param gui LuaGuiElement
---@param element LuaGuiElement.add_param
---@param player LuaPlayer?
---@return boolean, LuaGuiElement|string
function GuiTemplater.create_GUI_safely(gui, element, player)
	local is_ok, newGui = pcall(gui.add, element)
	if is_ok then
		return true, newGui
	end
	GuiTemplater._log(newGui, player)

	if element.type == "sprite-button" and newGui:find("^Unknown sprite") then
		element.sprite = "utility/missing_icon" -- or utility/missing_mod_icon
		element.hovered_sprite = nil
		element.clicked_sprite = nil
		return GuiTemplater.create_GUI_safely(gui, element, player)
	elseif newGui:find("^Unknown style") then
		element.style = nil
		return GuiTemplater.create_GUI_safely(gui, element, player)
	elseif newGui:find("^Gui element with name ") or newGui:find("^Invalid name ") then
		element.name = nil
		return GuiTemplater.create_GUI_safely(gui, element, player)
	end

	return false, newGui
end


---@param message string|table
---@param player LuaPlayer?
GuiTemplater._log = function(message, player)
	log(message)

	if not GuiTemplater.print_errors_to_admins then return end
	if not (game and game.connected_players) then return end

	local RED_COLOR = {1, 0, 0}
	for _, _player in pairs(game.connected_players) do
		if _player.valid and _player.admin then
			_player.print(message, RED_COLOR) -- TODO: IMPROVE!
		end
	end
end


GuiTemplater.__events = {
	on_create = true,
	on_finish = true,
	on_pre_destroy = true,
	on_pre_clear = true,
}


return GuiTemplater
