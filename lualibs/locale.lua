---@class ZOlocale_util
local locale_util = {build = 1}


--[[
locale_util.array_to_locale(array): table?
locale_util.array_to_locale_as_new(array): table?
locale_util.locale_to_array(locale): table
locale_util.merge_locales(...: table): table
locale_util.merge_locales_as_new(...: table): table
]]


local type = type
local deepcopy = table.deepcopy
local tinsert = table.insert


---@param array table
---@return table?
function locale_util.array_to_locale(array)
	local locale
	if #array <= 10 then
		locale = array
	else
		locale = {{''}}
		local i = 1
		local j = 2
		for _, _data in pairs(array) do
			local row = locale[i]
			if type(_data) == "string" then
				if j > 2 then
					local prev_data = row[j-1]
					if type(prev_data) == "string" then
						row[j-1] = prev_data .. _data
						goto skip_itertion
					end
				end
			end
			row[j] = _data
			if j >= 20 then
				if i >= 20 then
					log("Too much data")
					return
				end
				i = i + 1
				locale[i] = {''}
				j = 2
			else
				j = j + 1
			end
			::skip_itertion::
		end
	end

	if type(locale[1]) == "string" then
		if locale[1] ~= '' then
			tinsert(locale, 1, '')
		end
	else
		tinsert(locale, 1, '')
	end

	return locale
end


---@param array table
---@return table?
function locale_util.array_to_locale_as_new(array)
	local locale = locale_util.array_to_locale(array)
	if locale then
		return deepcopy(locale)
	end
end


---@param locale table
---@return table
function locale_util.locale_to_array(locale)
	local v1 = locale[1]
	if not (type(v1) == "string" and #v1 == 0) then return locale end

	local array = {}
	for _, _data in pairs(locale) do
		local _type = type(_data)
		if _type == "table" then
			local new_array = locale_util.locale_to_array(_data)
			if new_array == _data then
				array[#array+1] = _data
			else
				for _, __data in next, new_array do
					array[#array+1] = __data
				end
			end
		elseif _type == "string" then
			if #_data ~= 0 then
				array[#array+1] = _data
			end
		else
			array[#array+1] = _data
		end
	end
	return array
end


---@vararg table
---@return table
function locale_util.merge_locales(...)
	local args = {...}
	local new_locale = {}

	for _, locale in pairs(args) do
		local _, v = next(locale)
		if type(v) == "table" then
			new_locale[#new_locale+1] = locale
		else
			for _, data in pairs(locale) do
				local _type = type(data)
				if _type == "table" then
					local new_array = locale_util.locale_to_array(data)
					if new_array == data or #new_array == 0 then
						new_locale[#new_locale+1] = data
					else
						for _, _v in pairs(new_array) do
							new_locale[#new_locale+1] = _v
						end
					end
				elseif _type == "string" then
					if #data ~= 0 then
						new_locale[#new_locale+1] = data
					end
				else
					new_locale[#new_locale+1] = data
				end
			end
		end
	end

	return locale_util.array_to_locale(new_locale)
end


---@vararg table
---@return table
function locale_util.merge_locales_as_new(...)
	return deepcopy(locale_util.merge_locales(...))
end


return locale_util
