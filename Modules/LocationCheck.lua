---@type string, Namespace
local _, ns = ...

---@class LocationCheck
local locationCheck = {}
ns.locationCheck = locationCheck

local eventFrame = CreateFrame("Frame", nil, UIParent)
eventFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
eventFrame:RegisterEvent('PLAYER_FOCUS_CHANGED')

-- 1 - world
-- 2 - party
-- 3 - arena
-- 4 - pvp
-- 5 - raid
local playerLocation = 0

local addonEnabled = true

locationCheck.isAddonEnabled = function()
    return addonEnabled
end

---@param event string
local function onEvent(_, event)
    local _, instanceType = IsInInstance()
    local enabledIn = ns.settings.enabledIn

    if event == "PLAYER_REGEN_DISABLED" and enabledIn.combatOnly then -- Entering combat, specific for each zone
        if instanceType == "arena" then
            playerLocation = 3
            addonEnabled = enabledIn.arena
        elseif instanceType == "pvp" then
            playerLocation = 4
            addonEnabled = enabledIn.battleground
        elseif instanceType == "party" then
            playerLocation = 2
            addonEnabled = enabledIn.party
        elseif instanceType == "raid" then
            playerLocation = 5
            addonEnabled = enabledIn.raid
        elseif instanceType ~= "arena" or instanceType ~= "pvp" then
            playerLocation = 1
            addonEnabled = enabledIn.world
        end
    elseif event == "PLAYER_REGEN_ENABLED" and enabledIn.combatOnly then -- Ending combat
        addonEnabled = false
    elseif event == "PLAYER_ENTERING_BATTLEGROUND" and not enabledIn.combatOnly then -- if not Combat only, try to load at locations
        if instanceType == "arena" then
            playerLocation = 3
            addonEnabled = enabledIn.arena
        elseif instanceType == "pvp" then
            playerLocation = 4
            addonEnabled = enabledIn.battleground
        end
    elseif event == "PLAYER_ENTERING_WORLD" and not enabledIn.combatOnly then -- if not Combat only, try to load at locations
        if instanceType == "party" then
            playerLocation = 2
            addonEnabled = enabledIn.party
        elseif instanceType == "raid" then
            playerLocation = 5
            addonEnabled = enabledIn.raid
        elseif instanceType ~= "arena" or instanceType ~= "pvp" then
            playerLocation = 1
            addonEnabled = enabledIn.world
        end
    elseif event == "PLAYER_ENTERING_BATTLEGROUND" and enabledIn.combatOnly then -- if Combat only and just loaded in location
        if instanceType == "arena" then
            playerLocation = 3
            if enabledIn.arena then addonEnabled = false end
        elseif instanceType == "pvp" then
            playerLocation = 4
            if enabledIn.battleground then addonEnabled = false end
        end
    elseif event == "PLAYER_ENTERING_WORLD" and enabledIn.combatOnly then -- if Combat only and just loaded in location
        if instanceType == "party" then
            playerLocation = 2
            if enabledIn.party then addonEnabled = false end
        elseif instanceType == "raid" then
            playerLocation = 5
            if enabledIn.raid then addonEnabled = false end
        elseif instanceType ~= "arena" or instanceType ~= "pvp" then
            playerLocation = 1
            if enabledIn.world then addonEnabled = false end
        end
    end
end

eventFrame:SetScript("OnEvent", onEvent)

locationCheck.settingsChanged = function()
    if not ns.settings.enabledIn.enabled or ns.settings.enabledIn.combatOnly then
        addonEnabled = false
    elseif playerLocation == 1 then
        addonEnabled = ns.settings.enabledIn.world
    elseif playerLocation == 2 then
        addonEnabled = ns.settings.enabledIn.party
    elseif playerLocation == 3 then
        addonEnabled = ns.settings.enabledIn.arena
    elseif playerLocation == 4 then
        addonEnabled = ns.settings.enabledIn.battleground
    elseif playerLocation == 5 then
        addonEnabled = ns.settings.enabledIn.raid
    end

    if not addonEnabled then
        for _, unit in ipairs(ns.units) do
            unit:Clear()
        end
    end
end
