-- Forced Fading Nametags server plugin (BeamMP Server 3.x)
-- The server distributes policy only. The client companion applies it to
-- BeamMP's local native nametag renderer.

local EVENT_CONFIG = "FFN_Config"
local CONFIG_PATH = "Resources/Server/ForcedFadingNametags/config.json"
local DEFAULTS = {
  enabled = true,
  mandatory = true,
  fullOpacityDistance = 20,
  fadeStartDistance = 30,
  maximumVisibilityDistance = 100,
  maximumOpacity = 1.0,
  minimumOpacity = 0.0,
  fadeSmoothness = "linear",
  updateFrequencyHz = 30
}

local currentConfig = nil

local function clampNumber(value, fallback, minimum, maximum)
  value = tonumber(value)
  if value == nil then value = fallback end
  if value < minimum then value = minimum end
  if value > maximum then value = maximum end
  return value
end

local function sanitize(raw)
  if type(raw) ~= "table" then raw = {} end
  local result = {
    version = 1,
    enabled = raw.enabled == nil and DEFAULTS.enabled or raw.enabled == true,
    mandatory = raw.mandatory == nil and DEFAULTS.mandatory or raw.mandatory == true,
    fullOpacityDistance = clampNumber(raw.fullOpacityDistance, DEFAULTS.fullOpacityDistance, 0, 10000),
    fadeStartDistance = clampNumber(raw.fadeStartDistance, DEFAULTS.fadeStartDistance, 0, 10000),
    maximumVisibilityDistance = clampNumber(raw.maximumVisibilityDistance, DEFAULTS.maximumVisibilityDistance, 1, 10000),
    maximumOpacity = clampNumber(raw.maximumOpacity, DEFAULTS.maximumOpacity, 0, 1),
    minimumOpacity = clampNumber(raw.minimumOpacity, DEFAULTS.minimumOpacity, 0, 1),
    fadeSmoothness = "linear",
    updateFrequencyHz = clampNumber(raw.updateFrequencyHz, DEFAULTS.updateFrequencyHz, 1, 60)
  }

  if result.fadeStartDistance < result.fullOpacityDistance then
    result.fadeStartDistance = result.fullOpacityDistance
  end
  if result.maximumVisibilityDistance < result.fadeStartDistance then
    result.maximumVisibilityDistance = result.fadeStartDistance
  end
  if result.minimumOpacity > result.maximumOpacity then
    result.minimumOpacity = result.maximumOpacity
  end
  return result
end

local function readConfig()
  local file, err = io.open(CONFIG_PATH, "r")
  if not file then
    print("[ForcedFadingNametags] Could not read config; using defaults: " .. tostring(err))
    return sanitize(DEFAULTS)
  end

  local contents = file:read("*a")
  file:close()
  local ok, decoded = pcall(Util.JsonDecode, contents)
  if not ok or type(decoded) ~= "table" then
    print("[ForcedFadingNametags] Invalid JSON in " .. CONFIG_PATH .. "; using defaults")
    return sanitize(DEFAULTS)
  end
  return sanitize(decoded)
end

local function sendConfig(playerID)
  if not currentConfig then currentConfig = readConfig() end
  local ok, err = MP.TriggerClientEventJson(playerID, EVENT_CONFIG, currentConfig)
  if not ok then
    print("[ForcedFadingNametags] Config delivery failed for player " .. tostring(playerID) .. ": " .. tostring(err))
  end
end

local function onPlayerJoin(playerID)
  sendConfig(playerID)
end

local function onPlayerDisconnect(playerID)
  -- There is no per-player state to retain. The client extension stops being
  -- relevant when BeamMP unloads the connected session.
end

local function onConsoleInput(input)
  if input == "ffn reload" then
    currentConfig = readConfig()
    MP.TriggerClientEventJson(-1, EVENT_CONFIG, currentConfig)
    print("[ForcedFadingNametags] Configuration reloaded and broadcast")
    return "Reloaded Forced Fading Nametags configuration"
  end
end

local function onInit()
  currentConfig = readConfig()
  MP.RegisterEvent("onPlayerJoin", "FFN_onPlayerJoin")
  MP.RegisterEvent("onPlayerDisconnect", "FFN_onPlayerDisconnect")
  MP.RegisterEvent("onConsoleInput", "FFN_onConsoleInput")
  print("[ForcedFadingNametags] Loaded. Native BeamMP nametag fading is enabled for participating clients.")
end

function FFN_onPlayerJoin(playerID) onPlayerJoin(playerID) end
function FFN_onPlayerDisconnect(playerID) onPlayerDisconnect(playerID) end
function FFN_onConsoleInput(input) return onConsoleInput(input) end

MP.RegisterEvent("onInit", "FFN_onInit")
function FFN_onInit() onInit() end

