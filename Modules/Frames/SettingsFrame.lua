---@type string, Namespace
local _, ns = ...

---@class SettingsFrame
local settingsFrame = {}
ns.settingsFrame = settingsFrame

local frame = CreateFrame("Frame", nil, UIParent)
frame:Hide()
frame.name = "TrufiGCD"
ns.utils.interfaceOptions_AddCategory(frame)
settingsFrame.frame = frame

SLASH_TRUFI1, SLASH_TRUFI2 = '/tgcd', '/trufigcd'
function SlashCmdList.TRUFI()
    Settings.OpenToCategory(frame.name)
end

---show/hide anchors button, text and frame
local showHideAnchorsButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
showHideAnchorsButton:SetWidth(100)
showHideAnchorsButton:SetHeight(22)
showHideAnchorsButton:SetPoint('TOPLEFT', 10, -30)
showHideAnchorsButton:SetText('Show')
ns.frameUtils.addTooltip(showHideAnchorsButton, "Show/Hide anchors", "Show or hide icon frame anchors to change their position")

local showHideAnchorsButtonLabel = showHideAnchorsButton:CreateFontString(nil, 'BACKGROUND')
showHideAnchorsButtonLabel:SetFont(STANDARD_TEXT_FONT, 10)
showHideAnchorsButtonLabel:SetText('Show/Hide anchors')
showHideAnchorsButtonLabel:SetPoint('TOP', 0, 10)

---frame after push show/hide button
local frameShowAnchors = CreateFrame('Frame', nil, UIParent)
frameShowAnchors:SetWidth(160)
frameShowAnchors:SetHeight(50)
frameShowAnchors:SetPoint('TOP', 0, -150)
frameShowAnchors:Hide()
frameShowAnchors:RegisterForDrag('LeftButton')
frameShowAnchors:SetScript('OnDragStart', frameShowAnchors.StartMoving)
frameShowAnchors:SetScript('OnDragStop', frameShowAnchors.StopMovingOrSizing)
frameShowAnchors:SetMovable(true)
frameShowAnchors:EnableMouse(true)

local frameShowAnchorsTexture = frameShowAnchors:CreateTexture(nil, 'BACKGROUND')
frameShowAnchorsTexture:SetAllPoints(frameShowAnchors)
frameShowAnchorsTexture:SetColorTexture(0, 0, 0)
frameShowAnchorsTexture:SetAlpha(0.5)

local frameShowAnchorsReturnButton = CreateFrame("Button", nil, frameShowAnchors, "UIPanelButtonTemplate")
frameShowAnchorsReturnButton:SetWidth(73)
frameShowAnchorsReturnButton:SetHeight(22)
frameShowAnchorsReturnButton:SetPoint("TOP", -37, -22)
frameShowAnchorsReturnButton:SetText("Settings")

local frameShowAnchorsHideButton = CreateFrame("Button", nil, frameShowAnchors, "UIPanelButtonTemplate")
frameShowAnchorsHideButton:SetWidth(73)
frameShowAnchorsHideButton:SetHeight(22)
frameShowAnchorsHideButton:SetPoint("TOP", 37, -22)
frameShowAnchorsHideButton:SetText("Hide")

local frameShowAnchorsButtonText = frameShowAnchors:CreateFontString(nil, "BACKGROUND")
frameShowAnchorsButtonText:SetFont(STANDARD_TEXT_FONT, 12)
frameShowAnchorsButtonText:SetText('TrufiGCD')
frameShowAnchorsButtonText:SetPoint("TOP", 0, -8)

frameShowAnchorsReturnButton:SetScript("OnClick", function()
    Settings.OpenToCategory(frame.name)
end)

local anchorDisplayed = false

settingsFrame.toggleAnchors = function()
    if anchorDisplayed then
        showHideAnchorsButton:SetText("Show")
        frameShowAnchors:Hide()
        for unitType, queueSettings in pairs(ns.settings.activeProfile.unitSettings) do
            if queueSettings.enable then
                local iconQueue = ns.units[unitType].iconQueue
                iconQueue:HideAnchor()

                queueSettings.point, _, _, queueSettings.x, queueSettings.y = iconQueue.frame:GetPoint()
                ns.settings:Save()
            end
        end
    else
        showHideAnchorsButton:SetText("Hide")
        frameShowAnchors:Show()
        for unitType, unitSettings in pairs(ns.settings.activeProfile.unitSettings) do
            if unitSettings.enable then
                ns.units[unitType].iconQueue:ShowAnchor()
            end
        end
    end
    anchorDisplayed = not anchorDisplayed
end

frameShowAnchorsHideButton:SetScript("OnClick", function() settingsFrame.toggleAnchors() end)
showHideAnchorsButton:SetScript("OnClick", function() settingsFrame.toggleAnchors() end)

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

--labels for checkboxes and sliders
local labelEnable = frame:CreateFontString(nil, "BACKGROUND")
labelEnable:SetFont(STANDARD_TEXT_FONT, 12)
labelEnable:SetText("Enable")
labelEnable:SetPoint("TOPLEFT", 20, -65)

local labelFade = frame:CreateFontString(nil, "BACKGROUND")
labelFade:SetFont(STANDARD_TEXT_FONT, 12)
labelFade:SetText("Fade")
labelFade:SetPoint("TOPLEFT", 105, -65)

local labelSize = frame:CreateFontString(nil, "BACKGROUND")
labelSize:SetFont(STANDARD_TEXT_FONT, 12)
labelSize:SetText("Icons size")
labelSize:SetPoint("TOPLEFT", 245, -65)

local labelNumber = frame:CreateFontString(nil, "BACKGROUND")
labelNumber:SetFont(STANDARD_TEXT_FONT, 12)
labelNumber:SetText("Icons number")
labelNumber:SetPoint("TOPLEFT", 390, -65)

---@class UnitSettingsFrame
local UnitSettingsFrame = {}
UnitSettingsFrame.__index = UnitSettingsFrame

---@param unitType UnitType
---@param offset number
function UnitSettingsFrame:New(unitType, offset)
    ---@class UnitSettingsFrame
    local obj = setmetatable({}, UnitSettingsFrame)
    obj.unitType = unitType

    obj.buttonEnable = ns.frameUtils.createCheckButton({
        frame = frame,
        text = ns.settings.activeProfile.unitSettings[unitType].text,
        position = "TOPLEFT",
        x = 10,
        y = -50 - offset * 40,
        name = "trgcdcheckenable" .. unitType,
        checked = ns.settings.activeProfile.unitSettings[unitType].enable,
        onClick = function()
            ns.settings.activeProfile.unitSettings[unitType].enable = not ns.settings.activeProfile.unitSettings[unitType].enable

            local iconQueue = ns.units[unitType].iconQueue
            if ns.settings.activeProfile.unitSettings[unitType].enable then
                iconQueue:ShowAnchor()
            else
                iconQueue:HideAnchor()
            end

            ns.settings:Save()
            ns.units[unitType]:Clear()
        end
    })

    ---dropdown menu
    obj.directionDropdown = CreateFrame("Frame", "trgcdframemenu" .. unitType, frame, "UIDropDownMenuTemplate")
    obj.directionDropdown:SetPoint("TOPLEFT", 70, -50 - offset * 40)
    UIDropDownMenu_SetWidth(obj.directionDropdown, 55)
    UIDropDownMenu_SetText(obj.directionDropdown, ns.settings.activeProfile.unitSettings[unitType].direction)

    ---@param direction Direction
    local function onMenuItemClick(direction)
        UIDropDownMenu_SetText(obj.directionDropdown, direction)
        ns.settings.activeProfile.unitSettings[unitType].direction = direction
        ns.settings:Save()

        ns.units[unitType].iconQueue:Resize()
        ns.units[unitType]:Clear()
    end

    UIDropDownMenu_Initialize(obj.directionDropdown, function()
        local left = UIDropDownMenu_CreateInfo()
        left.text = "Left"
        left.menuList = 1
        left.notCheckable = true
        left.func = function() onMenuItemClick("Left") end
        UIDropDownMenu_AddButton(left)

        local right = UIDropDownMenu_CreateInfo()
        right.text = "Right"
        right.menuList = 2
        right.notCheckable = true
        right.func = function() onMenuItemClick("Right") end
        UIDropDownMenu_AddButton(right)

        local up = UIDropDownMenu_CreateInfo()
        up.text = "Up"
        up.menuList = 3
        up.notCheckable = true
        up.func = function() onMenuItemClick("Up") end
        UIDropDownMenu_AddButton(up)

        local down = UIDropDownMenu_CreateInfo()
        down.text = "Down"
        down.menuList = 4
        down.notCheckable = true
        down.func = function() onMenuItemClick("Down") end
        UIDropDownMenu_AddButton(down)
    end)

    ---Size Slider
    obj.sizeSlider = CreateFrame("Slider", "trgcdframesizeslider" .. unitType, frame, "TrufiGCD_OptionsSliderTemplate")
    obj.sizeSlider:SetWidth(170)
    obj.sizeSlider:SetPoint("TOPLEFT", 190, -55 - offset * 40)
    _G[obj.sizeSlider:GetName() .. 'Low']:SetText('10')
    _G[obj.sizeSlider:GetName() .. 'High']:SetText('100')
    _G[obj.sizeSlider:GetName() .. 'Text']:SetText(ns.settings.activeProfile.unitSettings[unitType].iconSize)
    obj.sizeSlider:SetMinMaxValues(10,100)
    obj.sizeSlider:SetValueStep(1)
    obj.sizeSlider:SetValue(ns.settings.activeProfile.unitSettings[unitType].iconSize)
    obj.sizeSlider:SetScript("OnValueChanged", function(_, value)
        value = math.ceil(value)
        _G[obj.sizeSlider:GetName() .. 'Text']:SetText(value)
        ns.settings.activeProfile.unitSettings[unitType].iconSize = value
        ns.settings:Save()

        ns.units[unitType].iconQueue:Resize()
        ns.units[unitType]:Clear()
    end)
    obj.sizeSlider:Show()

    ---Icons number slider
    obj.iconsNumber = CreateFrame("Slider", "trgcdframewidthslider" .. unitType, frame, "TrufiGCD_OptionsSliderTemplate")
    obj.iconsNumber:SetWidth(100)
    obj.iconsNumber:SetPoint("TOPLEFT", 390, -55 - offset * 40)
    _G[obj.iconsNumber:GetName() .. 'Low']:SetText('1')
    _G[obj.iconsNumber:GetName() .. 'High']:SetText('8')
    _G[obj.iconsNumber:GetName() .. 'Text']:SetText(ns.settings.activeProfile.unitSettings[unitType].iconsNumber)
    obj.iconsNumber:SetMinMaxValues(1,8)
    obj.iconsNumber:SetValueStep(1)
    obj.iconsNumber:SetValue(ns.settings.activeProfile.unitSettings[unitType].iconsNumber)
    obj.iconsNumber:SetScript("OnValueChanged", function (_, value)
        value = math.ceil(value)
        _G[obj.iconsNumber:GetName() .. 'Text']:SetText(value)
        ns.settings.activeProfile.unitSettings[unitType].iconsNumber = value
        ns.settings:Save()

        ns.units[unitType].iconQueue:Resize()
        ns.units[unitType]:Clear()
    end)
    obj.iconsNumber:Show()

    return obj
end

function UnitSettingsFrame:SyncWithSettings()
    local queueSettings = ns.settings.activeProfile.unitSettings[self.unitType]

    self.buttonEnable:SetChecked(queueSettings.enable)
    UIDropDownMenu_SetText(self.directionDropdown, queueSettings.direction)

    _G[self.sizeSlider:GetName() .. 'Text']:SetText(queueSettings.iconSize)
    self.sizeSlider:SetValue(queueSettings.iconSize)

    _G[self.iconsNumber:GetName() .. 'Text']:SetText(queueSettings.iconsNumber)
    self.iconsNumber:SetValue(queueSettings.iconsNumber)

    local iconQueue = ns.units[self.unitType].iconQueue
    iconQueue:Resize()
    iconQueue:UpdateOffset()
end

---@type {[UnitType]: UnitSettingsFrame}
local unitSettingsFrames = {}
for i, unitType in ipairs(ns.constants.unitTypes) do
    unitSettingsFrames[unitType] = UnitSettingsFrame:New(unitType, i)
end

settingsFrame.syncWithSettings = function()
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

    for _, unitSettings in pairs(unitSettingsFrames) do
        unitSettings:SyncWithSettings()
    end
end
