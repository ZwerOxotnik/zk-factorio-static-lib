local M = {}


local type = type
local deepcopy = table.deepcopy
local tinsert = table.insert


---@param array table
---@return table?
M.array_to_locale = function(array)
	local final_data
	if #array >= 380 then
		log("Too much data")
		return
	elseif #array <= 10 then
		final_data = array
	else
		final_data = {{''}}
		local i = 1
		local j = 2
		for _, _data in pairs(array) do
			local row = final_data[i]
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
				i = i + 1
				final_data[i] = {''}
				j = 2
			else
				j = j + 1
			end
			::skip_itertion::
		end
	end

	if type(final_data[1]) == "string" then
		if final_data[1] ~= '' then
			tinsert(final_data, 1, '')
		end
	else
		tinsert(final_data, 1, '')
	end
	if #final_data > 20 then
		log("Too much data")
		return
	end

	return final_data
end


---@param array table
---@return table?
M.array_to_locale_as_new = function(array)
	local locale = M.array_to_locale(array)
	if locale then
		return deepcopy(locale)
	end
end


---@param locale table
---@return table
M.locale_to_array = function(locale)
	local v1 = locale[1]
	if not (type(v1) == "string" and #v1 == 0) then return locale end

	local array = {}
	for _, _data in pairs(locale) do
		local _type = type(_data)
		if _type == "table" then
			local new_array = M.locale_to_array(_data)
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
M.merge_locales = function(...)
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
					local new_array = M.locale_to_array(data)
					if new_array == data or #new_array == 0 then
						new_locale[#new_locale+1] = data
					else
						for i=1, #new_array do
							new_locale[#new_locale+1] = new_array[i]
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

	return M.array_to_locale(new_locale)
end


---@vararg table
---@return table
M.merge_locales_as_new = function(...)
	return deepcopy(M.merge_locales(...))
end

local t2 = M.merge_locales({'', nil, "tsef", {"test", 3, 2, 4}, {'', "test", {'', "test"}}},{'', nil, "tsef", {"test"}, {'', "test", {'', "test"}}},{'', nil, "tsef", {"test"}, {'', "test", {'', "test"}}},{'', nil, "tsef", {"test"}, {'', "test", {'', "test"}}},{'', nil, "tsef", {"test"}, {'', "test", {'', "test"}}},{'', nil, "tsef", {"test"}, {'', "test", {'', "test"}}},{'', nil, "tsef", {"test"}, {'', "test", {'', "test"}}},{'', nil, "tsef", {"test"}, {'', "test", {'', "test"}}},{'', nil, "tsef", {"test"}, {'', "test", {'', "test"}}},{'', nil, "tsef", {"test"}, {'', "test", {'', "test"}}}, nil, {{"fesfes"}, nil, nil, 44})
g = 4

return M
