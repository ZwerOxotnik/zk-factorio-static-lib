--[[
  This is modified version of https://github.com/wube/factorio-data/blob/master/core/lualib/event_handler.lua
  Modified by ZwerOxotnik
]]

---@type table<string, table>
local libraries = {}

local setup_ran = false

local register_remote_interfaces = function()
  --Sometimes, in special cases, on_init and on_load can be run at the same time. Only register events once in this case.
  if setup_ran then return end
  setup_ran = true

  for _, lib in pairs(libraries) do
    if lib.add_remote_interface then
      lib.add_remote_interface()
    end

    if lib.add_commands then
      lib.add_commands()
    end
  end
end

local register_events = function()
  local all_events = {}
  local on_nth_tick = {}

  for lib_name, lib in pairs(libraries) do
    if lib.events then
      for k, handler in pairs(lib.events) do
        all_events[k] = all_events[k] or {}
        all_events[k][lib_name] = handler
      end
    end

    if lib.on_nth_tick then
      for n, handler in pairs(lib.on_nth_tick) do
        on_nth_tick[n] = on_nth_tick[n] or {}
        on_nth_tick[n][lib_name] = handler
      end
    end
  end

  for event, handlers in pairs(all_events) do
		local count = 0
		for _ in pairs(handlers) do
			count = count + 1
		end
		if count == 1 then
			local _, func = next(handlers)
			script.on_event(event, func)
		else
			-- TODO: improve
			local action = function(_event)
				for _, handler in pairs(handlers) do
					handler(_event)
				end
			end
			script.on_event(event, action)
		end
  end

  for n, handlers in pairs(on_nth_tick) do
		local count = 0
		for _ in pairs(handlers) do
			count = count + 1
		end

		if count == 1 then
			local _, func = next(handlers)
			script.on_nth_tick(n, func)
		else
			-- TODO: improve
			local action = function(event)
				for _, handler in pairs(handlers) do
					handler(event)
				end
			end
			script.on_nth_tick(n, action)
		end
  end

end

script.on_init(function()
  register_remote_interfaces()
  register_events()
  for _, lib in pairs(libraries) do
    if lib.on_init then
      lib.on_init()
    end
  end
end)

script.on_load(function()
  register_remote_interfaces()
  register_events()
  for _, lib in pairs(libraries) do
    if lib.on_load then
      lib.on_load()
    end
  end
end)

script.on_configuration_changed(function(data)
  for _, lib in pairs(libraries) do
    if lib.on_configuration_changed then
      lib.on_configuration_changed(data)
    end
  end
end)


local handler = {}

handler.add_lib = function(lib)
  for _, current in pairs(libraries) do
    if current == lib then
      error("Trying to register same lib twice")
    end
  end
  table.insert(libraries, lib)
end

handler.add_libraries = function(libs)
  for _, lib in pairs(libs) do
    handler.add_lib(lib)
  end
end

return handler
