TrufiGCD:define('unitFrame', function()
    local utils = TrufiGCD:require('utils')
    local iconFrame = TrufiGCD:require('iconFrame')

    local _idCounter = 0;

    local getUniqId = function()
        _idCounter = _idCounter + 1
        return _idCounter
    end

    local Unit = {}

    function Unit:new(options)
        options = options or {}

        local obj = {}
        obj.id = getUniqId()

        -- capacity elements in frame
        obj.numberIcons = options.numberIcons or 3

        -- size of icons frames in pixels
        obj.sizeIcons = options.sizeIcons or 30

        -- direction of fade icons
        obj.direct = 'left'

        -- position relative from parent
        obj.position = 'CENTER'

        -- offset in pixels
        obj.offset = {0, 0}

        -- true if mouse is over icon, need to stoping moving (if this option is enable)
        obj.isMouseOverIcon = false

        self.__index = self
        return setmetatable(obj, self)
    end

    function Unit:createFrame()
        self.frame = CreateFrame('Frame', nil, UIParent)
        self.frame:RegisterForDrag('LeftButton')
        self.frame:SetPoint(self.position, self.offset[1], self.offset[2])

        self.frame:SetScript('OnDragStart', self.onDragStart)
        self.frame:SetScript('OnDragStop', self.nDragStop)

        self.frameTexture = self.frame:CreateTexture(nil, 'BACKGROUND')
        self.frameTexture:SetAllPoints(self.frame)
        self.frameTexture:SetTexture(0, 0, 0)
        self.frameTexture:SetAlpha(0)

        self.frameText = self.frame:CreateFontString(nil, 'BACKGROUND')
        self.frameText:SetFont('Fonts\\FRIZQT__.TTF', 9)
        self.frameText:SetText(TrGCDQueueOpt[i].text)
        self.frameText:SetAllPoints(self.frame)
        self.frameText:SetAlpha(0)
    end

    function Unit:createIcons()
        local i;

        self.iconsFrames = {}

        for i = 1, self.numberIcons + 1 do
            self.iconsFrames[i] = iconFrame:new({
                parentFrame = self.frame,
                size = self.sizeIcons,
                onEnterCallback = self.mouseOverIcon,
                onLeaveCallback = self.mouseLeaveIcon
            })
        end
    end

    function Unit:mouseOverIcon()
        self.isMouseOverIcon = true
    end

    function Unit:mouseLeaveIcon()
        self.isMouseOverIcon = false
    end

    return Unit
end)
