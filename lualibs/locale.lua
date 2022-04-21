local M = {}


local ceil = math.ceil
local deepcopy = table.deepcopy
local tinsert = table.insert


---@param array table
---@return table?
M.array_to_locale = function(array)
	local final_data = {}
	if #array >= 380 then
			log("Too much data")
			return
	elseif #array > 10 then
		for i=1, ceil(#array/20)+1 do
			final_data[i] = {""}
		end
		local i = 1
		local j = 2
		for _, _data in pairs(array) do
			final_data[i][j] = _data
			if j >= 20 then
				i = i + 1
				j = 2
			else
				j = j + 1
			end
		end
	else
		final_data = array
	end

	if type(final_data[1]) ~= "string" then
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
	local final_data = {}
	if #array >= 380 then
			log("Too much data")
			return
	elseif #array > 10 then
		for i=1, ceil(#array/20)+1 do
			final_data[i] = {""}
		end
		local i = 1
		local j = 2
		for _, _data in pairs(array) do
			final_data[i][j] = deepcopy(_data)
			if j >= 20 then
				i = i + 1
				j = 2
			else
				j = j + 1
			end
		end
	else
		final_data = array
	end

	if type(final_data[1]) ~= "string" then
		tinsert(final_data, 1, '')
	end
	if #final_data > 20 then
		log("Too much data")
		return
	end

	return final_data
end


---@vararg table
---@return table
M.merge_locales = function(...)
  local args = {...}
  local new_locale = {''}

  for i=1, #args do
    new_locale[i+1] = args[i]
  end

  return new_locale
end


---@vararg table
---@return table
M.merge_locales_as_new = function(...)
  local args = {...}
  local new_locale = {''}

  for i=1, #args do
    new_locale[i+1] = deepcopy(args[i])
  end

  return new_locale
end

return M
