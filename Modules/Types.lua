---@class Namespace
---@field frameUtils FrameUtils
---@field UnitSettings UnitSettings
---@field utils Utils
---@field Icon Icon
---@field IconQueue IconQueue
---@field profileFrame ProfileFrame
---@field ProfileSettings ProfileSettings
---@field settings Settings
---@field innerBlockList {[string]: boolean}
---@field innerIconsBlocklist {[string]: boolean}
---@field settingsFrame SettingsFrame
---@field blocklistFrame BlocklistFrame
---@field units {[UnitType]: Unit}
---@field masqueHelper MasqueHelper
---@field locationCheck LocationCheck
---@field constants Constants

---@alias Direction "Left" | "Right" | "Up" | "Down"

---@alias Point "TOPLEFT"| "TOPRIGHT"| "BOTTOMLEFT"| "BOTTOMRIGHT"| "TOP"| "BOTTOM"| "LEFT"| "RIGHT"| "CENTER"

---@alias UnitType "player" | "party1" | "party2" | "party3" | "party4" | "arena1" | "arena2" | "arena3" | "arena4" | "arena5" | "target" | "focus"

---@class SavedVariablesUnitSettings
---@field x? number
---@field y? number
---@field point? Point
---@field enable? boolean
---@field fade? Direction
---@field size? number
---@field width? number

---@class SavedVariablesEnabledIn
---@field Enable? boolean
---@field PvE? boolean
---@field Arena? boolean
---@field Bg? boolean
---@field World? boolean
---@field Raid? boolean
---@field ["Combat only"]? boolean

---@class SavedVariablesV0
---@field EnableIn? SavedVariablesEnabledIn
---@field ModScroll? boolean
---@field TooltipEnable? boolean
---@field TooltipSpellID? boolean
---@field TooltipStopMove? boolean
---@field iconClickAddsSpellToBlocklist? boolean
---@field TrGCDQueueFr? SavedVariablesUnitSettings
---@field TrGCDBL? number[]

--TODO: Remove V0 types after 01.12.2024
---@class GlobalSavedVariablesV0: SavedVariablesV0
---@class CharacterSavedVariablesV0: SavedVariablesV0

---@class SavedVariablesV1: SavedVariablesV0
---@field id? string
---@field name? string

---@class ProfileVariablesV1: SavedVariablesV1

---@class GlobalSavedVariablesV1
---@field version 1
---@field profiles? { [string]: ProfileVariablesV1 }
---@field lastUsedProfileId? string

---@class CharacterSavedVariablesV1
---@field version 1
---@field profileId? string
