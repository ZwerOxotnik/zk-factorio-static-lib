---@class MFlauxlib
local lauxlib = {}


---Got some help from JanSharp (https://github.com/JanSharp/phobos/issues/4)


---transcribed from [lauxlib.c](https://github.com/Rseding91/Factorio-Lua/blob/a402810b47438402bb0f73c4e12671d1fcfb7ee1/src/lauxlib.c#L101-L113)
---for Factorio Lua
---@return integer
lauxlib.count_levels = function()
	local li = 4
	local le = 3 -- minimal level is 2, so it'll check 3rd one first
	-- find an upper bound
	while debug.getinfo(le, "t") do
	li = le
	le = le * 2
	end

	-- do a binary search
	while li < le do
		local m = math.floor((li + le) / 2)
		if debug.getinfo(m, "t") then
			li = m + 1
		else
			le = m
		end
	end

	return le - 2
end


---Returns a table with information about the first function.
---@param what infowhat? # Default: "S".
---@return debuginfo
---
---[View about debug.getinfo](command:extension.lua.doc?["en-us/52/manual.html/pdf-debug.getinfo"])
lauxlib.get_first_lua_func_info = function(what)
	what = what or "S"

	local li = 4
	local le = 3 -- minimal level is 2, so it'll check 3rd one first
	-- find an upper bound
	while debug.getinfo(le, "t") do
		li = le
		le = le * 2
	end

	-- do a binary search
	while li < le do
		local m = math.floor((li + le) / 2)
		if debug.getinfo(m, "t") then
			li = m + 1
		else
			le = m
		end
	end

	return debug.getinfo(le - 1, what)
end


return lauxlib
