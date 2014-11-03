TrufiGCD:define('UnitFrame', function()
    local utils = TrufiGCD:require('utils')
    local IconFrame = TrufiGCD:require('IconFrame')
    local masqueHelper = TrufiGCD:require('masqueHelper')

    local timeGcd = 1.6
    local fastSpeedModificator = 3

    local _idCounter = 0

    local getUniqId = function()
        _idCounter = _idCounter + 1
        return _idCounter
    end

    local UnitFrame = {}

    function UnitFrame:new(options)
        options = options or {}

        local obj = {}
        obj.id = getUniqId()

        -- capacity elements in frame
        obj.numberIcons = options.numberIcons or 3

        -- size of icons frames in pixels
        obj.sizeIcons = options.sizeIcons or 30

        obj.longSize = obj.numberIcons * obj.sizeIcons

        -- direction of fade icons
        obj.direction = options.direction or 'Left'

        -- position relative from parent
        obj.position = options.position or 'CENTER'

        -- offset in pixels
        obj.offset = options.offset or {0, 0}

        -- true if mouse is over icon, need to stoping moving (if this option is enable)
        obj.stopMovingMouseOverIcon = options.stopMovingMouseOverIcon or true

        obj.isMoving = true

        -- text which show in background
        obj.text = options.text or 'None'

        -- count of next used icon
        obj.indexIcon = 1

        obj.speed = timeGcd / 1.6

        obj.iconsStack = {}

        -- buffer in px between last icon and start position
        obj.buffer = 0

        self.__index = self

        local metatable = setmetatable(obj, self)

        metatable:createFrame()
        metatable:createIcons()
        metatable:updateSize()

        return metatable
    end

    function UnitFrame:createFrame()
        self.frame = CreateFrame('Frame', nil, UIParent)
        self.frame:RegisterForDrag('LeftButton')
        self.frame:SetPoint(self.position, self.offset[1], self.offset[2])

        self.frame:SetScript('OnDragStart', self.onDragStart)
        self.frame:SetScript('OnDragStop', self.nDragStop)

        self.frameTexture = self.frame:CreateTexture(nil, 'BACKGROUND')
        self.frameTexture:SetAllPoints(self.frame)
        self.frameTexture:SetTexture(0, 0, 0)
        self.frameTexture:Hide()
        --self.frameTexture:SetAlpha(0)

        self.frameText = self.frame:CreateFontString(nil, 'BACKGROUND')
        self.frameText:SetFont('Fonts\\FRIZQT__.TTF', 9)
        self.frameText:SetText(self.text)
        self.frameText:SetAllPoints(self.frame)
        self.frameText:SetAlpha(0)
    end

    function UnitFrame:createIcons()
        local i

        self.iconsFrames = {}

        for i = 1, self.numberIcons + 1 do
            self.iconsFrames[i] = IconFrame:new({
                parentFrame = self.frame,
                size = self.sizeIcons,
                onEnterCallback = self.mouseOverIcon,
                onLeaveCallback = self.mouseLeaveIcon
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

    function UnitFrame:changeOptions(options)
        options = options or {}

        if options.direction or options.sizeIcons or options.numberIcons then
            self.direction = options.direction or self.direction
            self.sizeIcons = options.sizeIcons or self.sizeIcons
            self.numberIcons = options.numberIcons or self.numberIcons

            self:updateSize()
            self:updateIcons()
        end

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
        table.foreach(self.iconsFrames, function(i, el)
            el:setSize(self.sizeIcons)
            el:setDirection(self.direction)
        end)

        masqueHelper:reskinIcons()
    end

    function UnitFrame:addSpell(spellId, spellIcon)
        table.insert(self.iconsStack, {id = spellId, icon = spellIcon})
    end

    function UnitFrame:showIcon()
        self.indexIcon = (self.indexIcon + 1) % (self.numberIcons + 1) + 1

        local icon = self.iconsFrames[self.indexIcon]
        icon:setOffset(0)
        icon:setSpell(self.iconsStack[1].id, self.iconsStack[1].icon)
        icon:show()

        table.remove(self.iconsStack, 1)
    end

    function UnitFrame:showCansel(spellId)
        self.iconsFrames[self.indexIcon]:showCanselTexture()
        return self.indexIcon
    end

    function UnitFrame:hideCansel(index)
        self.iconsFrames[index]:hideCanselTexture()
    end

    function UnitFrame:update(time)
        local buffer = math.min(self.iconsFrames[self.indexIcon]:getOffset(), self.sizeIcons)
        local lastIconIsShow = self.iconsFrames[self.indexIcon].isShow
        local fastSpeed = self.speed * fastSpeedModificator * (#self.iconsStack + 1)
        local offset
        local fastSpeedDuration

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

        if #self.iconsStack > 0 and (buffer >= self.sizeIcons or not lastIconIsShow) then
            self:showIcon()
        end

        table.foreach(self.iconsFrames, function(i, el)
            if not el.isShow then return end

            local currentOffset = el:getOffset() + offset

            el:setOffset(currentOffset)

            local dist = currentOffset - self.longSize + self.sizeIcons

            if dist > 0 then
                local alpha = 1 - dist / self.sizeIcons
                if alpha > 0 then
                    el:setAlpha(alpha)
                else
                    el:hide()
                end
            end
        end)
    end

    return UnitFrame
end)
