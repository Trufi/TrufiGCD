---@type string, Namespace
local _, ns = ...

---@class BlocklistFrame
local blocklistFrame = {}
ns.blocklistFrame = blocklistFrame

local frame = CreateFrame("Frame", nil, UIParent)
frame:Hide()
frame.name = "Blocklist"
frame.parent = "TrufiGCD"
ns.utils.interfaceOptions_AddCategory(frame)

local listBorder = CreateFrame("Frame", nil, frame, "BackdropTemplate")
listBorder:SetPoint("TOPLEFT", 10, -25)
listBorder:SetWidth(200)
listBorder:SetHeight(501)
listBorder:SetBackdrop({
    bgFile = nil,
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {left = 0, right = 0, top = 0, bottom = 0}
})
listBorder:SetBackdropBorderColor(0.4, 0.4, 0.4)

local listContainer = CreateFrame("ScrollFrame", nil, frame)
listContainer:SetPoint("TOPLEFT",10, -30)
listContainer:SetWidth(200)
listContainer:SetHeight(488)

local listScrollBar = CreateFrame("Slider", "TrGCDBLScroll", listContainer, "UIPanelScrollBarTemplate")
listScrollBar:SetPoint("TOPLEFT", listContainer, "TOPRIGHT", 1, -16)
listScrollBar:SetPoint("BOTTOMLEFT", listContainer, "BOTTOMRIGHT", 1, 16)
listScrollBar:SetMinMaxValues(1, 470)
listScrollBar:SetValueStep(1)
listScrollBar:SetValue(0)
listScrollBar:SetScript("OnValueChanged", function(self, value)
    self:GetParent():SetVerticalScroll(value)
end)

local listScrollBarBackground = listScrollBar:CreateTexture(nil, "BACKGROUND")
listScrollBarBackground:SetAllPoints(listScrollBar)
listScrollBarBackground:SetColorTexture(0, 0, 0, 0.4)


local list = CreateFrame("Frame", nil, listContainer)
list:SetWidth(200)
list:SetHeight(958)

local listText = list:CreateFontString(nil, "BACKGROUND")
listText:SetFont(STANDARD_TEXT_FONT, 12)
listText:SetText("Spell Blocklist")
listText:SetPoint("TOPLEFT", 15, 15)

local selectedItemText = frame:CreateFontString(nil, "BACKGROUND")
selectedItemText:SetFont(STANDARD_TEXT_FONT, 12)
selectedItemText:SetText("Select spell to delete")

---@class Item
---@field index integer
---@field button any
---@field texture any
---@field text any

---@type Item | nil
local selectedItem = nil

---@type Item[]
local items = {}

for i = 1, 60 do
    local button = CreateFrame("Button", nil, list)
    button:SetWidth(192)
    button:SetHeight(15)
    button:SetPoint("TOP", 0, -(i - 1) * 16)
    button:Disable()

    local text = button:CreateFontString(nil, "BACKGROUND")
    text:SetFont(STANDARD_TEXT_FONT, 11)
    text:SetText(" ")
    text:SetPoint("TOP", 0, 10)
    text:SetAllPoints(button)

    local texture = button:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(button)
    texture:SetColorTexture(255, 210, 0)
    texture:SetAlpha(0)

    ---@type Item
    local item = {
        index = i,
        button = button,
        text = text,
        texture = texture,
    }
    items[i] = item

    button:SetScript("OnEnter", function()
        if selectedItem ~= item then
            texture:SetAlpha(0.3)
        end
    end)

    button:SetScript("OnLeave", function()
        if selectedItem ~= item then
            texture:SetAlpha(0)
        end
    end)

    button:SetScript("OnClick", function()
        if selectedItem ~= nil then
            selectedItem.texture:SetAlpha(0)
        end
        selectedItem = item
        texture:SetAlpha(0.6)
        selectedItemText:SetText(text:GetText())
    end)
end

local addOnIconClickCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Add by Ctrl+Alt+Click on icon",
    position = "TOPLEFT",
    x = 260,
    y = -280,
    name = "TrGCDCheckiconClickAddsSpellToBlocklist",
    checked = ns.settings.activeProfile.iconClickAddsSpellToBlocklist,
    tooltip = "Add a spell to blocklist by Ctrl+Alt+Click on the spell icon",
    onClick = function()
        ns.settings.activeProfile.iconClickAddsSpellToBlocklist = not ns.settings.activeProfile.iconClickAddsSpellToBlocklist
        ns.settings:Save()
    end
})

blocklistFrame.syncWithSettings = function()
	for i = 1, 60 do
        local spellId = ns.settings.activeProfile.blocklist[i]
        local item = items[i]
        if spellId ~= nil then
            item.button:Enable()

            local name = ns.utils.getSpellInfo(spellId)
            if name then
                item.text:SetText(spellId .. " - " .. name)
            else
                item.text:SetText(spellId)
            end

        else
            item.button:Disable()
            item.text:SetText(nil)
            item.texture:SetAlpha(0)
        end
    end

    addOnIconClickCheckbox:SetChecked(ns.settings.activeProfile.iconClickAddsSpellToBlocklist)
end
blocklistFrame.syncWithSettings()

local buttonDelete = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
buttonDelete:SetWidth(100)
buttonDelete:SetHeight(22)
buttonDelete:SetPoint("TOPLEFT", 260, -130)
buttonDelete:SetText("Delete")
buttonDelete:SetScript("OnClick", function()
    if selectedItem then
        table.remove(ns.settings.activeProfile.blocklist, selectedItem.index)
        selectedItemText:SetText("Select spell to delete")
        ns.settings:Save()
        blocklistFrame.syncWithSettings()
    end
end)
selectedItemText:SetPoint("TOPLEFT", buttonDelete, "TOPLEFT", 5, 15)

listContainer:SetScrollChild(list)

local input = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
input:SetWidth(200)
input:SetHeight(20)
input:SetPoint("TOPLEFT", 265, -200)
input:SetAutoFocus(false)
input:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

local function addItem()
    if #ns.settings.activeProfile.blocklist >= 60 then
        print("[TrufiGCD]: blocklist has exceeded its limit of 60 items")
        return
    end

    ---@type string
    local inputValue = input:GetText()
    if not inputValue then
        return
    end

    local inputSpellId = tonumber(inputValue)

    if inputSpellId ~= nil then
        table.insert(ns.settings.activeProfile.blocklist, inputSpellId)
    else
        local spellName = inputValue

        ---@type number | nil
        local spellId = select(7, ns.utils.getSpellInfo(spellName))

        if not spellId then
            print("[TrufiGCD]: can't find a spell ID for the name \"" .. spellName .. "\". Please, provide the exact spell ID.")
            return
        end

        table.insert(ns.settings.activeProfile.blocklist, spellId)
        print("[TrufiGCD]: converted \"" .. spellName .. "\" to spell ID \"" .. spellId .. "\". If this is not the desired spell ID, provide the exact ID of the spell you wish to block as multiple ones with this name may exist.")
    end

    ns.settings:Save()
    blocklistFrame.syncWithSettings()
    input:SetText("")
    input:ClearFocus()
end
input:SetScript("OnEnterPressed", addItem)

local buttonAdd = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
buttonAdd:SetWidth(100)
buttonAdd:SetHeight(22)
buttonAdd:SetPoint("TOPLEFT", 260, -225)
buttonAdd:SetText("Add")
buttonAdd:SetScript("OnClick", addItem)

local buttonAddText = buttonAdd:CreateFontString(nil, "BACKGROUND")
buttonAddText:SetFont(STANDARD_TEXT_FONT, 12)
buttonAddText:SetText("Enter spell ID or name")
buttonAddText:SetPoint("TOPLEFT", 5, 40)

-- Item Blocklist Section
local itemListBorder = CreateFrame("Frame", nil, frame, "BackdropTemplate")
itemListBorder:SetPoint("TOPLEFT", 480, -25)
itemListBorder:SetWidth(200)
itemListBorder:SetHeight(501)
itemListBorder:SetBackdrop({
    bgFile = nil,
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {left = 0, right = 0, top = 0, bottom = 0}
})
itemListBorder:SetBackdropBorderColor(0.4, 0.4, 0.4)

local itemListContainer = CreateFrame("ScrollFrame", nil, frame)
itemListContainer:SetPoint("TOPLEFT", 480, -30)
itemListContainer:SetWidth(200)
itemListContainer:SetHeight(488)

local itemListScrollBar = CreateFrame("Slider", "TrGCDItemBLScroll", itemListContainer, "UIPanelScrollBarTemplate")
itemListScrollBar:SetPoint("TOPLEFT", itemListContainer, "TOPRIGHT", 1, -16)
itemListScrollBar:SetPoint("BOTTOMLEFT", itemListContainer, "BOTTOMRIGHT", 1, 16)
itemListScrollBar:SetMinMaxValues(1, 470)
itemListScrollBar:SetValueStep(1)
itemListScrollBar:SetValue(0)
itemListScrollBar:SetScript("OnValueChanged", function(self, value)
    self:GetParent():SetVerticalScroll(value)
end)

local itemListScrollBarBackground = itemListScrollBar:CreateTexture(nil, "BACKGROUND")
itemListScrollBarBackground:SetAllPoints(itemListScrollBar)
itemListScrollBarBackground:SetColorTexture(0, 0, 0, 0.4)

local itemList = CreateFrame("Frame", nil, itemListContainer)
itemList:SetWidth(200)
itemList:SetHeight(958)

local itemListText = itemList:CreateFontString(nil, "BACKGROUND")
itemListText:SetFont(STANDARD_TEXT_FONT, 12)
itemListText:SetText("Item Blocklist")
itemListText:SetPoint("TOPLEFT", 15, 15)

local selectedItemItemText = frame:CreateFontString(nil, "BACKGROUND")
selectedItemItemText:SetFont(STANDARD_TEXT_FONT, 12)
selectedItemItemText:SetText("Select item to delete")

---@type Item | nil
local selectedItemItem = nil

---@type Item[]
local itemItems = {}

for i = 1, 60 do
    local button = CreateFrame("Button", nil, itemList)
    button:SetWidth(192)
    button:SetHeight(15)
    button:SetPoint("TOP", 0, -(i - 1) * 16)
    button:Disable()

    local text = button:CreateFontString(nil, "BACKGROUND")
    text:SetFont(STANDARD_TEXT_FONT, 11)
    text:SetText(" ")
    text:SetPoint("TOP", 0, 10)
    text:SetAllPoints(button)

    local texture = button:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(button)
    texture:SetColorTexture(255, 210, 0)
    texture:SetAlpha(0)

    ---@type Item
    local item = {
        index = i,
        button = button,
        text = text,
        texture = texture,
    }
    itemItems[i] = item

    button:SetScript("OnEnter", function()
        if selectedItemItem ~= item then
            texture:SetAlpha(0.3)
        end
    end)

    button:SetScript("OnLeave", function()
        if selectedItemItem ~= item then
            texture:SetAlpha(0)
        end
    end)

    button:SetScript("OnClick", function()
        if selectedItemItem ~= nil then
            selectedItemItem.texture:SetAlpha(0)
        end
        selectedItemItem = item
        texture:SetAlpha(0.6)
        selectedItemItemText:SetText(text:GetText())
    end)
end

local addOnIconClickItemCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Add by Ctrl+Alt+Click on icon",
    position = "TOPLEFT",
    x = 730,
    y = -280,
    name = "TrGCDCheckiconClickAddsItemToBlocklist",
    checked = ns.settings.activeProfile.iconClickAddsItemToBlocklist,
    tooltip = "Add an item to blocklist by Ctrl+Alt+Click on the item icon",
    onClick = function()
        ns.settings.activeProfile.iconClickAddsItemToBlocklist = not ns.settings.activeProfile.iconClickAddsItemToBlocklist
        ns.settings:Save()
    end
})

local function syncItemBlocklistWithSettings()
    for i = 1, 60 do
        local itemId = ns.settings.activeProfile.itemBlocklist[i]
        local item = itemItems[i]
        if itemId ~= nil then
            item.button:Enable()

            local itemName = GetItemInfo(itemId)
            if itemName then
                item.text:SetText(itemId .. " - " .. itemName)
            else
                item.text:SetText(itemId)
            end
        else
            item.button:Disable()
            item.text:SetText(nil)
            item.texture:SetAlpha(0)
        end
    end

    addOnIconClickItemCheckbox:SetChecked(ns.settings.activeProfile.iconClickAddsItemToBlocklist)
end


local buttonItemDelete = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
buttonItemDelete:SetWidth(100)
buttonItemDelete:SetHeight(22)
buttonItemDelete:SetPoint("TOPLEFT", 730, -130)
buttonItemDelete:SetText("Delete")
buttonItemDelete:SetScript("OnClick", function()
    if selectedItemItem then
        table.remove(ns.settings.activeProfile.itemBlocklist, selectedItemItem.index)
        selectedItemItemText:SetText("Select item to delete")
        ns.settings:Save()
        syncItemBlocklistWithSettings()
    end
end)
selectedItemItemText:SetPoint("TOPLEFT", buttonItemDelete, "TOPLEFT", 5, 15)

itemListContainer:SetScrollChild(itemList)

local itemInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
itemInput:SetWidth(200)
itemInput:SetHeight(20)
itemInput:SetPoint("TOPLEFT", 735, -200)
itemInput:SetAutoFocus(false)
itemInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

local function addItemToBlocklist()
    if #ns.settings.activeProfile.itemBlocklist >= 60 then
        print("[TrufiGCD]: item blocklist has exceeded its limit of 60 items")
        return
    end

    ---@type string
    local inputValue = itemInput:GetText()
    if not inputValue then
        return
    end

    local inputItemId = tonumber(inputValue)

    if inputItemId ~= nil then
        table.insert(ns.settings.activeProfile.itemBlocklist, inputItemId)
    else
        local itemName = inputValue
        local itemId = GetItemInfoInstant(itemName)

        if not itemId then
            print("[TrufiGCD]: can't find an item ID for the name \"" .. itemName .. "\". Please, provide the exact item ID.")
            return
        end

        table.insert(ns.settings.activeProfile.itemBlocklist, itemId)
        print("[TrufiGCD]: converted \"" .. itemName .. "\" to item ID \"" .. itemId .. "\". If this is not the desired item ID, provide the exact ID of the item you wish to block as multiple ones with this name may exist.")
    end

    ns.settings:Save()
    syncItemBlocklistWithSettings()
    itemInput:SetText("")
    itemInput:ClearFocus()
end
itemInput:SetScript("OnEnterPressed", addItemToBlocklist)

local buttonItemAdd = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
buttonItemAdd:SetWidth(100)
buttonItemAdd:SetHeight(22)
buttonItemAdd:SetPoint("TOPLEFT", 730, -225)
buttonItemAdd:SetText("Add")
buttonItemAdd:SetScript("OnClick", addItemToBlocklist)

local buttonItemAddText = buttonItemAdd:CreateFontString(nil, "BACKGROUND")
buttonItemAddText:SetFont(STANDARD_TEXT_FONT, 12)
buttonItemAddText:SetText("Enter item ID or name")
buttonItemAddText:SetPoint("TOPLEFT", 5, 40)

-- Update the original syncWithSettings to also sync item blocklist
local originalSyncWithSettings = blocklistFrame.syncWithSettings
blocklistFrame.syncWithSettings = function()
    originalSyncWithSettings()
    syncItemBlocklistWithSettings()
end

-- Initial sync
syncItemBlocklistWithSettings()
