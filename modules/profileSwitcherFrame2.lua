TrufiGCD:define('profileSwitcherFrame2', function()
    local settings = TrufiGCD:require('settings')
    local utils = TrufiGCD:require('utils')
    local profileSwitcher = TrufiGCD:require('profileSwitcher')

    local settingsWidth = 600

    local frame = CreateFrame('Frame', nil, UIParent, 'OptionsBoxTemplate')
    frame.name = 'profileSwitcher2'
    frame.parent = 'TrufiGCD'

    frame.okay = function()
    end

    frame.cancel = function()
    end

    frame.default = function()
    end

    local buttonAddRule =  CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
    buttonAddRule:SetWidth(100)
    buttonAddRule:SetHeight(22)
    buttonAddRule:SetPoint('TOP', 5, -30)
    buttonAddRule:SetText('Add rule')
    buttonAddRule:SetScript('OnClick', function()  end)

    local frameRules = CreateFrame('Frame', nil, frame)
    frameRules:SetPoint('TOPLEFT', 0, -70)
    frameRules:SetWidth(500)
    frameRules:SetHeight(500)

    local currentProfileName = nil
    local profilesList = nil

    local function getDataFromSettings()
        currentProfileName = settings:getName()
        profilesList = settings:getProfilesList()
    end

    getDataFromSettings()
    settings:on('change', getDataFromSettings)

    local _idCounter = 0
    local rules = profileSwitcher.getRules()
    local framesRules = {}

    local FrameRule = {}

    function FrameRule:new(rule, options)
        options = options or {}        

        local obj = {}

        _idCounter = _idCounter + 1

        obj.rule = rule

        obj.offset = options.offset or {0, 0}

        self.__index = self

        metatable = setmetatable(obj, self)

        metatable:create()

        return metatable
    end

    function FrameRule:create()
        self.frame = CreateFrame('Frame', nil, frameRules)
        self.frame:SetPoint('TOPLEFT', self.offset[1], self.offset[2])
        self.frame:SetWidth(settingsWidth)
        self.frame:SetHeight(30)

        -- local buttonAddRule =  CreateFrame('Button', nil, self.frame, 'UIPanelButtonTemplate')
        -- buttonAddRule:SetWidth(100)
        -- buttonAddRule:SetHeight(22)
        -- buttonAddRule:SetPoint('TOP', 30, 30)
        -- buttonAddRule:SetText('123')

        self.frameDropdownCurrent = CreateFrame('Frame', 'TrGCDFrameRuleFrameDropdown' .. self.rule.id, self.frame, 'UIDropDownMenuTemplate')
        self.frameDropdownCurrent:SetPoint('TOPLEFT', 0, 0)

        UIDropDownMenu_SetWidth(self.frameDropdownCurrent, 200)
        UIDropDownMenu_SetText(self.frameDropdownCurrent, self.rule:getProfileName())
        UIDropDownMenu_Initialize(self.frameDropdownCurrent, function() self:initMenu() end)
    end

    function FrameRule:initMenu()
        local info = UIDropDownMenu_CreateInfo()

        for i, el in pairs(profilesList) do
            info.text = el
            info.menuList = i
            info.func = function() self:menuItemOnClick(el) end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info)
        end
    end

    function FrameRule:menuItemOnClick(profileName)
        if currentProfileName == profileName then return end


    end

    for id, rule in pairs(rules) do
        framesRules[id] = FrameRule:new(rule)
    end

    -- TODO: убрать потом
    TrGCDGUITESTPAN = frame
    -- /run InterfaceOptionsFrame_OpenToCategory(TrGCDGUITESTPAN)

    return frame
end)
