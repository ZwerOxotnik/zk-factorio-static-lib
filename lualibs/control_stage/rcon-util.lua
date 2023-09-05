---@class ZOrcon_util
local rcon_util = {build = 1}


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
			local parameters = table.pack(...)
			for _, path in ipairs(parameters) do
				if type(data) ~= "table" then
					return
				end
				data = data[path]
				if data == nil then
					return
				end
			end
			if type(data) == "userdata" then
				return
			end

			if type(data) == "table" then
				rcon.print(game.table_to_json(data))
			else
				rcon.print(tostring(data))
			end
		end,
	})
end


return rcon_util
