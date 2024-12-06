---@type string, Namespace
local _, ns = ...

local AceGUI = LibStub("AceGUI-3.0")

---@class LabelSettingsFrame
local labelSettingsFrame = {}
ns.labelSettingsFrame = labelSettingsFrame

local settingFrame = CreateFrame("Frame", nil, UIParent)
settingFrame:Hide()
settingFrame.name = "Labels"
settingFrame.parent = "TrufiGCD"
ns.utils.interfaceOptions_AddCategory(settingFrame)

local container = AceGUI:Create("SimpleGroup")
container:SetLayout("List")
container.frame:SetParent(settingFrame)
container.frame:ClearAllPoints()
container.frame:SetAllPoints(settingFrame)
container.frame:Show()

local title = AceGUI:Create("Label")
title:SetText("|cFFFFFFFFLabels|r")
title:SetFont(STANDARD_TEXT_FONT, 18, "")
title:SetFullWidth(true)
container:AddChild(title)

local heading = AceGUI:Create("Heading")
heading:SetFullWidth(true)
container:AddChild(heading)

local enableCheckBox = AceGUI:Create("CheckBox")
enableCheckBox:SetLabel("Enable")
enableCheckBox:SetCallback("OnValueChanged", function(_, _, value)
    ns.settings.activeProfile.labels.enable = value
    ns.settings:Save()
    for _, unit in pairs(ns.units) do
        unit.iconQueue:SyncLabelSettings()
    end
end)
container:AddChild(enableCheckBox)

local spacer1 = AceGUI:Create("Label")
spacer1:SetText(" ")
spacer1:SetFullWidth(true)
container:AddChild(spacer1)

local colorGroup = AceGUI:Create("InlineGroup")
colorGroup:SetTitle("Colors")
colorGroup:SetFullWidth(true)
colorGroup:SetLayout("List")
container:AddChild(colorGroup)

local damageColor = AceGUI:Create("ColorPicker")
damageColor:SetLabel("Damage")
damageColor:SetWidth(200)
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
critColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
    ns.settings.activeProfile.labels.critColor.r = r
    ns.settings.activeProfile.labels.critColor.g = g
    ns.settings.activeProfile.labels.critColor.b = b
    ns.settings.activeProfile.labels.critColor.a = a
    ns.settings:Save()
end)
colorGroup:AddChild(critColor)

local spacer2 = AceGUI:Create("Label")
spacer2:SetText(" ")
spacer2:SetFullWidth(true)
container:AddChild(spacer2)

local positionMenu = AceGUI:Create("Dropdown")
positionMenu:SetLabel("Position")
positionMenu:SetList({
    TOP = "TOP",
    BOTTOM = "BOTTOM",
    CENTER = "CENTER",
})
positionMenu:SetCallback("OnValueChanged", function(_, _, key)
    ns.settings.activeProfile.labels.position = key
    ns.settings:Save()

    for _, unit in pairs(ns.units) do
        unit.iconQueue:SyncLabelSettings()
    end
end)
container:AddChild(positionMenu)

labelSettingsFrame.syncWithSettings = function()
    local settings = ns.settings.activeProfile.labels
    enableCheckBox:SetValue(settings.enable)
    damageColor:SetColor(
        settings.damageColor.r,
        settings.damageColor.g,
        settings.damageColor.b,
        settings.damageColor.a
    )
    healColor:SetColor(
        settings.healColor.r,
        settings.healColor.g,
        settings.healColor.b,
        settings.healColor.a
    )
    critColor:SetColor(
        settings.critColor.r,
        settings.critColor.g,
        settings.critColor.b,
        settings.critColor.a
    )
    positionMenu:SetValue(settings.position)
end
