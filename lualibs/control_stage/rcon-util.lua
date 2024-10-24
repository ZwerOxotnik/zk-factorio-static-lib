---@class ZOrcon_util
local rcon_util = {build = 4}


--[[
rcon_util.expose_global_data()
]]


function rcon_util.expose_global_data()
	local interface_name =  script.mod_name .. "_ZO_rcon"
	remote.remove_interface(interface_name) -- for safety
	remote.add_interface(interface_name, {
		---@param ... any
		print = function(...)
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
			if type(data) == "userdata" then
				return nil
			end

			if type(data) == "table" then
				rcon.print(helpers.table_to_json(data))
			else
				rcon.print(data)
			end
		end,
	})
end


return rcon_util
