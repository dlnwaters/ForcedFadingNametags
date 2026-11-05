-- Server-authoritative policy adapter for BeamMP's native nametag renderer.
local M = {}
local EVENT_CONFIG = "FFN_Config"
local config = nil
local originalGetValue = nil
local hookedGetValue = false

local function logInfo(message)
  if type(log) == "function" then
    log("I", "ForcedFadingNametags", message)
  end
end

local function applyPolicy()
  if not config or type(settings) ~= "table" or type(settings.getValue) ~= "function" then
    return
  end

  if not hookedGetValue then
    originalGetValue = settings.getValue
    settings.getValue = function(name, defaultValue)
      if config and config.enabled then
        if name == "hideNameTags" then return false end
        if name == "nameTagFadeEnabled" then return true end
        if name == "nameTagFadeInvert" then return false end
        if name == "nameTagDontFullyHide" then return false end
        if name == "nameTagFadeDistance" then return config.maximumVisibilityDistance end
      end
      return originalGetValue(name, defaultValue)
    end
    hookedGetValue = true
  end

  if config.enabled then
    -- Keep the visible settings UI and persisted values aligned when possible.
    -- The getValue policy above remains authoritative if a local menu changes
    -- these while connected.
    settings.setValue("hideNameTags", false)
    settings.setValue("nameTagFadeEnabled", true)
    settings.setValue("nameTagFadeInvert", false)
    settings.setValue("nameTagDontFullyHide", false)
    settings.setValue("nameTagFadeDistance", config.maximumVisibilityDistance)
  end
end

local function receiveConfig(data)
  if type(jsonDecode) ~= "function" then
    logInfo("BeamMP JSON decoder is unavailable; configuration was not applied")
    return
  end
  local ok, decoded = pcall(jsonDecode, data)
  if not ok or type(decoded) ~= "table" or decoded.version ~= 1 then
    logInfo("Received invalid or unsupported server configuration")
    return
  end
  config = decoded
  applyPolicy()

  if config.enabled and (config.fullOpacityDistance > 0 or config.fadeStartDistance > 0) then
    logInfo("Using BeamMP native linear fade to " .. tostring(config.maximumVisibilityDistance) .. " m. This renderer has no full-opacity plateau or separate fade-start control.")
  end
end

function M.onUpdate(dt)
  -- The renderer reads settings every frame. This reapplies persisted values
  -- after BeamMP UI changes; the getter hook keeps the policy authoritative.
  if config and config.enabled then applyPolicy() end
end

function M.onExtensionLoaded()
  if type(AddEventHandler) == "function" then
    AddEventHandler(EVENT_CONFIG, receiveConfig)
    logInfo("Client companion loaded; waiting for server configuration")
  else
    logInfo("BeamMP event handler API is unavailable")
  end
end

function M.onExtensionUnloaded()
  if hookedGetValue and settings and settings.getValue then
    settings.getValue = originalGetValue
  end
  hookedGetValue = false
  originalGetValue = nil
  config = nil
end

return M

