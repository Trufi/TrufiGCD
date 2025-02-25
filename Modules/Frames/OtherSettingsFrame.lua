---@type string, Namespace
local _, ns = ...

---@class OtherSettingsFrame
local otherSettingsFrame = {}
ns.otherSettingsFrame = otherSettingsFrame

local frame = CreateFrame("Frame", nil, UIParent)
frame:Hide()
frame.name = "Other"
frame.parent = "TrufiGCD"
ns.utils.interfaceOptions_AddCategory(frame)
otherSettingsFrame.frame = frame

---tooltip settings
local tooltipText = frame:CreateFontString(nil, "BACKGROUND")
tooltipText:SetFont(STANDARD_TEXT_FONT, 12)
tooltipText:SetText("Tooltip:")
tooltipText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -70, -360)

---enable tooltip checkbox
local tooltipEnableCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Enable",
    position = "TOPRIGHT",
    x = -90,
    y = -380,
    name = "TrGCDCheckTooltip",
    checked = ns.settings.activeProfile.tooltipEnabled,
    tooltip = "Show tooltip when hovering an icon",
    onClick = function()
        ns.settings.activeProfile.tooltipEnabled = not ns.settings.activeProfile.tooltipEnabled
        ns.settings:Save()
    end
})

---Stop moving with displayed tooltip checkbox
local stopMovingCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Stop icons",
    position = "TOPRIGHT",
    x = -90,
    y = -410,
    name = "TrGCDCheckTooltipMove",
    checked = ns.settings.activeProfile.tooltipStopScroll,
    tooltip = "Stop moving icons when hovering an icon",
    onClick = function()
        ns.settings.activeProfile.tooltipStopScroll = not ns.settings.activeProfile.tooltipStopScroll
        ns.settings:Save()
    end
})

---Print spell ID to the chat checkbox
local spellIdCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Spell ID",
    position = "TOPRIGHT",
    x = -90,
    y = -440,
    name = "TrGCDCheckTooltipSpellID",
    checked = ns.settings.activeProfile.tooltipPrintSpellId,
    tooltip = "Print spell ID to the chat when hovering an icon",
    onClick = function()
        ns.settings.activeProfile.tooltipPrintSpellId = not ns.settings.activeProfile.tooltipPrintSpellId
        ns.settings:Save()
    end
})

---Scrolling icons checkbox
local scrollingCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Scrolling icons",
    position = "TOPRIGHT",
    x = -90,
    y = -80,
    name = "TrGCDCheckModScroll",
    checked = ns.settings.activeProfile.iconsScroll,
    tooltip = "Icons will be disappearing without moving",
    onClick = function()
        ns.settings.activeProfile.iconsScroll = not ns.settings.activeProfile.iconsScroll
        ns.settings:Save()
    end
})

--EnableIn checkboxes: Enable, World, PvE, Arena, Bg
local enableInText = frame:CreateFontString(nil, "BACKGROUND")
enableInText:SetFont(STANDARD_TEXT_FONT, 12)
enableInText:SetText("Enable in:")
enableInText:SetPoint("TOPRIGHT", -53, -175)

local combatOnlyCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Combat only",
    position = "TOPRIGHT",
    x = -90,
    y = -110,
    name = "trgcdcheckenablein6",
    checked = ns.settings.activeProfile.enabledIn.combatOnly,
    onClick = function()
        ns.settings.activeProfile.enabledIn.combatOnly = not ns.settings.activeProfile.enabledIn.combatOnly
        ns.settings:Save()
        ns.locationCheck.settingsChanged()
    end
})

local enableCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Enable addon",
    position = "TOPRIGHT",
    x = -90,
    y = -140,
    name = "trgcdcheckenablein0",
    checked = ns.settings.activeProfile.enabledIn.enabled,
    onClick = function()
        ns.settings.activeProfile.enabledIn.enabled = not ns.settings.activeProfile.enabledIn.enabled
        ns.settings:Save()
        ns.locationCheck.settingsChanged()
    end
})

local worldCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "World",
    position = "TOPRIGHT",
    x = -90,
    y = -200,
    name = "trgcdcheckenablein1",
    checked = ns.settings.activeProfile.enabledIn.world,
    onClick = function()
        ns.settings.activeProfile.enabledIn.world = not ns.settings.activeProfile.enabledIn.world
        ns.settings:Save()
        ns.locationCheck.settingsChanged()
    end
})

local partyCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Party",
    position = "TOPRIGHT",
    x = -90,
    y = -230,
    name = "trgcdcheckenablein2",
    checked = ns.settings.activeProfile.enabledIn.party,
    onClick = function()
        ns.settings.activeProfile.enabledIn.party = not ns.settings.activeProfile.enabledIn.party
        ns.settings:Save()
        ns.locationCheck.settingsChanged()
    end
})

local raidCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Raid",
    position = "TOPRIGHT",
    x = -90,
    y = -260,
    name = "trgcdcheckenablein5",
    checked = ns.settings.activeProfile.enabledIn.raid,
    onClick = function()
        ns.settings.activeProfile.enabledIn.raid = not ns.settings.activeProfile.enabledIn.raid
        ns.settings:Save()
        ns.locationCheck.settingsChanged()
    end
})

local arenaCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Arena",
    position = "TOPRIGHT",
    x = -90,
    y = -290,
    name = "trgcdcheckenablein3",
    checked = ns.settings.activeProfile.enabledIn.arena,
    onClick = function()
        ns.settings.activeProfile.enabledIn.arena = not ns.settings.activeProfile.enabledIn.arena
        ns.settings:Save()
        ns.locationCheck.settingsChanged()
    end
})

local battlegroundCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Battleground",
    position = "TOPRIGHT",
    x = -90,
    y = -320,
    name = "trgcdcheckenablein4",
    checked = ns.settings.activeProfile.enabledIn.battleground,
    onClick = function()
        ns.settings.activeProfile.enabledIn.battleground = not ns.settings.activeProfile.enabledIn.battleground
        ns.settings:Save()
        ns.locationCheck.settingsChanged()
    end
})

otherSettingsFrame.syncWithSettings = function()
    local settings = ns.settings.activeProfile

    tooltipEnableCheckbox:SetChecked(settings.tooltipEnabled)
    stopMovingCheckbox:SetChecked(settings.tooltipStopScroll)
    spellIdCheckbox:SetChecked(settings.tooltipPrintSpellId)
    scrollingCheckbox:SetChecked(settings.iconsScroll)

    combatOnlyCheckbox:SetChecked(settings.enabledIn.combatOnly)
    enableCheckbox:SetChecked(settings.enabledIn.enabled)
    worldCheckbox:SetChecked(settings.enabledIn.world)
    partyCheckbox:SetChecked(settings.enabledIn.party)
    raidCheckbox:SetChecked(settings.enabledIn.raid)
    arenaCheckbox:SetChecked(settings.enabledIn.arena)
    battlegroundCheckbox:SetChecked(settings.enabledIn.battleground)
end
