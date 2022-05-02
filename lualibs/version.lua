-- Works for any stage
local M = {}


-- Supports strings like: "5", "5.5", "5.5.5"
---@param str string
---@return number version
---@overload fun()
M.string_to_version = function(str)
  if not str then return end
  local version, major, patch = str:match("(%d+)%.?(%d*)%.?(%d*)")
  version = version * 1e10
  if major then version = version + (major * 1e5) end
  if patch then version = version + patch end
  return version
end


---@param mod_name string
---@return version
---@overload fun()
M.get_mod_version = nil

if script and script.active_mods then
  -- For control stage
  M.get_mod_version = function(mod_name)
    return M.string_to_version(scripts.active_mods[mod_name])
  end
else
  -- For data/settings stage
  M.get_mod_version = function(mod_name)
    return M.string_to_version(mods[mod_name])
  end
end


return M
