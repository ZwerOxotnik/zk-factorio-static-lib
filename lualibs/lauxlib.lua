---@class MFlauxlib
local lauxlib = {}


---Got some help from JanSharp (https://github.com/JanSharp/phobos/issues/4)


---Optimized version of [lauxlib.c](https://github.com/Rseding91/Factorio-Lua/blob/a402810b47438402bb0f73c4e12671d1fcfb7ee1/src/lauxlib.c#L101-L113)
---for Factorio Lua
---@return integer
lauxlib.count_levels = function()
	local li = 16
	local le = 15
	-- find bounds
	if not debug.getinfo(16, "t") then
		repeat
			le = li
			li = li / 2
		until debug.getinfo(li, "t")
	else
		repeat
			li = le
			le = le + le
		until not debug.getinfo(le, "t")
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

	local li = 16
	local le = 15
	-- find bounds
	if not debug.getinfo(16, "t") then
		repeat
			le = li
			li = li / 2
		until debug.getinfo(li, "t")
	else
		repeat
			li = le
			le = le + le
		until not debug.getinfo(le, "t")
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
