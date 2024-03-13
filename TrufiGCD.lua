-- TrufiGCD stevemyz@gmail.com

---@type string, Namespace
local _, ns = ...

local function unitIdToIndex(unitId)
    if unitId == "player" then return 1
    elseif unitId == "party1" then return 2
    elseif unitId == "party2" then return 3
    elseif unitId == "party3" then return 4
    elseif unitId == "party4" then return 5
    elseif unitId == "arena1" then return 6
    elseif unitId == "arena2" then return 7
    elseif unitId == "arena3" then return 8
    elseif unitId == "arena4" then return 9
    elseif unitId == "arena5" then return 10
    elseif unitId == "target" then return 11
    elseif unitId == "focus" then return 12
    end
    return nil
end

local function areUnitsEqual(unitA, unitB)
    local nameA = UnitName(unitA)
    return nameA and nameA == UnitName(unitB) and UnitHealth(unitA) == UnitHealth(unitB)
end

local function checkIfTargetUnitAlreadyInUse(selectedUnitIndex) -- чек есть ли цель или фокус уже во фреймах (пати или арена)
    local selectedUnit = ""
    local existedUnitIndex = -1

    if selectedUnitIndex == 11 then
        selectedUnit = "target"
    elseif selectedUnitIndex == 12 then
        selectedUnit = "focus"
    else
        return
    end

    if areUnitsEqual(selectedUnit, "player") then existedUnitIndex = 1
    elseif areUnitsEqual(selectedUnit, "party1") then existedUnitIndex = 2
    elseif areUnitsEqual(selectedUnit, "party2") then existedUnitIndex = 3
    elseif areUnitsEqual(selectedUnit, "party3") then existedUnitIndex = 4
    elseif areUnitsEqual(selectedUnit, "party4") then existedUnitIndex = 5
    elseif areUnitsEqual(selectedUnit, "arena1") then existedUnitIndex = 6
    elseif areUnitsEqual(selectedUnit, "arena2") then existedUnitIndex = 7
    elseif areUnitsEqual(selectedUnit, "arena3") then existedUnitIndex = 8
    elseif areUnitsEqual(selectedUnit, "arena4") then existedUnitIndex = 9
    elseif areUnitsEqual(selectedUnit, "arena5") then existedUnitIndex = 10
    elseif selectedUnit ~= "target" and areUnitsEqual(selectedUnit, "target") then existedUnitIndex = 11
    elseif selectedUnit ~= "focus" and areUnitsEqual(selectedUnit, "focus") then existedUnitIndex = 12
    end

    if existedUnitIndex ~= -1 then
        ns.units[selectedUnitIndex]:Copy(ns.units[existedUnitIndex])
    end
end

local minUpdateInterval = 0.03

local loadFrame = CreateFrame("Frame", nil, UIParent)
loadFrame:RegisterEvent("ADDON_LOADED")
loadFrame:SetScript("OnEvent", function(_, event, name)
    if name ~= "TrufiGCD" or event ~= "ADDON_LOADED" then
        return
    end

    ns.settings:LoadFromCharacterSavedVariables()
    ns.settingsFrame.syncWithSettings()

    ns.settings:LoadBlocklistFromCharacterSavedVariables()
    ns.blocklistFrame:syncWithSettings()

    ns.locationCheck.settingsChanged()

    local targetFocusChangeFrame = CreateFrame("Frame", nil, UIParent)
    targetFocusChangeFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
    targetFocusChangeFrame:RegisterEvent('PLAYER_FOCUS_CHANGED')
    targetFocusChangeFrame:SetScript("OnEvent", function(_, changeEvent)
        if changeEvent == "PLAYER_TARGET_CHANGED" then
            ns.units[11]:Clear()
            if ns.settings.unitSettings[11].enable then
                checkIfTargetUnitAlreadyInUse(11)
            end
        elseif changeEvent == "PLAYER_FOCUS_CHANGED" then
            ns.units[12]:Clear()
            if ns.settings.unitSettings[12].enable then
                checkIfTargetUnitAlreadyInUse(12)
            end
        end
    end)

    local eventFrame = CreateFrame("Frame", nil, UIParent)
    eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    eventFrame:RegisterEvent("UNIT_AURA")

    eventFrame:SetScript("OnEvent", function(_, unitEvent, unitId, _, spellId)
        local unitIndex = unitIdToIndex(unitId)
        if unitIndex and ns.locationCheck.isAddonEnabled() then
            ns.units[unitIndex]:OnEvent(unitEvent, spellId, unitId)
        end
    end)

    local lastUpdateTime = GetTime()

    eventFrame:SetScript("OnUpdate", function()
        local time = GetTime()
        local interval = time - lastUpdateTime
        if interval > minUpdateInterval then
            for unitIndex = 1, 12 do
                ns.units[unitIndex]:Update(time, interval)
            end
            lastUpdateTime = time
        end
    end)
end)
