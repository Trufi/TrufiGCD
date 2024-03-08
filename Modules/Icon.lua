local _, ns = ...

local Masque = LibStub("Masque", true)

local crossTexture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7"

---@class Icon
local Icon = {}
Icon.__index = Icon
ns.Icon = Icon

---@param parentFrame any
---@param unitIndex any
function Icon:New(parentFrame, unitIndex)
    ---@class Icon
    local obj = setmetatable({}, Icon)
    obj.parentFrame = parentFrame
    obj.unitIndex = unitIndex
    obj.displayed = false
    obj.offset = 0
    obj.startTime = 0
    obj.spellId = 0
    obj.cancelTextureDisplayed = false
    obj:CreateFrame()
    return obj
end

---@private
function Icon:CreateFrame()
    local options = TrGCDQueueOpt[self.unitIndex]

    self.frame = CreateFrame("Button", nil, self.parentFrame)
    self.frame:Hide()
    self.frame:SetScript("OnEnter", function() self:onEnter() end)
    self.frame:SetScript("OnLeave", function() self:onLeave() end)
    self.frame:SetWidth(options.size)
    self.frame:SetHeight(options.size)

    self.texture = self.frame:CreateTexture(nil, "BACKGROUND")
    self.texture:SetAllPoints(self.frame)

    self.cancelTexture = self.frame:CreateTexture(nil, "BORDER")
    self.cancelTexture:SetAllPoints(self.frame)
    self.cancelTexture:SetTexture(crossTexture)
    self.cancelTexture:SetAlpha(1)
    self.cancelTexture:Hide()

    if Masque then
        TrGCDMasqueIcons:AddButton(self.frame, {Icon = self.texture})
    end
end

function Icon:Show()
    self.startTime = GetTime()
    self.displayed = true
    self.frame:Show()
    self.frame:SetAlpha(1)
end

function Icon:Hide()
    self.offset = 0
    self.displayed = false

    self.frame:Hide()
    self.frame:SetAlpha(0)

    self.cancelTextureDisplayed = false
    self.cancelTexture:Hide()
end

---@param size number
function Icon:Clear(size)
    self.offset = 0
    self.displayed = false
    self.cancelTextureDisplayed = false

    self.frame:SetAlpha(0)
    self.frame:SetHeight(size)
    self.frame:SetWidth(size)
    self.frame:ClearAllPoints()
    self.frame:Hide()

    self.cancelTexture:SetTexture(nil)
    self.cancelTexture:Hide()
end

function Icon:UpdatePosition()
    local direction = TrGCDQueueOpt[self.unitIndex].fade
    if direction == "Left" then
        self.frame:SetPoint("RIGHT", self.offset, 0)
    elseif direction == "Right" then
        self.frame:SetPoint("LEFT", -self.offset, 0)
    elseif direction == "Up" then
        self.frame:SetPoint("BOTTOM", 0, -self.offset)
    elseif direction == "Down" then
        self.frame:SetPoint("TOP", 0, self.offset)
    end
end

---@param from Icon
function Icon:Copy(from)
    self.offset = from.offset
    self.startTime = from.startTime

    self:UpdatePosition()
    self.texture:SetTexture(from.texture:GetTexture())

    self.displayed = from.displayed
    if self.displayed then
        self.frame:Show()
        self.frame:SetAlpha(1)
    else
        self.frame:Hide()
    end

    self.cancelTextureDisplayed = from.cancelTextureDisplayed
    if self.cancelTextureDisplayed then
        self.cancelTexture:Show()
    else
        self.cancelTexture:Hide()
    end
end

---@param id number
function Icon:SetSpell(id, texture)
    self.offset = 0
    self.displayed = false
    self.spellId = id
    self.texture:SetTexture(texture)
    self.frame:SetAlpha(0)
    self.frame:Hide()
end

function Icon:ShowCancelTexture()
    self.cancelTexture:Show()
    self.cancelTextureDisplayed = true
end

function Icon:HideCancelTexture()
    self.cancelTexture:Hide()
    self.cancelTextureDisplayed = false
end

---@private
function Icon:onEnter()
    if TrufiGCDChSave["TooltipEnable"] then
        GameTooltip_SetDefaultAnchor(GameTooltip, self.frame)
        GameTooltip:SetSpellByID(self.spellId, false, false, true)
        GameTooltip:Show()
        if TrufiGCDChSave["TooltipStopMove"] then
            TrGCDIconOnEnter[self.unitIndex] = false
        end
        if TrufiGCDChSave["TooltipSpellID"] then
            if self.spellId ~= nil then
                print(GetSpellLink(self.spellId) .. " ID: " .. self.spellId)
            end
        end
    end
end

---@private
function Icon:onLeave()
    GameTooltip_Hide()
    TrGCDIconOnEnter[self.unitIndex] = true
end
