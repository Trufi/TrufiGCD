local _, ns = ...

---@type Icon
local Icon = ns.Icon

local Masque = LibStub("Masque", true)

local fastSpeedModifier = 3

local iconHidingDuration = 2
local iconHidingDelay = 3

local innerIconsNumber = 10

---@class IconQueue
local IconQueue = {}
IconQueue.__index = IconQueue
ns.IconQueue = IconQueue

---@param unitIndex number
function IconQueue:New(unitIndex)
    ---@class IconQueue
    local obj = setmetatable({}, IconQueue)

    ---Index of this icon queue unit
    ---1 - player, 2 - party1, 3 - party2
    ---5 - arena1, 6 - arena2, 7 - arena3
    ---11 - target, 12 - focus
    obj.unitIndex = unitIndex

    ---@type number[]
    obj.nextIconIndices = {}

    ---Buffer between the last shown icon and the start of the frame.
    ---Used to place a next icon if it's big enough.
    obj.buffer = 0

    obj:CreateFrame()

    obj.iconIndex = 1

    ---@type {[number]: Icon}
    obj.icons = {}
    for i = 1, innerIconsNumber do
        obj.icons[i] = Icon:New(obj.frame, unitIndex)
    end

    return obj
end

---@private
function IconQueue:CreateFrame()
    local options = TrGCDQueueOpt[self.unitIndex]

    self.frame = CreateFrame("Frame", nil, UIParent)

    self.texture = self.frame:CreateTexture(nil, "BACKGROUND")
    self.texture:SetAllPoints(self.frame)
    self.texture:SetColorTexture(0, 0, 0)
    self.texture:SetAlpha(0.6)
    self.texture:Hide()

    self.text = self.frame:CreateFontString(nil, "BACKGROUND")
    self.text:SetFont(STANDARD_TEXT_FONT, 9)
    self.text:SetText(options.text)
    self.text:SetAllPoints(self.frame)
    self.text:SetAlpha(0.6)
    self.text:Hide()

    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", self.frame.StartMoving)
    self.frame:SetScript("OnDragStop", self.frame.StopMovingOrSizing)
    self.frame:SetPoint(options.point, options.x, options.y)

    self:Resize()
end

---@param id number
function IconQueue:AddSpell(id, texture)
    if self.iconIndex == innerIconsNumber then
        self.iconIndex = 1
    end

    self.icons[self.iconIndex]:SetSpell(id, texture)
    table.insert(self.nextIconIndices, self.iconIndex)
    self.iconIndex = self.iconIndex + 1
end

---@param from IconQueue
function IconQueue:Copy(from)
    for i = 1, innerIconsNumber do
        self.icons[i]:Copy(from.icons[i])
    end

    self.buffer = from.buffer
    self.iconIndex = from.iconIndex

    self.nextIconIndices = {}
    for _, x in ipairs(from.nextIconIndices) do
        table.insert(self.nextIconIndices, x)
    end
end

---Updates the icons every frame
---@param interval number
---@param iconsScroll boolean
---@param isCasting boolean
function IconQueue:Update(interval, iconsScroll, isCasting)
    local options = TrGCDQueueOpt[self.unitIndex]

    if #self.nextIconIndices > 0 and self.buffer >= options.size then
        self:ShowNextIcon()
        self.buffer = 0
    end

    local fastSpeed = options.speed * fastSpeedModifier * (#self.nextIconIndices + 1)
    local fastSpeedDuration = 0.0

    if #self.nextIconIndices > 0 then
        fastSpeedDuration = math.min((options.size - self.buffer) / fastSpeed, interval)
    end

    local width = options.width * options.size
    local offsetDelta = fastSpeedDuration * fastSpeed
    if not isCasting then
        offsetDelta = offsetDelta + (interval - fastSpeedDuration) * options.speed
    end

    for _, icon in ipairs(self.icons) do
        if icon.displayed then
            if iconsScroll or fastSpeedDuration > 0 then
                icon.offset = icon.offset - offsetDelta
            end

            icon:UpdatePosition()

            if not iconsScroll then
                local elapsedTime = GetTime() - icon.startTime

                if elapsedTime > iconHidingDuration + iconHidingDelay then
                    icon:Hide()
                elseif elapsedTime > iconHidingDelay then
                    local alpha = 1 - (elapsedTime - iconHidingDelay) / iconHidingDuration
                    icon.frame:SetAlpha(alpha)
                end
            end

            local absoluteOffset = math.abs(icon.offset)
            if absoluteOffset > width then
                local alpha = 1 - (absoluteOffset - width) / 10

                if alpha < 0 then
                    icon:Hide()
                elseif iconsScroll then
                    icon.frame:SetAlpha(alpha)
                end
            end
        end
    end

    if iconsScroll or fastSpeedDuration > 0 then
        self.buffer = self.buffer + offsetDelta
    end
end

function IconQueue:ShowCancel()
    local previousIconIndex = self.iconIndex - 1
    if previousIconIndex == 0 then
        previousIconIndex = innerIconsNumber
    end

    self.icons[previousIconIndex]:ShowCancelTexture()

    return previousIconIndex
end

---@param index number
function IconQueue:HideCancel(index)
    -- TODO: if change target between fake cancel and hide cancel, new hide cancel not done
    if self.icons[index] then
        self.icons[index]:HideCancelTexture()
    end
end

---@private
function IconQueue:ShowNextIcon()
    local nextIconIndex = table.remove(self.nextIconIndices, 1)
    self.icons[nextIconIndex]:Show()
end

function IconQueue:Clear()
    local options = TrGCDQueueOpt[self.unitIndex]

    for _, icon in ipairs(self.icons) do
        icon:Clear(options.size)
    end

    self.iconIndex = 1
    self.nextIconIndices = {}
end

function IconQueue:Resize()
    local options = TrGCDQueueOpt[self.unitIndex]
    if options.fade == "Left" or options.fade == "Right" then
        self.frame:SetWidth(options.width * options.size)
        self.frame:SetHeight(options.size)
    elseif options.fade == "Up" or options.fade == "Down" then
        self.frame:SetWidth(options.size)
        self.frame:SetHeight(options.width * options.size)
    end

    if Masque then
        TrGCDMasqueIcons:ReSkin()
    end
end

function IconQueue:UpdateOffset()
    local options = TrGCDQueueOpt[self.unitIndex]
    self.frame:ClearAllPoints()
    self.frame:SetPoint(options.point, options.x, options.y)
end

function IconQueue:ShowAnchor()
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)

    self.texture:Show()
    self.text:Show()
end

function IconQueue:HideAnchor()
    self.frame:SetMovable(false)
    self.frame:EnableMouse(false)

    self.texture:Hide()
    self.text:Hide()
end