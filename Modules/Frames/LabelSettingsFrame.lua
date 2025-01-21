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

-- Add some content under the first heading
local title = AceGUI:Create("Label")
title:SetText("|cFFFFFFFFLabels|r")
title:SetFont(STANDARD_TEXT_FONT, 18, "")
title:SetFullWidth(true)
container:AddChild(title)

local heading = AceGUI:Create("Heading")
heading:SetFullWidth(true)
container:AddChild(heading)

local enableCheckBox = AceGUI:Create("CheckBox")
enableCheckBox:SetValue(true)
enableCheckBox:SetLabel("Enable")
-- enableCheckBox:OnValueChanged
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
-- colorPicker:SetWidth(200)
-- colorPicker:OnValueChanged
colorGroup:AddChild(damageColor)

local healColor = AceGUI:Create("ColorPicker")
healColor:SetLabel("Heal")
-- colorPicker:SetWidth(200)
-- colorPicker:OnValueChanged
colorGroup:AddChild(healColor)

local critColor = AceGUI:Create("ColorPicker")
critColor:SetLabel("Critical")
-- colorPicker:SetWidth(200)
-- colorPicker:OnValueChanged
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
})
positionMenu:SetValue("TOP")
container:AddChild(positionMenu)
