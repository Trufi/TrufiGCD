TrufiGCD:define('IconFrame', function()
    local spellTooltip = TrufiGCD:require('spellTooltip')
    local masqueHelper = TrufiGCD:require('masqueHelper')
    local utils = TrufiGCD:require('utils')

    local _idCounter = 0

    local crossTexture = 'Interface\\TargetingFrame\\UI-RaidTargetingIcon_7'

    local Icon = {}

    function Icon:new(options)
        options = options or {}

        local obj = {}

        _idCounter = _idCounter + 1
        obj.id = _idCounter

        -- parent of frame, must be unitFrame
        obj.parentFrame = options.parentFrame

        -- size of frame in pixels
        obj.size = options.size

        -- offset from start position in one direction
        obj.offset = 0
        self.direction = options.direction or 'Left'

        obj.isShow = false

        obj.isCancelTextureShow = false

        -- spell id of current icon
        obj.spellId = nil

        -- mouse onEnter callback
        obj.onEnterCallback = options.onEnterCallback or (function() end)

        -- mouse onLeave callback
        obj.onLeaveCallback = options.onLeaveCallback or (function() end)

        self.__index = self

        local metatable = setmetatable(obj, self)

        metatable:createFrame()
        metatable:updateFramePosition()

        return metatable
    end

    function Icon:createFrame()
        self.frame = CreateFrame('Button', nil, self.parentFrame)
        self.frame:Hide()
        self.frame:SetScript('OnEnter', function() self:onEnter() end)
        self.frame:SetScript('OnLeave', function() self:onLeave() end)
        --self.frame:SetPoint('LEFT', 0, 0)

        self.frame:SetWidth(self.size)
        self.frame:SetHeight(self.size)

        self.frameTexture = self.frame:CreateTexture(nil, 'BACKGROUND')
        self.frameTexture:SetAllPoints(self.frame)

        self.frameCanselTexture = self.frame:CreateTexture(nil, 'BORDER')
        self.frameCanselTexture:SetAllPoints(self.frame)
        self.frameCanselTexture:SetTexture(crossTexture)
        --self.frameCanselTexture:SetAlpha(1)
        self.frameCanselTexture:Hide()

        masqueHelper:addIcon(self.frame, self.frameTexture)
    end

    function Icon:onEnter()
        spellTooltip:show(self.spellId, self.frame)
        self:onEnterCallback()
    end

    function Icon:onLeave()
        spellTooltip:hide()
        self:onLeaveCallback()
    end

    function Icon:show(options)
        self.frame:Show()
        self.frame:SetAlpha(options.alpha or 1)
        self.isShow = true
        self.frameCanselTexture:Hide()
        self.isCancelTextureShow = false
    end

    function Icon:hide()
        self.frame:Hide()
        self.isShow = false
    end

    function Icon:setSize(size)
        self.size = size
        self.frame:SetWidth(size)
        self.frame:SetHeight(size)
    end

    function Icon:updateFramePosition()
        if self.direction == 'Left' then
            self.frame:SetPoint('RIGHT', -self.offset, 0)
        elseif self.direction == 'Right' then
            self.frame:SetPoint('LEFT', self.offset, 0)
        elseif self.direction == 'Up' then
            self.frame:SetPoint('BOTTOM', 0, -self.offset)
        else
            self.frame:SetPoint('TOP', 0, self.offset)
        end
    end

    function Icon:setDirection(str)
        self.direction = str
        self.frame:ClearAllPoints()
        self:updateFramePosition()
    end

    function Icon:setOffset(val)
        self.offset = val
        self:updateFramePosition()
    end

    function Icon:getOffset()
        return self.offset
    end

    function Icon:changeOffset(val)
        self.offset = self.offset + val
        self:updateFramePosition()
    end

    function Icon:showCanselTexture()
        self.frameCanselTexture:Show()
        self.isCancelTextureShow = true
    end

    function Icon:hideCanselTexture()
        self.frameCanselTexture:Hide()
        self.isCancelTextureShow = false
    end

    function Icon:setSpell(id, texture)
        self.spellId = id
        self.frameTexture:SetTexture(texture)
    end

    function Icon:setAlpha(val)
        self.frame:SetAlpha(val)
    end

    function Icon:getId()
        return self.id
    end

    function Icon:getState()
        return {
            offset = self.offset,
            isShow = self.isShow,
            isCancelTextureShow = self.isCancelTextureShow,
            spellId = self.spellId,
            texture = self.frameTexture:GetTexture()
        }
    end

    function Icon:setState(state)
        self.isShow = state.isShow

        self:setOffset(state.offset)

        if self.isShow then
            self.frame:Show()
            self.frame:SetAlpha(1)
        else
            self.frame:Hide()
        end

        self.isCancelTextureShow = state.isCancelTextureShow

        if self.isCancelTextureShow then
            self:showCanselTexture()
        else
            self:hideCanselTexture()
        end

        self.frameTexture:SetTexture(state.texture)
    end

    return Icon
end)
