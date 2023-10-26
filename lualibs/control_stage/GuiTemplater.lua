--- Quite simple library to handle GUIs in almost data-driven manner. It doesn't use "global" yet.
--- WARNING: events "on_*" as fields for "children" weren't implemented yet

local ZOGuiTemplater = {build = 3}

---@type table<uint, fun(event: EventData)>
ZOGuiTemplater.events = {}
---@type table<string, ZOGuiTemplate.event_func>
ZOGuiTemplater.events_GUIs = {
	[script.mod_name .. "_close"] = function(element, player, event)
		element.parent.parent.destroy()
	end
}
ZOGuiTemplater.raise_error = false


ZOGuiTemplater.close_button = {
	hovered_sprite = "utility/close_black",
	clicked_sprite = "utility/close_black",
	sprite = "utility/close_white",
	style = "frame_action_button",
	type = "sprite-button",
	name = script.mod_name .. "_close"
}
ZOGuiTemplater.drag_handler  = {type = "empty-widget", name = "drag_handler", style = "draggable_space"}
ZOGuiTemplater.shallow_frame = {type = "frame", name = "shallow_frame", style = "inside_shallow_frame"}


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
---@field raise_error? boolean
--TODO: create_for_new_players, create_for_joined_players, destroy_for_left_players


---@class ZOGuiTemplate: ZOGuiTemplater.data
---@field createGUIs  fun(gui: LuaGuiElement?, element: ZOGuiTemplater.data?): boolean
---@field destroyGUIs fun(gui: LuaGuiElement?): boolean
---@field clear       fun(gui: LuaGuiElement?): boolean


---@param _template_data ZOGuiTemplater.data
local function _checkEvents(_template_data)
	local is_valid = true
	if _template_data.element.name == nil then
		is_valid = false
		log("There's no name for GuiElement")
	end
	if is_valid and (_template_data.events or _template_data.event) then
		for _, event_data in ipairs(_template_data.events or {_template_data.event}) do
			if type(event_data[1]) == "string" then
				event_data[1] = defines.events[event_data[1]]
			end
			local events_GUIs = ZOGuiTemplater.events_GUIs
			ZOGuiTemplater.events[event_data[1]] = ZOGuiTemplater.events[event_data[1]] or
				---@param event EventData
				function(event)
				local element = event.element
				if not (element and element.valid) then return end
				local f = events_GUIs[element.name]
				if f then
					f(element, game.get_player(event.player_index), event)
				end
			end
			events_GUIs[_template_data.element.name] = event_data[2]
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

	template.createGUIs = function(gui, template_data)
		if not (gui and gui.valid) then return false end

		template_data = template_data or init_data

		local is_ok, newGui, result
		local element = template_data.element
		if template_data.raise_error or (ZOGuiTemplater.raise_error and template_data.raise_error ~= false) then
			newGui = gui.add(element)
		else
			is_ok, newGui = pcall(gui.add, element)
			if not is_ok then
				log(newGui)
				return false
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
					log(result)
					return false
				end
			end
		end

		if not newGui.valid then return false end

		local children = template_data.children
		if children then
			for i=1, #children do
				is_ok, result = template.createGUIs(newGui, children[i])
				if not is_ok then
					log(result)
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
	top_flow.add(ZOGuiTemplater.close_button)

	local shallow_frame = main_frame.add(ZOGuiTemplater.shallow_frame)
	shallow_frame.style.padding = 8

	if prev_location then
		main_frame.location = prev_location
	else
		main_frame.force_auto_center()
	end

	return shallow_frame
end


return ZOGuiTemplater
