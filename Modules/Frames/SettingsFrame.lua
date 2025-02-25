---@type string, Namespace
local _, ns = ...

local AceGUI = LibStub("AceGUI-3.0")

---@class SettingsFrame
local settingsFrame = {}
ns.settingsFrame = settingsFrame

local frame = CreateFrame("Frame", nil, UIParent)
frame:Hide()
frame.name = "TrufiGCD"
settingsFrame.frame = frame
ns.utils.interfaceOptions_AddCategory(frame)

SLASH_TRUFI1, SLASH_TRUFI2 = '/tgcd', '/trufigcd'
function SlashCmdList.TRUFI()
    Settings.OpenToCategory(frame.name)
end

local simpleGroup = AceGUI:Create("SimpleGroup")
simpleGroup:SetLayout("Flow")
simpleGroup.frame:SetParent(frame)
simpleGroup.frame:ClearAllPoints()
simpleGroup.frame:SetAllPoints(frame)
simpleGroup.frame:Show()

local showHideAnchorsGroup = AceGUI:Create("SimpleGroup")
showHideAnchorsGroup:SetWidth(200)
showHideAnchorsGroup:SetHeight(200)
showHideAnchorsGroup:SetLayout("Flow")
simpleGroup:AddChild(showHideAnchorsGroup)

local showHideAnchorsButtonLabel = AceGUI:Create("Label")
showHideAnchorsButtonLabel:SetFont(STANDARD_TEXT_FONT, 10, "")
showHideAnchorsButtonLabel:SetText('Show/Hide anchors')
showHideAnchorsGroup:AddChild(showHideAnchorsButtonLabel)

local showHideAnchorsButton = AceGUI:Create("Button")
showHideAnchorsButton:SetWidth(100)
showHideAnchorsButton:SetHeight(22)
showHideAnchorsButton:SetText('Show')
showHideAnchorsGroup:AddChild(showHideAnchorsButton)
-- ns.frameUtils.addTooltip(showHideAnchorsButton, "Show/Hide anchors", "Show or hide icon frame anchors to change their position")

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
        for _, unit in pairs(ns.units) do
            local unitSettings = ns.settings.activeProfile.unitSettings[unit.unitType]
            unitSettings.point, _, _, unitSettings.x, unitSettings.y = unit.iconQueue.frame:GetPoint()
            unit.iconQueue:HideAnchor()
        end
        ns.settings:Save()
    else
        showHideAnchorsButton:SetText("Hide")
        frameShowAnchors:Show()
        for _, unit in pairs(ns.units) do
            local layout = ns.settings.activeProfile.layoutSettings[unit.layoutType]
            if layout.enable then
                unit.iconQueue:ShowAnchor()
            end
        end
    end
    anchorDisplayed = not anchorDisplayed
end

frameShowAnchorsHideButton:SetScript("OnClick", function() settingsFrame.toggleAnchors() end)
showHideAnchorsButton:SetCallback("OnClick", function() settingsFrame.toggleAnchors() end)


---@param container any
---@param width number | nil
---@param height number | nil
local function addSpace(container, width, height)
    local spacer = AceGUI:Create("Label")
    spacer:SetText(" ")
    -- spacer:SetText((width or "N") .. " x " .. (height or "N"))
    if width ~= nil then
        spacer:SetWidth(width)
    else
        spacer:SetFullWidth(true)
    end
    if height ~= nil then
        spacer:SetHeight(height)
        spacer:SetFont(STANDARD_TEXT_FONT, height, "")
    else
        spacer:SetFullHeight(true)
    end
    container:AddChild(spacer)
end

local layoutTab = AceGUI:Create("TabGroup")
layoutTab:SetLayout("List")
layoutTab:SetFullWidth(true)
layoutTab:SetTabs({
    {text = "Player", value = "player"},
    {text = "Party", value = "party"},
    {text = "Arena", value = "arena"},
    {text = "Target", value = "target"},
    {text = "Focus", value = "focus"},
})
layoutTab:SetCallback("OnGroupSelected", function(container, event, layoutType)
    container:ReleaseChildren()
    addSpace(container, nil, 10)

    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable")
    enableCheckbox:SetWidth(100)
    enableCheckbox:SetValue(ns.settings.activeProfile.layoutSettings[layoutType].enable)
    enableCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        ns.settings.activeProfile.layoutSettings[layoutType].enable = value

        for _, unit in pairs(ns.units) do
            if unit.layoutType == layoutType then
                if ns.settings.activeProfile.layoutSettings[layoutType].enable then
                    unit.iconQueue:ShowAnchor()
                else
                    unit.iconQueue:HideAnchor()
                end
                unit:Clear()
            end
        end

        ns.settings:Save()
    end)
    container:AddChild(enableCheckbox)
    addSpace(container, nil, 10)

    local iconGroup = AceGUI:Create("InlineGroup")
    iconGroup:SetTitle("Icons")
    iconGroup:SetLayout("Flow")
    iconGroup:SetFullWidth(true)
    container:AddChild(iconGroup)

    local directionDropdown = AceGUI:Create("Dropdown")
    directionDropdown:SetLabel("Fade Direction")
    directionDropdown:SetWidth(100)
    directionDropdown:SetList({
        ["Left"] = "Left",
        ["Right"] = "Right",
        ["Up"] = "Up",
        ["Down"] = "Down"
    })
    directionDropdown:SetValue(ns.settings.activeProfile.layoutSettings[layoutType].direction)
    directionDropdown:SetCallback("OnValueChanged", function(_, _, value)
        ns.settings.activeProfile.layoutSettings[layoutType].direction = value
        ns.settings:Save()

        for _, unit in pairs(ns.units) do
            if unit.layoutType == layoutType then
                unit.iconQueue:Resize()
                unit:Clear()
            end
        end
    end)
    iconGroup:AddChild(directionDropdown)
    addSpace(iconGroup, 20)

    local sizeSlider = AceGUI:Create("Slider")
    sizeSlider:SetLabel("Icon Size")
    sizeSlider:SetWidth(200)
    sizeSlider:SetSliderValues(10, 100, 1)
    sizeSlider:SetValue(ns.settings.activeProfile.layoutSettings[layoutType].iconSize)
    sizeSlider:SetCallback("OnValueChanged", function(_, _, value)
        value = math.ceil(value)
        ns.settings.activeProfile.layoutSettings[layoutType].iconSize = value
        ns.settings:Save()

        for _, unit in pairs(ns.units) do
            if unit.layoutType == layoutType then
                unit.iconQueue:Resize()
                unit:Clear()
            end
        end
    end)
    iconGroup:AddChild(sizeSlider)
    addSpace(iconGroup, 20)

    local iconSlider = AceGUI:Create("Slider")
    iconSlider:SetLabel("Row Length In Icons")
    iconSlider:SetWidth(200)
    iconSlider:SetSliderValues(1, 8, 1)
    iconSlider:SetValue(ns.settings.activeProfile.layoutSettings[layoutType].iconsNumber)
    iconSlider:SetCallback("OnValueChanged", function(_, _, value)
        value = math.ceil(value)
        ns.settings.activeProfile.layoutSettings[layoutType].iconsNumber = value
        ns.settings:Save()

        for _, unit in pairs(ns.units) do
            if unit.layoutType == layoutType then
                unit.iconQueue:Resize()
                unit:Clear()
            end
        end
    end)
    iconGroup:AddChild(iconSlider)

    addSpace(container, nil, 20)

    local labelsGroup = AceGUI:Create("InlineGroup")
    labelsGroup:SetTitle("Labels")
    labelsGroup:SetLayout("Flow")
    labelsGroup:SetFullWidth(true)
    container:AddChild(labelsGroup)

    local labelsSettings = ns.settings.activeProfile.labels

    local labelEnableCheckBox = AceGUI:Create("CheckBox")
    labelEnableCheckBox:SetLabel("Enable")
    labelEnableCheckBox:SetWidth(120)
    labelEnableCheckBox:SetValue(labelsSettings.enable)
    labelEnableCheckBox:SetCallback("OnValueChanged", function(_, _, value)
        ns.settings.activeProfile.labels.enable = value
        ns.settings:Save()
        for _, unit in pairs(ns.units) do
            unit.iconQueue:SyncLabelSettings()
        end
    end)
    labelsGroup:AddChild(labelEnableCheckBox)
    addSpace(labelsGroup, nil, 5)

    local positionMenu = AceGUI:Create("Dropdown")
    positionMenu:SetLabel("Position")
    positionMenu:SetList({
        TOP = "TOP",
        BOTTOM = "BOTTOM",
        CENTER = "CENTER",
    })
    positionMenu:SetValue(labelsSettings.position)
    positionMenu:SetCallback("OnValueChanged", function(_, _, key)
        ns.settings.activeProfile.labels.position = key
        ns.settings:Save()

        for _, unit in pairs(ns.units) do
            unit.iconQueue:SyncLabelSettings()
        end
    end)
    labelsGroup:AddChild(positionMenu)
    addSpace(labelsGroup, nil, 10)

    local colorGroup = AceGUI:Create("InlineGroup")
    colorGroup:SetTitle("Colors")
    colorGroup:SetFullWidth(true)
    colorGroup:SetLayout("Flow")
    labelsGroup:AddChild(colorGroup)

    local damageColor = AceGUI:Create("ColorPicker")
    damageColor:SetLabel("Damage")
    damageColor:SetWidth(200)
    damageColor:SetColor(
        labelsSettings.damageColor.r,
        labelsSettings.damageColor.g,
        labelsSettings.damageColor.b,
        labelsSettings.damageColor.a
    )
    damageColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
        ns.settings.activeProfile.labels.damageColor.r = r
        ns.settings.activeProfile.labels.damageColor.g = g
        ns.settings.activeProfile.labels.damageColor.b = b
        ns.settings.activeProfile.labels.damageColor.a = a
        ns.settings:Save()
    end)
    colorGroup:AddChild(damageColor)

    local healColor = AceGUI:Create("ColorPicker")
    healColor:SetLabel("Heal")
    healColor:SetWidth(200)
    healColor:SetColor(
        labelsSettings.healColor.r,
        labelsSettings.healColor.g,
        labelsSettings.healColor.b,
        labelsSettings.healColor.a
    )
    healColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
        ns.settings.activeProfile.labels.healColor.r = r
        ns.settings.activeProfile.labels.healColor.g = g
        ns.settings.activeProfile.labels.healColor.b = b
        ns.settings.activeProfile.labels.healColor.a = a
        ns.settings:Save()
    end)
    colorGroup:AddChild(healColor)

    local critColor = AceGUI:Create("ColorPicker")
    critColor:SetLabel("Critical")
    critColor:SetWidth(200)
    critColor:SetColor(
        labelsSettings.critColor.r,
        labelsSettings.critColor.g,
        labelsSettings.critColor.b,
        labelsSettings.critColor.a
    )
    critColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
        ns.settings.activeProfile.labels.critColor.r = r
        ns.settings.activeProfile.labels.critColor.g = g
        ns.settings.activeProfile.labels.critColor.b = b
        ns.settings.activeProfile.labels.critColor.a = a
        ns.settings:Save()
    end)
    colorGroup:AddChild(critColor)
end)

layoutTab:SelectTab("player")
simpleGroup:AddChild(layoutTab)

settingsFrame.syncWithSettings = function()
    layoutTab:SelectTab("player")
end
