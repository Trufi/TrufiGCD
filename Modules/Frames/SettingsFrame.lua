---@type string, Namespace
local _, ns = ...

---@class SettingsFrame
local settingsFrame = {}
ns.settingsFrame = settingsFrame

local frame = CreateFrame("Frame", nil, UIParent)
frame:Hide()
frame.name = "TrufiGCD"
InterfaceOptions_AddCategory(frame)

SLASH_TRUFI1, SLASH_TRUFI2 = '/tgcd', '/trufigcd'
function SlashCmdList.TRUFI()
    InterfaceOptionsFrame_OpenToCategory(frame)
end

---show/hide anchors button, text and frame
local showHideAnchorsButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
showHideAnchorsButton:SetWidth(100)
showHideAnchorsButton:SetHeight(22)
showHideAnchorsButton:SetPoint('TOPLEFT', 10, -30)
showHideAnchorsButton:SetText('Show')

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

local frameShowAnchorsButton = CreateFrame('Button', nil, frameShowAnchors, 'UIPanelButtonTemplate')
frameShowAnchorsButton:SetWidth(150)
frameShowAnchorsButton:SetHeight(22)
frameShowAnchorsButton:SetPoint('BOTTOM', 0, 5)
frameShowAnchorsButton:SetText('Return to options')

local frameShowAnchorsButtonText = frameShowAnchorsButton:CreateFontString(nil, 'BACKGROUND')
frameShowAnchorsButtonText:SetFont(STANDARD_TEXT_FONT, 12)
frameShowAnchorsButtonText:SetText('TrufiGCD')
frameShowAnchorsButtonText:SetPoint('TOP', 0, 15)

frameShowAnchorsButton:SetScript('OnClick', function()
    InterfaceOptionsFrame_OpenToCategory(frame)
end)

local anchorDisplayed = false

showHideAnchorsButton:SetScript("OnClick", function()
    if anchorDisplayed then
        showHideAnchorsButton:SetText("Show")
        frameShowAnchors:Hide()
        for unitType, queueSettings in pairs(ns.settings.unitSettings) do
            if queueSettings.enable then
                local iconQueue = ns.units[unitType].iconQueue
                iconQueue:HideAnchor()

                queueSettings.point, _, _, queueSettings.x, queueSettings.y = iconQueue.frame:GetPoint()
                ns.settings:SaveToCharacterSavedVariables()
            end
        end
    else
        showHideAnchorsButton:SetText("Hide")
        frameShowAnchors:Show()
        for unitType, unitSettings in pairs(ns.settings.unitSettings) do
            if unitSettings.enable then
                ns.units[unitType].iconQueue:ShowAnchor()
            end
        end
    end

    anchorDisplayed = not anchorDisplayed
end)

---button to load saved to cached settings
local buttonLoad = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
buttonLoad:SetWidth(100)
buttonLoad:SetHeight(22)
buttonLoad:SetPoint("TOPRIGHT", -145, -30)
buttonLoad:SetText("Load")
buttonLoad:SetScript("OnClick", function()
    ns.settings:LoadFromGlobalSavedVariables()
    ns.settings:SaveToCharacterSavedVariables()
    settingsFrame.syncWithSettings()
end)

local buttonLoadText = buttonLoad:CreateFontString(nil, "BACKGROUND")
buttonLoadText:SetFont(STANDARD_TEXT_FONT, 10)
buttonLoadText:SetText("Load cached settings")
buttonLoadText:SetPoint("TOP", 0, 10)

---button to save current settings to the cache
local buttonSave = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
buttonSave:SetWidth(100)
buttonSave:SetHeight(22)
buttonSave:SetPoint("TOPRIGHT", -260, -30)
buttonSave:SetText("Save")
buttonSave:SetScript("OnClick", function()
    ns.settings:SaveToGlobalSavedVariables()
end)

local buttonSaveText = buttonSave:CreateFontString(nil, "BACKGROUND")
buttonSaveText:SetFont(STANDARD_TEXT_FONT, 10)
buttonSaveText:SetText("Save settings to cache")
buttonSaveText:SetPoint("TOP", 0, 10)

---button to restore default settings
local buttonRestore = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
buttonRestore:SetWidth(100)
buttonRestore:SetHeight(22)
buttonRestore:SetPoint("TOPRIGHT", -30, -30)
buttonRestore:SetText("Default")
buttonRestore:SetScript("OnClick", function()
    ns.settings:SetToDefaults()
    settingsFrame.syncWithSettings()
end)

local buttonRestoreText = buttonRestore:CreateFontString(nil, "BACKGROUND")
buttonRestoreText:SetFont(STANDARD_TEXT_FONT, 10)
buttonRestoreText:SetText("Restore default settings")
buttonRestoreText:SetPoint("TOP", 0, 10)

---@class CheckButtonOptions
---@field x number
---@field y number
---@field position Point
---@field text string
---@field name string
---@field checked boolean
---@field tooltip? string
---@field onClick fun(button: any): nil

---@param opts CheckButtonOptions
local function CreateCheckButton(opts)
    local button = CreateFrame("CheckButton", opts.name, frame, "ChatConfigCheckButtonTemplate")
    button:SetPoint(opts.position, opts.x, opts.y)
    button:SetChecked(opts.checked)
    _G[opts.name .. 'Text']:SetText(opts.text)
    button:SetScript("OnEnter", function(self)
        if opts.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(opts.tooltip, nil, nil, nil, nil, 1)
        end
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    button:SetScript("OnClick", function()
        opts.onClick(button)
    end)
    return button
end

---tooltip settings
local tooltipText = frame:CreateFontString(nil, "BACKGROUND")
tooltipText:SetFont(STANDARD_TEXT_FONT, 12)
tooltipText:SetText("Tooltip:")
tooltipText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -70, -360)

---enable tooltip checkbox
local tooltipEnableCheckbox = CreateCheckButton({
    text = "Enable",
    position = "TOPRIGHT",
    x = -90,
    y = -380,
    name = "TrGCDCheckTooltip",
    checked = ns.settings.tooltipEnabled,
    tooltip = "Show tooltip when hovering an icon",
    onClick = function()
        ns.settings.tooltipEnabled = not ns.settings.tooltipEnabled
        ns.settings:SaveToCharacterSavedVariables()
    end
})

---Stop moving with displayed tooltip checkbox
local stopMovingCheckbox = CreateCheckButton({
    text = "Stop icons",
    position = "TOPRIGHT",
    x = -90,
    y = -410,
    name = "TrGCDCheckTooltipMove",
    checked = ns.settings.tooltipStopScroll,
    tooltip = "Stop moving icons when hovering an icon",
    onClick = function()
        ns.settings.tooltipStopScroll = not ns.settings.tooltipStopScroll
        ns.settings:SaveToCharacterSavedVariables()
    end
})

---Print spell ID to the chat checkbox
local spellIdCheckbox = CreateCheckButton({
    text = "Spell ID",
    position = "TOPRIGHT",
    x = -90,
    y = -440,
    name = "TrGCDCheckTooltipSpellID",
    checked = ns.settings.tooltipPrintSpellId,
    tooltip = "Print spell ID to the chat when hovering an icon",
    onClick = function()
        ns.settings.tooltipPrintSpellId = not ns.settings.tooltipPrintSpellId
        ns.settings:SaveToCharacterSavedVariables()
    end
})

---Scrolling icons checkbox
local scrollingCheckbox = CreateCheckButton({
    text = "Scrolling icons",
    position = "TOPRIGHT",
    x = -90,
    y = -80,
    name = "TrGCDCheckModScroll",
    checked = ns.settings.iconsScroll,
    tooltip = "Icons will be disappearing without moving",
    onClick = function()
        ns.settings.iconsScroll = not ns.settings.iconsScroll
        ns.settings:SaveToCharacterSavedVariables()
    end
})

--EnableIn checkboxes: Enable, World, PvE, Arena, Bg
local enableInText = frame:CreateFontString(nil, "BACKGROUND")
enableInText:SetFont(STANDARD_TEXT_FONT, 12)
enableInText:SetText("Enable in:")
enableInText:SetPoint("TOPRIGHT", -53, -175)

local combatOnlyCheckbox = CreateCheckButton({
    text = "Combat only",
    position = "TOPRIGHT",
    x = -90,
    y = -110,
    name = "trgcdcheckenablein6",
    checked = ns.settings.enabledIn.combatOnly,
    onClick = function()
        ns.settings.enabledIn.combatOnly = not ns.settings.enabledIn.combatOnly
        ns.settings:SaveToCharacterSavedVariables()
        ns.locationCheck.settingsChanged()
    end
})

local enableCheckbox = CreateCheckButton({
    text = "Enable addon",
    position = "TOPRIGHT",
    x = -90,
    y = -140,
    name = "trgcdcheckenablein0",
    checked = ns.settings.enabledIn.enabled,
    onClick = function()
        ns.settings.enabledIn.enabled = not ns.settings.enabledIn.enabled
        ns.settings:SaveToCharacterSavedVariables()
        ns.locationCheck.settingsChanged()
    end
})

local worldCheckbox = CreateCheckButton({
    text = "World",
    position = "TOPRIGHT",
    x = -90,
    y = -200,
    name = "trgcdcheckenablein1",
    checked = ns.settings.enabledIn.world,
    onClick = function()
        ns.settings.enabledIn.world = not ns.settings.enabledIn.world
        ns.settings:SaveToCharacterSavedVariables()
        ns.locationCheck.settingsChanged()
    end
})

local partyCheckbox = CreateCheckButton({
    text = "Party",
    position = "TOPRIGHT",
    x = -90,
    y = -230,
    name = "trgcdcheckenablein2",
    checked = ns.settings.enabledIn.party,
    onClick = function()
        ns.settings.enabledIn.party = not ns.settings.enabledIn.party
        ns.settings:SaveToCharacterSavedVariables()
        ns.locationCheck.settingsChanged()
    end
})

local raidCheckbox = CreateCheckButton({
    text = "Raid",
    position = "TOPRIGHT",
    x = -90,
    y = -260,
    name = "trgcdcheckenablein5",
    checked = ns.settings.enabledIn.raid,
    onClick = function()
        ns.settings.enabledIn.raid = not ns.settings.enabledIn.raid
        ns.settings:SaveToCharacterSavedVariables()
        ns.locationCheck.settingsChanged()
    end
})

local arenaCheckbox = CreateCheckButton({
    text = "Arena",
    position = "TOPRIGHT",
    x = -90,
    y = -290,
    name = "trgcdcheckenablein3",
    checked = ns.settings.enabledIn.arena,
    onClick = function()
        ns.settings.enabledIn.arena = not ns.settings.enabledIn.arena
        ns.settings:SaveToCharacterSavedVariables()
        ns.locationCheck.settingsChanged()
    end
})

local battlegroundCheckbox = CreateCheckButton({
    text = "Battleground",
    position = "TOPRIGHT",
    x = -90,
    y = -320,
    name = "trgcdcheckenablein4",
    checked = ns.settings.enabledIn.battleground,
    onClick = function()
        ns.settings.enabledIn.battleground = not ns.settings.enabledIn.battleground
        ns.settings:SaveToCharacterSavedVariables()
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
labelSize:SetPoint("TOPLEFT", 195, -65)

local labelNumber = frame:CreateFontString(nil, "BACKGROUND")
labelNumber:SetFont(STANDARD_TEXT_FONT, 12)
labelNumber:SetText("Icons number")
labelNumber:SetPoint("TOPLEFT", 290, -65)

local labelScale = frame:CreateFontString(nil, "BACKGROUND")
labelScale:SetFont(STANDARD_TEXT_FONT, 12)
labelScale:SetText("Scale")
labelScale:SetPoint("TOPLEFT", 405, -65)

---@class UnitSettingsFrame
local UnitSettingsFrame = {}
UnitSettingsFrame.__index = UnitSettingsFrame

---@param unitType UnitType
---@param offset number
function UnitSettingsFrame:New(unitType, offset)
    local queueSettings = ns.settings.unitSettings[unitType]

    ---@class UnitSettingsFrame
    local obj = setmetatable({}, UnitSettingsFrame)
    obj.unitType = unitType

    obj.buttonEnable = CreateCheckButton({
        text = queueSettings.text,
        position = "TOPLEFT",
        x = 10,
        y = -50 - offset * 40,
        name = "trgcdcheckenable" .. unitType,
        checked = queueSettings.enable,
        onClick = function()
            queueSettings.enable = not queueSettings.enable

            local iconQueue = ns.units[unitType].iconQueue
            if queueSettings.enable then
                iconQueue:ShowAnchor()
            else
                iconQueue:HideAnchor()
            end

            ns.settings:SaveToCharacterSavedVariables()
		    ns.units[unitType]:Clear()
        end
    })

    ---dropdown menu
    obj.directionDropdown = CreateFrame("Frame", "trgcdframemenu" .. unitType, frame, "UIDropDownMenuTemplate")
    obj.directionDropdown:SetPoint("TOPLEFT", 70, -50 - offset * 40)
    UIDropDownMenu_SetWidth(obj.directionDropdown, 55)
    UIDropDownMenu_SetText(obj.directionDropdown, queueSettings.direction)

    ---@param direction Direction
    local function onMenuItemClick(direction)
        UIDropDownMenu_SetText(obj.directionDropdown, direction)
        queueSettings.direction = direction
        ns.settings:SaveToCharacterSavedVariables()

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
    obj.sizeSlider = CreateFrame("Slider", "trgcdframesizeslider" .. unitType, frame, "OptionsSliderTemplate")
    obj.sizeSlider:SetWidth(100)
    obj.sizeSlider:SetPoint("TOPLEFT", 175, -55 - offset * 40)
    _G[obj.sizeSlider:GetName() .. 'Low']:SetText('10')
    _G[obj.sizeSlider:GetName() .. 'High']:SetText('100')
    _G[obj.sizeSlider:GetName() .. 'Text']:SetText(queueSettings.iconSize)
    obj.sizeSlider:SetMinMaxValues(10,100)
    obj.sizeSlider:SetValueStep(1)
    obj.sizeSlider:SetValue(queueSettings.iconSize)
    obj.sizeSlider:SetScript("OnValueChanged", function(_, value)
        value = math.ceil(value)
        _G[obj.sizeSlider:GetName() .. 'Text']:SetText(value)
        queueSettings.iconSize = value
        ns.settings:SaveToCharacterSavedVariables()

        ns.units[unitType].iconQueue:Resize()
        ns.units[unitType]:Clear()
    end)
    obj.sizeSlider:Show()

    ---Icons number slider
    obj.iconsNumber = CreateFrame("Slider", "trgcdframewidthslider" .. unitType, frame, "OptionsSliderTemplate")
    obj.iconsNumber:SetWidth(80)
    obj.iconsNumber:SetPoint("TOPLEFT", 290, -55 - offset * 40)
    _G[obj.iconsNumber:GetName() .. 'Low']:SetText('1')
    _G[obj.iconsNumber:GetName() .. 'High']:SetText('8')
    _G[obj.iconsNumber:GetName() .. 'Text']:SetText(queueSettings.iconsNumber)
    obj.iconsNumber:SetMinMaxValues(1, 8)
    obj.iconsNumber:SetValueStep(1)
    obj.iconsNumber:SetValue(queueSettings.iconsNumber)
    obj.iconsNumber:SetScript("OnValueChanged", function (_, value)
        value = math.ceil(value)
        _G[obj.iconsNumber:GetName() .. 'Text']:SetText(value)
        queueSettings.iconsNumber = value
        ns.settings:SaveToCharacterSavedVariables()

        ns.units[unitType].iconQueue:Resize()
        ns.units[unitType]:Clear()
    end)
    obj.iconsNumber:Show()

    ---Icons scale slider
    obj.scaleSlider = CreateFrame("Slider", "trgcdframescaleslider" .. unitType, frame, "OptionsSliderTemplate")
    obj.scaleSlider:SetWidth(80)
    obj.scaleSlider:SetPoint("TOPLEFT", 385, -55 - offset * 40)
    _G[obj.scaleSlider:GetName() .. 'Low']:SetText('0.5')
    _G[obj.scaleSlider:GetName() .. 'High']:SetText('2')
    _G[obj.scaleSlider:GetName() .. 'Text']:SetText(queueSettings.iconScale)
    obj.scaleSlider:SetMinMaxValues(0.5, 2)
    obj.scaleSlider:SetValueStep(0.1)
    obj.scaleSlider:SetValue(queueSettings.iconScale)
    obj.scaleSlider:SetScript("OnValueChanged", function (_, value)
        value = math.ceil(value * 10) / 10
        _G[obj.scaleSlider:GetName() .. 'Text']:SetText(value)
        queueSettings.iconScale = value
        ns.settings:SaveToCharacterSavedVariables()

        ns.units[unitType].iconQueue:Resize()
        ns.units[unitType]:Clear()
    end)
    obj.iconsNumber:Show()

    return obj
end

function UnitSettingsFrame:SyncWithSettings()
    local queueSettings = ns.settings.unitSettings[self.unitType]

    self.buttonEnable:SetChecked(queueSettings.enable)
    UIDropDownMenu_SetText(self.directionDropdown, queueSettings.direction)

    _G[self.sizeSlider:GetName() .. 'Text']:SetText(queueSettings.iconSize)
    self.sizeSlider:SetValue(queueSettings.iconSize)

    _G[self.iconsNumber:GetName() .. 'Text']:SetText(queueSettings.iconsNumber)
    self.iconsNumber:SetValue(queueSettings.iconsNumber)

    _G[self.scaleSlider:GetName() .. 'Text']:SetText(queueSettings.iconScale)
    self.scaleSlider:SetValue(queueSettings.iconScale)

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
    tooltipEnableCheckbox:SetChecked(ns.settings.tooltipEnabled)
    stopMovingCheckbox:SetChecked(ns.settings.tooltipStopScroll)
    spellIdCheckbox:SetChecked(ns.settings.tooltipPrintSpellId)
    scrollingCheckbox:SetChecked(ns.settings.iconsScroll)

    combatOnlyCheckbox:SetChecked(ns.settings.enabledIn.combatOnly)
    enableCheckbox:SetChecked(ns.settings.enabledIn.enabled)
    worldCheckbox:SetChecked(ns.settings.enabledIn.world)
    partyCheckbox:SetChecked(ns.settings.enabledIn.party)
    raidCheckbox:SetChecked(ns.settings.enabledIn.raid)
    arenaCheckbox:SetChecked(ns.settings.enabledIn.arena)
    battlegroundCheckbox:SetChecked(ns.settings.enabledIn.battleground)

    for _, unitSettings in pairs(unitSettingsFrames) do
        unitSettings:SyncWithSettings()
    end
end
