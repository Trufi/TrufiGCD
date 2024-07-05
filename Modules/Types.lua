---@class Namespace
---@field frameUtils FrameUtils
---@field UnitSettings UnitSettings
---@field Icon Icon
---@field IconQueue IconQueue
---@field settings Settings
---@field innerBlockList number[]
---@field settingsFrame SettingsFrame
---@field blocklistFrame BlocklistFrame
---@field units {[UnitType]: Unit}
---@field masqueHelper MasqueHelper
---@field locationCheck LocationCheck
---@field constants Constants

---@alias Direction "Left" | "Right" | "Up" | "Down"

---@alias Point "TOPLEFT"| "TOPRIGHT"| "BOTTOMLEFT"| "BOTTOMRIGHT"| "TOP"| "BOTTOM"| "LEFT"| "RIGHT"| "CENTER"

---@alias UnitType "player" | "party1" | "party2" | "party3" | "party4" | "arena1" | "arena2" | "arena3" | "arena4" | "arena5" | "target" | "focus"
