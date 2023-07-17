-- Works for any stage
---@class ZWversion
local version_util = {build = 1}


--[[
version_util.string_to_version(str): number
version_util.string_to_version()
version_util.get_mod_version(mod_name): integer
]]


-- Supports strings like: "5", "5.5", "5.5.5"
---@param str string
---@return integer? # version
---@overload fun()
function version_util.string_to_version(str)
  if not str then return end
  local version, major, patch = str:match("(%d+)%.?(%d*)%.?(%d*)")
  version = version * 1e10
  if major then version = version + (major * 1e5) end
  if patch then version = version + patch end
  return version
end


---@param mod_name string
---@return integer? # version
version_util.get_mod_version = nil

if script and script.active_mods then
  -- For control stage
  function version_util.get_mod_version(mod_name)
    return version_util.string_to_version(scripts.active_mods[mod_name])
  end
else
  -- For data/settings stage
  function version_util.get_mod_version(mod_name)
    return version_util.string_to_version(mods[mod_name])
  end
end


return version_util
