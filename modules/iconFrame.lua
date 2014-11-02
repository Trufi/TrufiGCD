TrufiGCD:define('iconFrame', function()
    local utils = TrufiGCD:require('utils')
    local spellTooltip = TrufiGCD:require('spellTooltip')

    local _idCounter = 0;

    local getUniqId = function()
        _idCounter = _idCounter + 1
        return _idCounter
    end

    local crossTexture = 'Interface\\TargetingFrame\\UI-RaidTargetingIcon_7'

    local Icon = {}

    function Icon:new(options)
        options = options or {}

        local obj = {}
        obj.id = getUniqId()

        -- parent of frame, must be unitFrame
        obj.parentFrame = options.parentFrame

        -- size of frame in pixels
        obj.size = options.size

        -- offset from start position at one direction
        obj.offset = 0

        obj.isShow = false

        obj.isCancelTextureShow = false

        -- time when moving started
        obj.startTime = 0

        -- spell id of current icon
        obj.spellId = nil

        -- mouse onEnter callback
        obj.onEnterCallback = options.onEnterCallback or (function() end)

        -- mouse onLeave callback
        obj.onLeaveCallback = options.onLeaveCallback or (function() end)

        self.__index = self

        local metatable = setmetatable(obj, self)

        metatable:createFrame()

        return metatable
    end

    function Icon:createFrame()
        self.frame = createFrame('Button', nil, self.parentFrame)
        self.frame:Hide()
        self.frame:SetScript('OnEnter', self.onEnter)
        self.frame:SetScript('OnLeave', self.onLeave)

        self.frame:SetWidth(self.size)
        self.frame:SetHeight(self.size)

        self.frameTexture = self.frame:CreateTexture(nil, 'BACKGROUND')
        self.frameTexture:SetAllPoints(self.frame)

        self.frameCanselTexture = self.frame:CreateTexture(nil, 'BORDER')
        self.frameCanselTexture:SetTexture(crossTexture)
        --self.frameCanselTexture:SetAlpha(1)
        self.frameCanselTexture:Hide()

        if Masque then
            TrGCDMasqueIcons:AddButton(self.frame, {Icon = self.frameTexture})
        end
    end

    function Icon:onEnter()
        spellTooltip:show(self.spellId, self.frame)
        obj.onEnterCallback()
    end

    function Icon:onLeave()
        spellTooltip:hide()
        obj.onLeaveCallback()
    end

    function Icon:show()
        self.frame:Show()
        self.isShow = true
    end

    function Icon:hide()
        self.frame:Hide()
        self.isShow = false
    end

    function Icon:setSize(size)
        self.size = size
    end

    function Icon:setOffset(value)
        self.offset = value
    end

    function Icon:showCanselTexture()
        self.frameCanselTexture:Show()
    end

    function Icon:hideCanselTexture()
        self.frameCanselTexture:Hide()
    end

    function Icon:setSpell(id)
        self.spellId = id
    end

    return Icon
end)
