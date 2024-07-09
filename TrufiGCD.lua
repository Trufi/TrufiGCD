-- TrufiGCD stevemyz@gmail.com

-- The module initializes settings and provides all necessary user events to the modules.

---@type string, Namespace
local _, ns = ...

---@param unitA UnitType
---@param unitB UnitType
---@return boolean
local function areUnitsEqual(unitA, unitB)
    local nameA = UnitName(unitA)
    return nameA and nameA == UnitName(unitB) and UnitHealth(unitA) == UnitHealth(unitB)
end

---@param unitType UnitType
local function checkIfUnitAlreadyInUse(unitType)
    for _, existedUnitType in ipairs(ns.constants.unitTypes) do
        if areUnitsEqual(unitType, existedUnitType) then
            ns.units[unitType]:Copy(ns.units[existedUnitType])
            return
        end
    end
end

local loadFrame = CreateFrame("Frame", nil, UIParent)
loadFrame:RegisterEvent("ADDON_LOADED")
loadFrame:SetScript("OnEvent", function(_, event, name)
    if name ~= "TrufiGCD" or event ~= "ADDON_LOADED" then
        return
    end

    ns.settings:Load()
    ns.settingsFrame.syncWithSettings()
    ns.blocklistFrame.syncWithSettings()
    ns.profileFrame.syncWithSettings()

    ns.locationCheck.settingsChanged()

    local targetFocusChangeFrame = CreateFrame("Frame", nil, UIParent)
    targetFocusChangeFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
    targetFocusChangeFrame:RegisterEvent('PLAYER_FOCUS_CHANGED')
    targetFocusChangeFrame:SetScript("OnEvent", function(_, changeEvent)
        if changeEvent == "PLAYER_TARGET_CHANGED" then
            ns.units.target:Clear()
            if ns.settings.activeProfile.unitSettings.target.enable then
                checkIfUnitAlreadyInUse("target")
            end
        elseif changeEvent == "PLAYER_FOCUS_CHANGED" then
            ns.units.focus:Clear()
            if ns.settings.activeProfile.unitSettings.focus.enable then
                checkIfUnitAlreadyInUse("focus")
            end
        end
    end)

    local eventFrame = CreateFrame("Frame", nil, UIParent)
    eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    eventFrame:RegisterEvent("UNIT_AURA")

    eventFrame:SetScript("OnEvent", function(_, unitEvent, unitType, _, spellId)
        if ns.units[unitType] and ns.locationCheck.isAddonEnabled() then
            ns.units[unitType]:OnEvent(unitEvent, spellId, unitType)
        end
    end)

    local minUpdateInterval = 0.03
    local lastUpdateTime = GetTime()

    eventFrame:SetScript("OnUpdate", function()
        local time = GetTime()
        local interval = time - lastUpdateTime
        if interval > minUpdateInterval then
            for _, unit in pairs(ns.units) do
                unit:Update(time, interval)
            end
            lastUpdateTime = time
        end
    end)
end)
