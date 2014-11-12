TrufiGCD:define('profilesWidget', function()
    local settingsModule = TrufiGCD:require('settings')
    local config = TrufiGCD:require('config')
    local utils = TrufiGCD:require('utils')

    local widget = {}

    local _idCounter = 0

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
        UIDropDownMenu_SetText(self.frameDropdownCurrent, unitSettings[obj.name].direction)
        UIDropDownMenu_Initialize(self.frameDropdownCurrent, function() self:dropdownDirectionInit() end)
    end

    return widget
end)
