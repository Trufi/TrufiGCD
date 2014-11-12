TrufiGCD:define('profilesWidget', function()
    local settingsModule = TrufiGCD:require('settings')
    local config = TrufiGCD:require('config')
    local utils = TrufiGCD:require('utils')

    local widget = {}

    local _idCounter = 0

    local currentProfileName = nil
    local profilesList = nil

    function getDataFromSettings()
        currentProfileName = settings:get().name
        profilesList = settings:getProfilesList()
    end

    local WidgetSimple = {}

    function WidgetSimple:new(options)
        local obj = {}

        _idCounter = _idCounter + 1

        obj.id = _idCounter

        self.__index = self

        local metatable = setmetatable(obj, self)

        metatable:create(options)

        return metatable
    end

    function WidgetSimple:create(options)
        self.frame = CreateFrame('Frame', nil, options.parentFrame, 'OptionsBoxTemplate')

        self.frameDropdownCurrent = CreateFrame('Frame', 'TrGCDProfilesWidgetDropdown' .. self.id, self.frame, 'UIDropDownMenuTemplate')
        self.frameDropdownCurrent:SetPoint('TOPLEFT', 70, -10)

        UIDropDownMenu_SetWidth(self.frameDropdownCurrent, 55)
        UIDropDownMenu_SetText(self.frameDropdownCurrent, currentProfileName)
        UIDropDownMenu_Initialize(self.frameDropdownCurrent, function() self:dropdownDirectionInit() end)


    end

    function WidgetSimple:initMenu()
        

        for i, el in pairs(config.directionsList) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = el
            info.menuList = i
            info.func = function() self:changeDropDownDirection(i) end

            if i == 1 then info.notCheckable = true end

            UIDropDownMenu_AddButton(info)
        end
    end

    return widget
end)
