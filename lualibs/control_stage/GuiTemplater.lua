--- Quite simple library to handle GUIs in almost data-driven manner, fixing missing sprites. It doesn't use "global" yet.
--- WARNING: events "on_*" as fields for "children" weren't implemented yet

local ZOGuiTemplater = {build = 4}

---@type table<uint, fun(event: EventData)>
ZOGuiTemplater.events = {}
---@type table<string, ZOGuiTemplate.event_func>
ZOGuiTemplater.events_GUIs = {
	[script.mod_name .. "_close"] = function(element, player, event)
		element.parent.parent.destroy()
	end
}
ZOGuiTemplater.raise_error = false
ZOGuiTemplater.print_errors_to_admins = true



---@alias ZOGuiTemplate.event_func fun(element: LuaGuiElement, player: LuaPlayer, event: EventData)


---@class ZOGuiTemplater.event: table
---@field [1] string|uint # event id/name
---@field [2] ZOGuiTemplate.event_func


---@class ZOGuiTemplater.data: table
---@field element LuaGuiElement
---@field on_create? fun(gui: LuaGuiElement) # WARNING: works only for top element
---@field on_finish? fun(gui: LuaGuiElement) # WARNING: works only for top element
---@field on_pre_destroy? fun(gui: LuaGuiElement) # WARNING: works only for top element
---@field on_pre_clear?   fun(gui: LuaGuiElement) # WARNING: works only for top element
---@field event?  ZOGuiTemplater.event
---@field events? ZOGuiTemplater.event[]
---@field children? ZOGuiTemplater.data[]
---@field style? table<string, any> # see https://lua-api.factorio.com/latest/classes/LuaStyle.html
---@field admin_only?  boolean # Creates GUI if player is admin
---@field raise_error? boolean
---@field on_gui_selection_state_changed? ZOGuiTemplate.event_func
---@field on_gui_checked_state_changed? ZOGuiTemplate.event_func
---@field on_gui_click? ZOGuiTemplate.event_func
---@field on_gui_closed? ZOGuiTemplate.event_func
---@field on_gui_confirmed? ZOGuiTemplate.event_func
---@field on_gui_elem_changed? ZOGuiTemplate.event_func
---@field on_gui_hover? ZOGuiTemplate.event_func
---@field on_gui_leave? ZOGuiTemplate.event_func
---@field on_gui_location_changed? ZOGuiTemplate.event_func
---@field on_gui_opened? ZOGuiTemplate.event_func
---@field on_gui_selected_tab_changed? ZOGuiTemplate.event_func
---@field on_gui_switch_state_changed? ZOGuiTemplate.event_func
---@field on_gui_text_changed? ZOGuiTemplate.event_func
---@field on_gui_value_changed? ZOGuiTemplate.event_func
--TODO: create_for_new_players, create_for_joined_players, destroy_for_left_players


---@class ZOGuiTemplate: ZOGuiTemplater.data
---@field createGUIs  fun(gui: LuaGuiElement?): boolean
---@field destroyGUIs fun(gui: LuaGuiElement?): boolean
---@field clear       fun(gui: LuaGuiElement?): boolean


---@type table<string, table>
ZOGuiTemplater.buttons = {
	confirm_button = {type = "button", caption = {"gui.confirm"}},
	cancel_button  = {type = "button", caption = {"gui-mod-settings.cancel"}},
	plus = {type = "sprite-button", style = "frame_action_button"}, -- from zk-lib
	missing_icon = {type = "sprite-button", sprite = "utility/missing_icon"},
	cross_select = {type = "sprite-button", sprite = "utility/cross_select"},
	book = {type = "sprite-button", sprite = "utility/custom_tag_icon"},
	gps_map = {type = "sprite-button", sprite = "utility/gps_map_icon"},
	crafting_machine_recipe_not_unlocked = {type = "sprite-button", sprite = "utility/crafting_machine_recipe_not_unlocked"},
	prohibit = {type = "sprite-button", sprite = "utility/crafting_machine_recipe_not_unlocked"},
	favourite_server_icon = {type = "sprite-button", sprite = "utility/favourite_server_icon"},
	factorio_icon = {type = "sprite-button", sprite = "utility/favourite_server_icon"},
	custom_tag_in_map_view = {type = "sprite-button", sprite = "utility/custom_tag_in_map_view"},
	fire = {type = "sprite-button", sprite = "utility/heat_exchange_indication"},
	yellow_arrow_up = {type = "sprite-button", sprite = "utility/rail_planner_indication_arrow_too_far"},
	green_arrow_up  = {type = "sprite-button", sprite = "utility/rail_planner_indication_arrow"},
	blue_arrow_up   = {type = "sprite-button", sprite = "utility/fluid_indication_arrow"},
	questionmark = {type = "sprite-button", sprite = "utility/questionmark"},
	waiting_icon = {type = "sprite-button", sprite = "utility/multiplayer_waiting_icon"},
	player = {type = "sprite-button", sprite = "utility/player_force_icon"},
	time_editor = {type = "sprite-button", sprite = "utility/time_editor_icon"},
	surfaces    = {type = "sprite-button", sprite = "utility/surface_editor_icon"},
	resources   = {type = "sprite-button", sprite = "utility/resource_editor_icon"},
	tiles       = {type = "sprite-button", sprite = "utility/tile_editor_icon"},
	scripting_editor_icon = {type = "sprite-button", sprite = "utility/scripting_editor_icon"},
	clone_editor_icon = {type = "sprite-button", sprite = "utility/clone_editor_icon"},
	upgrade_blueprint = {type = "sprite-button", sprite = "utility/upgrade_blueprint"},
	deconstruction_mark = {type = "sprite-button", sprite = "utility/deconstruction_mark"},
	clock = {type = "sprite-button", sprite = "utility/clock"},
	danger_icon = {type = "sprite-button", sprite = "utility/danger_icon"},
	destroyed_icon = {type = "sprite-button", sprite = "utility/destroyed_icon"},
	recharge_icon = {type = "sprite-button", sprite = "utility/recharge_icon"},
	too_far_from_roboport_icon = {type = "sprite-button", sprite = "utility/too_far_from_roboport_icon"},
	warning_icon = {type = "sprite-button", sprite = "utility/warning_icon"},
	fluid_icon = {type = "sprite-button", sprite = "utility/fluid_icon"},
	ammo_icon = {type = "sprite-button", sprite = "utility/ammo_icon"},
	fuel_icon = {type = "sprite-button", sprite = "utility/fuel_icon"},
	electricity_icon = {type = "sprite-button", sprite = "utility/electricity_icon"},
	too_far = {type = "sprite-button", sprite = "utility/too_far"},
	_close = {
		hovered_sprite = "utility/close_black",
		clicked_sprite = "utility/close_black",
		sprite = "utility/close_white",
		style = "frame_action_button",
		type = "sprite-button",
		name = script.mod_name .. "_close"
	},
	close = {
		hovered_sprite = "utility/close_black",
		clicked_sprite = "utility/close_black",
		sprite = "utility/close_white",
		style = "frame_action_button",
		type = "sprite-button"
	},
	confirm = { -- TODO: improve style and add white sprite
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/confirm_slot",
	},
	hand = {
		type = "sprite-button",
		style = "slot_button",
		sprite = "utility/hand",
		hovered_sprite = "utility/hand_black",
		clicked_sprite = "utility/hand_black"
	},
	search = {
		type = "sprite-button",
		sprite = "utility/search_white",
		hovered_sprite = "utility/search_black",
		clicked_sprite = "utility/search_black"
	},
	refresh = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "refresh_white_icon"
	},
	trash = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/trash_white",
		hovered_sprite = "utility/trash",
		clicked_sprite = "utility/trash"
	},
	map_exchange_string = { -- white sprite from zk-lib
		type = "sprite-button",
		style = "frame_action_button",
		hovered_sprite = "utility/map_exchange_string",
		clicked_sprite = "utility/map_exchange_string"
	},
	lua_snippet_tool = {
		type = "sprite-button",
		name = "UB_run_public_script",
		style = "frame_action_button",
		sprite = "lua_snippet_tool_icon_white",
		hovered_sprite = "utility/lua_snippet_tool_icon",
		clicked_sprite = "utility/lua_snippet_tool_icon"
	},
	import = { -- TODO: add white button
		type = "sprite-button",
		sprite = "utility/import",
		tooltip = {"gui-blueprint-library.import-string"},
		style = "frame_action_button"
	},
	reset = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/reset_white",
		hovered_sprite = "utility/reset",
		clicked_sprite = "utility/reset"
	},
	warning = { -- TODO: find similar style to "frame_action_button"
		type = "sprite-button",
		sprite = "utility/warning_white",
		hovered_sprite = "utility/warning",
		clicked_sprite = "utility/warning"
	},
	select = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/select_icon_white",
		hovered_sprite = "utility/select_icon_black",
		clicked_sprite = "utility/select_icon_black"
	},
	technology = {
		type = "sprite-button",
		sprite = "utility/technology_white",
		hovered_sprite = "utility/technology_black",
		clicked_sprite = "utility/technology_black"
	},
	slot_icon_module = {
		type = "sprite-button",
		sprite = "utility/slot_icon_module",
		hovered_sprite = "utility/slot_icon_module_black",
		clicked_sprite = "utility/slot_icon_module_black"
	},
	slot_icon_armor = {
		type = "sprite-button",
		sprite = "utility/slot_icon_armor",
		hovered_sprite = "utility/slot_icon_armor_black",
		clicked_sprite = "utility/slot_icon_armor_black"
	},
	gun = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/slot_icon_gun",
		hovered_sprite = "utility/slot_icon_gun_black",
		clicked_sprite = "utility/slot_icon_gun_black"
	},
	fuel = { -- TODO: find similar style to "frame_action_button"
		type = "sprite-button",
		sprite = "utility/slot_icon_fuel",
		hovered_sprite = "utility/slot_icon_fuel_black",
		clicked_sprite = "utility/slot_icon_fuel_black"
	},
	robot = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/slot_icon_robot",
		hovered_sprite = "utility/slot_icon_robot_black",
		clicked_sprite = "utility/slot_icon_robot_black"
	},
	slot_icon_robot_material = {
		type = "sprite-button",
		sprite = "utility/slot_icon_robot_material",
		hovered_sprite = "utility/slot_icon_robot_material_black",
		clicked_sprite = "utility/slot_icon_robot_material_black"
	},
	slot_icon_inserter_hand = {
		type = "sprite-button",
		sprite = "utility/slot_icon_inserter_hand",
		hovered_sprite = "utility/slot_icon_inserter_hand_black",
		clicked_sprite = "utility/slot_icon_inserter_hand_black"
	},
	circuit_network_panel = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/circuit_network_panel_white",
		hovered_sprite = "utility/circuit_network_panel_black",
		clicked_sprite = "utility/circuit_network_panel_black"
	},
	logistic_network_panel = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/logistic_network_panel_white",
		hovered_sprite = "utility/logistic_network_panel_black",
		clicked_sprite = "utility/logistic_network_panel_black"
	},
	rename = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/rename_icon_small_white",
		hovered_sprite = "utility/rename_icon_small_black",
		clicked_sprite = "utility/rename_icon_small_black"
	},
	downloaded = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/downloaded_white",
		hovered_sprite = "utility/downloaded",
		clicked_sprite = "utility/downloaded"
	},
	downloading = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/downloading_white",
	},
	dropdown = { -- TODO: add white sprite
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/dropdown",
	},
	equipment_grid = {
		type = "sprite-button",
		sprite = "utility/equipment_grid",
	},
	expand_dots = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/expand_dots_white",
		hovered_sprite = "utility/expand_dots",
		clicked_sprite = "utility/expand_dots"
	},
	shuffle = { -- TODO: add white sprite
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/shuffle",
	},
	copy = { -- TODO: add white sprite
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/copy",
	},
	reassign = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/reassign",
	},
	list_view = { -- TODO: add white sprite
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/list_view",
	},
	grid_view = { -- TODO: add white sprite
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/grid_view",
	},
	status_working = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/status_working",
	},
	status_not_working = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/status_not_working",
	},
	status_yellow = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/status_yellow",
	},
	bookmark = { -- TODO: add white sprite
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/bookmark",
	},
	alert_arrow = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/alert_arrow",
	},
	notification = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/notification",
	},
	mod_dependency_arrow = { -- right arrow, TODO: add white sprite
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/mod_dependency_arrow",
	},
	map = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/map",
	},
	export = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/export",
	},
	change_recipe = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/change_recipe",
	},
	gears = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/change_recipe",
	},
	color_picker = { -- TODO: add white sprite
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/color_picker",
	},
	close_fat = { -- TODO: add white sprite
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/close_fat",
	},
	close_map_preview = { -- TODO: add white sprite
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/close_map_preview",
	},
	played_green = { -- right arrow
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/played_green",
	},
	played_dark_green = { -- right arrow
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/played_dark_green",
	},
	not_played_yet_green = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/not_played_yet_green",
	},
	not_played_yet_dark_green = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/not_played_yet_dark_green",
	},
	check_mark_green = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/check_mark_green",
	},
	check_mark_dark_green = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/check_mark_dark_green",
	},
	check_mark = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/check_mark_white",
		hovered_sprite = "utility/check_mark",
		clicked_sprite = "utility/check_mark"
	},
	center = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/center",
	},
	collapse = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/collapse",
		hovered_sprite = "utility/collapse_dark",
		clicked_sprite = "utility/collapse_dark"
	},
	expand = {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/expand",
		hovered_sprite = "utility/expand_dark",
		clicked_sprite = "utility/expand_dark"
	},
	underground_remove_pipes = { -- red square with cornerns
		type = "sprite-button",
		style = "frame_action_button",
		sprite = "utility/underground_remove_pipes",
	},
	achievement_label_failed = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/achievement_label_failed",
	},
	enter = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/enter",
	},
	thin_right_arrow = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/right_arrow",
	},
	thin_left_arrow = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/left_arrow",
	},
	spray = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/spray_icon",
	},
	brush = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/brush_icon",
	},
	paint_bucket = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/paint_bucket_icon",
	},
	export_slot = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/export_slot",
	},
	variations_tool = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/variations_tool_icon",
	},
	tick_once = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/tick_once",
	},
	tick_sixty = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/tick_sixty",
	},
	tick_custom = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/tick_custom",
	},
	speed_up = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/speed_up",
	},
	speed_down = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/speed_down",
	},
	play = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/play",
	},
	pause = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/pause",
	},
	stop = { -- TODO: add white sprite, tooltip
		type = "sprite-button",
		sprite = "utility/stop",
	},
	go_to_arrow = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/go_to_arrow",
	},
	clone = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/clone",
	},
	add = { -- TODO: add white sprite
		type = "sprite-button",
		sprite = "utility/add",
	},
}
if script.active_mods["zk-lib"] then
	ZOGuiTemplater.buttons.map_exchange_string.sprite = "map_exchange_string_white"
	ZOGuiTemplater.buttons.plus.sprite = "plus_white"
	ZOGuiTemplater.buttons.plus.hovered_sprite = "plus"
	ZOGuiTemplater.buttons.plus.clicked_sprite = "plus"
end

ZOGuiTemplater.drag_handler = {type = "empty-widget", name = "drag_handler", style = "draggable_space"}
ZOGuiTemplater.inside_shallow_frame = {type = "frame", name = "shallow_frame", style = "inside_shallow_frame"}


---@param _template_data ZOGuiTemplater.data
local function _checkEvents(_template_data)
	local is_valid = true
	if _template_data.element.name == nil then
		is_valid = false
		ZOGuiTemplater._log("There's no name for GuiElement")
	end

	for k, v in pairs(_template_data) do
		if k:find("^on_gui_") then
			_template_data.events = _template_data.events or {}
			_template_data.events[#_template_data.events+1] = {k, v}
		end
	end

	if is_valid and (_template_data.events or _template_data.event) then
		for _, event_data in ipairs(_template_data.events or {_template_data.event}) do
			local event = event_data[1]
			if type(event) == "string" then
				local event_id = defines.events[event]
				if event_id then
					event = defines.events[event]
					event_data[1] = event
				else
					local hidden_event = ZOGuiTemplater.__events[event]
					if hidden_event then
						_template_data[event] = event_data[2]
					end
					goto continue
				end
			end
			local events_GUIs = ZOGuiTemplater.events_GUIs
			ZOGuiTemplater.events[event] = ZOGuiTemplater.events[event] or
				---@param e EventData
				function(e)
				local element = e.element
				if not (element and element.valid) then return end
				local f = events_GUIs[element.name]
				if f then
					f(element, game.get_player(e.player_index), e)
				end
			end
			events_GUIs[_template_data.element.name] = event_data[2]
		    ::continue::
		end
	end

	local children = _template_data.children
	if not children then return end
	for i=1, #children do
		_checkEvents(children[i])
	end
end


---@param init_data ZOGuiTemplater.data
---@return ZOGuiTemplate
function ZOGuiTemplater.create(init_data)
	---@class ZOGuiTemplate
	local template = init_data

	_checkEvents(template)

	template.createGUIs = function(gui, template_data, player)
		---@cast template_data ZOGuiTemplater.data?
		---@cast player LuaPlayer?
		if not (gui and gui.valid) then return false end
		---@type LuaPlayer
		player = player or game.get_player(gui.player_index)

		template_data = template_data or init_data

		if template_data.admin_only and not player.admin then return false end

		local is_ok, newGui, result
		local element = template_data.element
		if template_data.raise_error or (ZOGuiTemplater.raise_error and template_data.raise_error ~= false) then
			newGui = gui.add(element)
		else
			is_ok, newGui = pcall(gui.add, element)
			if not is_ok then
				ZOGuiTemplater._log(newGui, player)
				-- Try to fix buttons
				if element.type == "sprite-button" and newGui:find("Unknown sprite") then
					local prev_sprite = element.sprite
					local prev_hovered_sprite = element.hovered_sprite
					local prev_clicked_sprite = element.clicked_sprite
					element.sprite = "utility/missing_icon" -- utility/missing_mod_icon
					element.hovered_sprite = nil
					element.clicked_sprite = nil
					is_ok, newGui = pcall(gui.add, element)
					if not is_ok then
						element.sprite = prev_sprite
						element.hovered_sprite = prev_hovered_sprite
						element.clicked_sprite = prev_clicked_sprite
					end
				end
				if not is_ok then
					return false
				end
			end
		end

		if template_data.style then
			local style = newGui.style
			for k, v in pairs(template_data.style) do
				style[k] = v
			end
		end

		if template_data.on_create then
			if template_data.raise_error or (ZOGuiTemplater.raise_error and template_data.raise_error ~= false) then
				template_data.on_create(newGui)
			else
				is_ok, result = pcall(template_data.on_create, newGui)
				if not is_ok then
					ZOGuiTemplater._log(result, player)
					return false
				end
			end
		end

		if not newGui.valid then return false end

		local children = template_data.children
		if children then
			for i=1, #children do
				is_ok, result = template.createGUIs(newGui, children[i], player)
				if not is_ok then
					ZOGuiTemplater._log(result, player)
					return false
				end
			end
		end

		if template_data.on_finish then
			if template_data.raise_error or (ZOGuiTemplater.raise_error and template_data.raise_error ~= false) then
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
				if init_data.raise_error or (ZOGuiTemplater.raise_error and init_data.raise_error ~= false) then
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
				if init_data.raise_error or (ZOGuiTemplater.raise_error and init_data.raise_error ~= false) then
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


---@param player LuaPlayer
---@param frame_name string
---@param title string|table?
---@return LuaGuiElement
ZOGuiTemplater.create_screen_window = function(player, frame_name, title)
	local screen = player.gui.screen
	local prev_location
	if screen[frame_name] then
		prev_location = screen[frame_name].location
		screen[frame_name].destroy()
	end
	local main_frame = screen.add{type = "frame", name = frame_name, direction = "vertical"}
	-- main_frame.style.horizontal_spacing = 0 -- it doesn't work
	main_frame.style.padding = 4

	local top_flow = main_frame.add{type = "flow"}
	top_flow.style.horizontal_spacing = 0
	if title then
		top_flow.add{
			type = "label",
			style = "frame_title",
			caption = title,
			ignored_by_interaction = true
		}
	end
	local drag_handler = top_flow.add(ZOGuiTemplater.drag_handler)
	drag_handler.drag_target = main_frame
	drag_handler.style.horizontally_stretchable = true
	drag_handler.style.vertically_stretchable   = true
	drag_handler.style.margin = 0
	top_flow.add(ZOGuiTemplater.buttons._close)

	local shallow_frame = main_frame.add(ZOGuiTemplater.inside_shallow_frame)
	shallow_frame.style.padding = 8

	if prev_location then
		main_frame.location = prev_location
	else
		main_frame.force_auto_center()
	end

	return shallow_frame
end


---@param message string|table
---@param player LuaPlayer?
ZOGuiTemplater._log = function(message, player)
	log(message)

	if not ZOGuiTemplater.print_errors_to_admins then return end
	if not (game and game.connected_players) then return end

	local RED_COLOR = {1, 0, 0}
	for _, _player in pairs(game.connected_players) do
		if _player.valid and _player.admin then
			_player.print(message, RED_COLOR) -- TODO: IMPROVE!
		end
	end
end


ZOGuiTemplater.__events = {
	on_create = true,
	on_finish = true,
	on_pre_destroy = true,
	on_pre_clear = true,
}


return ZOGuiTemplater
