---@class ZOremote_interface_util
local remote_interface_util = {build = 3}


--[[
remote_interface_util.expose_global_data()
]]


function remote_interface_util.expose_global_data()
	local interface_name =  script.mod_name .. "_ZO_public"
	if remote.interfaces[interface_name] then
		log(string.format("remote.interfaces[\"%s\"] will be recreated", interface_name)) -- TODO: improve
		remote.remove_interface(interface_name) -- for safety
	end

	remote.add_interface(interface_name, {
		---@param ... any
		---@return any?
		get = function(...)
			local data = global
			local parameters = {...}
			for _, path in ipairs(parameters) do
				if type(data) ~= "table" then
					return nil
				end
				data = data[path]
				if data == nil then
					return nil
				end
			end

			return data
		end,
		---@param data any
		---@param ... any
		---@return boolean
		set = function(data, ...)
			local prev_data = global --[[@as table]]
			local _data = prev_data
			local parameters = {...}
			for _, path in ipairs(parameters) do
				if type(_data) ~= "table" then
					return false
				end
				prev_data = _data
				_data = _data[path]
				if _data == nil then
					return false
				end
			end

			---@cast _data any
			prev_data[_data] = data
			return true
		end,
		---@param ... any
		---@return any?
		get_from_ENV = function(...)
			local data = _ENV
			local parameters = {...}
			for _, path in ipairs(parameters) do
				if type(data) ~= "table" then
					return nil
				end
				data = data[path]
				if data == nil then
					return nil
				end
			end

			return data
		end,
	})
end


return remote_interface_util
