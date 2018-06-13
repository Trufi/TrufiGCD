TrufiGCD:define('profileSwitcherFrame', function()
    local profileSwitcher = TrufiGCD:require('profileSwitcher')
    local settings = TrufiGCD:require('settings')
    local utils = TrufiGCD:require('utils')

    local frame = CreateFrame('Frame', nil, UIParent)
    frame.name = "profileSwitcher"

    local currentProfileName = nil
    local profilesList = nil

    local function getDataFromSettings()
        currentProfileName = settings:getName()
        profilesList = settings:getProfilesList()
    end

    getDataFromSettings()
    settings:on('change', getDataFromSettings)

    local _idCounter = 0

    local Switcher = {}

    function Switcher:new(options)
        options = options or {}

        local obj = {}

        _idCounter = _idCounter + 1

        obj.id = _idCounter

        obj.offset = options.offset or {0, 0}

        obj.desc = options.desc or ''

        obj.type = options.type or 'other'

        self.__index = self

        metatable = setmetatable(obj, self)

        metatable:create()

        return metatable
    end

    function Switcher:create()
        self.frame = CreateFrame('Frame', nil, frame)
        self.frame:SetPoint('TOPLEFT', self.offset[0], self.offset[1])

        self.frameDesc = self.frame:CreateFontString(nil, 'BACKGROUND')
        self.frameDesc:SetFont('Fonts\\FRIZQT__.TTF', 10)
        self.frameDesc:SetText(self.desc)
        self.frameDesc:SetPoint('TOP', 0, 10)



        self.frameDropdownCurrent = CreateFrame('Frame', 'TrGCDSwitcherFrameDropdown' .. self.id, self.frame, 'UIDropDownMenuTemplate')
        self.frameDropdownCurrent:SetPoint('TOPLEFT', 0, 20)

        UIDropDownMenu_SetWidth(self.frameDropdownCurrent, 200)
        UIDropDownMenu_SetText(self.frameDropdownCurrent, profileSwitcher.get(self.type))
        UIDropDownMenu_Initialize(self.frameDropdownCurrent, function() self:initMenu() end)
    end

    function Switcher:initMenu()
        local info = UIDropDownMenu_CreateInfo()

        for i, el in pairs(profilesList) do
            info.text = el
            info.menuList = i
            info.func = function() self:menuItemOnClick(el) end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info)
        end
    end

    function Switcher:menuItemOnClick(profileName)
        if profileSwitcher.get(self.type) == profileName then return end

        profileSwitcher.set(self.type, profileName)
    end

    -- local t = Switcher:new()

    frame.okay = function()
    end

    frame.cancel = function()
    end

    frame.default = function()
    end

    frame.parent = 'TrufiGCD'

    return frame
end)
