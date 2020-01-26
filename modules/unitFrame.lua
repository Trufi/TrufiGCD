TrufiGCD:define('UnitFrame', function()
    local masqueHelper = TrufiGCD:require('masqueHelper')
    local IconFrame = TrufiGCD:require('IconFrame')
    local config = TrufiGCD:require('config')
    local utils = TrufiGCD:require('utils')

    local timeGcd = config.timeGcd
    local fastSpeedModificator = config.fastSpeedModificator

    local _idCounter = 0

    local UnitFrame = {}

    function UnitFrame:new(settings, generalSettings, options)
        settings = settings or {}
        options = options or {}

        local obj = {}

        _idCounter = _idCounter + 1
        obj.id = _idCounter

        -- capacity elements in frame
        obj.numberIcons = settings.numberIcons or 3

        -- size of icons frames in pixels
        obj.sizeIcons = settings.sizeIcons or 30

        obj.longSize = obj.numberIcons * obj.sizeIcons

        -- direction of fade icons
        obj.direction = settings.direction or 'Left'

        -- position relative from parent
        obj.point = settings.point or 'CENTER'

        -- offset in pixels
        obj.offset = settings.offset or {0, 0}

        -- true if mouse is over icon, need to stoping moving (if this option is enable)
        obj.stopMovingMouseOverIcon = generalSettings.stopMove

        obj.isMoving = true

        -- text which show in background
        obj.text = settings.text or 'None'

        -- count of next used icon
        obj.indexIcon = obj.numberIcons + 1

        obj.transparencyIcons = settings.transparencyIcons or 1

        obj.speed = timeGcd / 1.6

        obj.iconsStack = {}

        -- stop move frame callback
        obj.onDragStop = options.onDragStop or (function() end)

        self.__index = self

        local metatable = setmetatable(obj, self)

        metatable:createFrame()
        metatable:createIcons()
        metatable:updateIcons()
        metatable:updateSize()

        return metatable
    end

    function UnitFrame:createFrame()
        self.frame = CreateFrame('Frame', nil, UIParent)
        self.frame:RegisterForDrag('LeftButton')
        self.frame:SetPoint(self.point, self.offset[1], self.offset[2])

        self.frame:SetScript('OnDragStart', self.frame.StartMoving)
        self.frame:SetScript('OnDragStop', function(...)
            self.frame.StopMovingOrSizing(...)
            self.onDragStop()
        end)

        self.frameTexture = self.frame:CreateTexture(nil, 'BACKGROUND')
        self.frameTexture:SetAllPoints(self.frame)
        self.frameTexture:SetColorTexture(0, 0, 0)
        self.frameTexture:Hide()
        self.frameTexture:SetAlpha(0.6)

        self.frameText = self.frame:CreateFontString(nil, 'BACKGROUND')
        self.frameText:SetFont(STANDARD_TEXT_FONT, 9)
        self.frameText:SetText(self.text)
        self.frameText:SetAllPoints(self.frame)
        self.frameText:SetAlpha(0.6)
        self.frameText:Hide()
    end

    function UnitFrame:createIcons()
        self.iconsFrames = {}

        for i = 1, self.numberIcons + 1 do
            self.iconsFrames[i] = IconFrame:new({
                parentFrame = self.frame,
                size = self.sizeIcons,
                onEnterCallback = function() self:mouseOverIcon() end,
                onLeaveCallback = function() self:mouseLeaveIcon() end
            })
        end
    end

    function UnitFrame:mouseOverIcon()
        if self.stopMovingMouseOverIcon then
            self.isMoving = false
        end
    end

    function UnitFrame:mouseLeaveIcon()
        if self.stopMovingMouseOverIcon then
            self.isMoving = true
        end
    end

    function UnitFrame:startMoving()
        self.isMoving = true
    end

    function UnitFrame:stopMoving()
        self.isMoving = false
    end

    function UnitFrame:changeOptions(options, generalSettings)
        options = options or {}

        self.point = options.point or self.point

        self.offset = options.offset or self.offset

        self.stopMovingMouseOverIcon = generalSettings.stopMove

        self.text = options.text or self.text

        self.transparencyIcons = options.transparencyIcons or self.transparencyIcons

        if options.direction or options.sizeIcons or options.numberIcons then
            self.direction = options.direction or self.direction
            self.sizeIcons = options.sizeIcons or self.sizeIcons
            self.numberIcons = options.numberIcons or self.numberIcons
            self.longSize = self.numberIcons * self.sizeIcons

            self:updateSize()
            self:updateOffset()
            self:updateIcons()
        end

    end

    function UnitFrame:updateOffset()
        self.frame:ClearAllPoints()
        self.frame:SetPoint(self.point, self.offset[1], self.offset[2])
    end

    function UnitFrame:updateSize()
        self.longSize = self.numberIcons * self.sizeIcons

        if self.direction == 'Left' or self.direction == 'Right' then
            self.frame:SetWidth(self.longSize)
            self.frame:SetHeight(self.sizeIcons)
        else
            self.frame:SetWidth(self.sizeIcons)
            self.frame:SetHeight(self.longSize)
        end

        --self.frameTexture:SetAllPoints(self.frame)
        self:updateSpeed()
    end

    function UnitFrame:updateSpeed()
        self.speed = self.sizeIcons / timeGcd
    end

    function UnitFrame:updateIcons()
        for i, el in pairs(self.iconsFrames) do
            el:setSize(self.sizeIcons)
            el:setDirection(self.direction)
            el:setAlpha(self.transparencyIcons)
        end

        if self.numberIcons > #self.iconsFrames then
            for i = #self.iconsFrames, self.numberIcons + 1 do
                self.iconsFrames[i] = IconFrame:new({
                    parentFrame = self.frame,
                    size = self.sizeIcons,
                    onEnterCallback = function() self:mouseOverIcon() end,
                    onLeaveCallback = function() self:mouseLeaveIcon() end
                })
            end
        end

        masqueHelper:reskinIcons()
    end

    function UnitFrame:addSpell(spellId, spellIcon)
        table.insert(self.iconsStack, {id = spellId, icon = spellIcon})
    end

    function UnitFrame:showIcon()
        self.indexIcon = self.indexIcon % (self.numberIcons + 1) + 1

        local icon = self.iconsFrames[self.indexIcon]
        icon:setOffset(0)
        icon:setSpell(self.iconsStack[1].id, self.iconsStack[1].icon)
        icon:show({alpha = self.transparencyIcons})

        table.remove(self.iconsStack, 1)
    end

    function UnitFrame:showCansel(spellId)
        self.iconsFrames[self.indexIcon]:showCanselTexture()
        return self.indexIcon
    end

    function UnitFrame:hideCansel(index)
        -- TODO: if change target between fake cansel and hide cansel, new hide cansel not done
        if self.iconsFrames[index] then
            self.iconsFrames[index]:hideCanselTexture()
        end
    end

    function UnitFrame:update(time)
        local lastIconOffset = self.iconsFrames[self.indexIcon].isShow and self.iconsFrames[self.indexIcon]:getOffset() or self.sizeIcons
        local buffer = math.min(self.iconsFrames[self.indexIcon]:getOffset(), self.sizeIcons)
        local fastSpeed = self.speed * fastSpeedModificator * (#self.iconsStack + 1)
        local offset = nil
        local fastSpeedDuration = nil

        if #self.iconsStack > 0 then
            fastSpeedDuration = math.min((self.sizeIcons - buffer) / fastSpeed, time)
        else
            fastSpeedDuration = 0
        end

        if self.isMoving then
            offset = (time - fastSpeedDuration) * self.speed + fastSpeedDuration * fastSpeed
        else
            offset = fastSpeedDuration * fastSpeed
        end

        if #self.iconsStack > 0 and (buffer >= self.sizeIcons or not self.iconsFrames[self.indexIcon].isShow) then
            self:showIcon()
        end

        for i, el in pairs(self.iconsFrames) do
            if el.isShow then
                local currentOffset = el:getOffset() + offset

                el:setOffset(currentOffset)

                local dist = currentOffset - self.longSize + self.sizeIcons

                if dist > 0 then
                    local alpha = self.transparencyIcons - dist / self.sizeIcons
                    if alpha > 0 then
                        el:setAlpha(alpha)
                    else
                        el:hide()
                    end
                end
            end
        end
    end

    function UnitFrame:getState()
        local state = {
            isMoving = self.isMoving,
            indexIcon = self.indexIcon,
            iconsStack = utils.clone(self.iconsStack),
            icons = {}
        }

        for i, el in pairs(self.iconsFrames) do
            state.icons[i] = el:getState()
        end

        return state
    end

    function UnitFrame:setState(state)
        self.isMoving = state.isMoving
        self.iconsStack = state.iconsStack

        local stateIconsLength = #state.icons
        local index = state.indexIcon + 1

        -- convert state icons to self icons with a different length
        for i = self.numberIcons + 1, 1, -1 do
            if state.icons[i] then
                -- get previous icon index
                index = index - 1 + stateIconsLength
                -- division with remainder for lua array index
                index = (index - 1) % stateIconsLength + 1

                self.iconsFrames[i]:setState(state.icons[index])
            else
                break
            end
        end

        self.indexIcon = self.numberIcons + 1

        self:update(0)
    end

    function UnitFrame:clear()
        self.isMoving = true
        self.iconsStack = {}
        self.indexIcon = self.numberIcons + 1

        for i, el in pairs(self.iconsFrames) do
            el:hide()
        end
    end

    function UnitFrame:showAnchor()
        self.frame:SetMovable(true)
        self.frame:EnableMouse(true)

        self.frameTexture:Show()
        self.frameText:Show()
    end

    function UnitFrame:hideAnchor()
        self.frame:SetMovable(false)
        self.frame:EnableMouse(false)

        self.frameTexture:Hide()
        self.frameText:Hide()
    end

    function UnitFrame:getPoint()
        local point, _, _, ofsX, ofsY = self.frame:GetPoint()
        return point, ofsX, ofsY
    end

    function UnitFrame:hide()
        self.frame:Hide()
    end

    function UnitFrame:show()
        self.frame:Show()
    end

    return UnitFrame
end)
