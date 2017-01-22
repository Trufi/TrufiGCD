TrufiGCD:define('profileSwitcherFrame2', function()
    local settings = TrufiGCD:require('settings')
    local utils = TrufiGCD:require('utils')
    local profileSwitcher = TrufiGCD:require('profileSwitcher')
    local config = TrufiGCD:require('config')

    local places = config.places
    local specs = config.specs

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

    local function addRule()
        profileSwitcher:createRule()
    end

    local buttonAddRule =  CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
    buttonAddRule:SetWidth(100)
    buttonAddRule:SetHeight(22)
    buttonAddRule:SetPoint('TOPLEFT', 10, -30)
    buttonAddRule:SetText('Add rule')
    buttonAddRule:SetScript('OnClick', addRule)

    local frameRules = CreateFrame('Frame', nil, frame)
    frameRules:SetPoint('TOPLEFT', 10, -100)
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

        self.buttonRemove =  CreateFrame('Button', nil, self.frame, 'UIPanelButtonTemplate')
        self.buttonRemove:SetWidth(25)
        self.buttonRemove:SetHeight(22)
        self.buttonRemove:SetPoint('TOPLEFT', 0, -2)
        self.buttonRemove:SetText('X')
        self.buttonRemove:SetScript('OnClick', function() self:onRemove() end)

        self.dropdownProfile = CreateFrame('Frame', 'TrGCDFrameRuleDropdownProfile' .. self.rule.id, self.frame, 'UIDropDownMenuTemplate')
        self.dropdownProfile:SetPoint('TOPLEFT', 15, 0)

        UIDropDownMenu_SetWidth(self.dropdownProfile, 100)
        UIDropDownMenu_SetText(self.dropdownProfile, self.rule.profileName)
        UIDropDownMenu_Initialize(self.dropdownProfile, function() self:initMenu() end)

        self.specCheckboxes = {}
        local specOffsetX = 160
        self.specCheckboxes[1] = self:createCheckbox('spec1', self.rule.specConditions[1], {specOffsetX, 0}, function() self:specOnClick(1) end)
        self.specCheckboxes[2] = self:createCheckbox('spec2', self.rule.specConditions[2], {specOffsetX + 30, 0}, function() self:specOnClick(2) end)
        self.specCheckboxes[3] = self:createCheckbox('spec3', self.rule.specConditions[3], {specOffsetX + 60, 0}, function() self:specOnClick(3) end)
        self.specCheckboxes[4] = self:createCheckbox('spec4', self.rule.specConditions[4], {specOffsetX + 90, 0}, function() self:specOnClick(4) end)

        self.placeCheckboxes = {}
        local placeOffsetX = 300

        self.placeCheckboxes[places.WORLD] = self:createCheckbox('place1', self.rule.placeConditions[places.WORLD],
            {placeOffsetX, 0}, function() self:placeOnClick(places.WORLD) end)

        self.placeCheckboxes[places.PARTY] = self:createCheckbox('place2', self.rule.placeConditions[places.PARTY],
            {placeOffsetX + 30, 0}, function() self:placeOnClick(places.PARTY) end)

        self.placeCheckboxes[places.RAID] = self:createCheckbox('place3', self.rule.placeConditions[places.RAID],
            {placeOffsetX + 60, 0}, function() self:placeOnClick(places.RAID) end)

        self.placeCheckboxes[places.ARENA] = self:createCheckbox('place4', self.rule.placeConditions[places.ARENA],
            {placeOffsetX + 90, 0}, function() self:placeOnClick(places.ARENA) end)

        self.placeCheckboxes[places.BATTLEGROUND] = self:createCheckbox('place5',
            self.rule.placeConditions[places.BATTLEGROUND],
            {placeOffsetX + 120, 0},
            function() self:placeOnClick(places.BATTLEGROUND) end)
    end

    function FrameRule:createCheckbox(id, checked, offset, onClick)
        local checkbox = CreateFrame('CheckButton', 'TrGCDFrameRuleChbox' .. id, self.frame, 'UICheckButtonTemplate')
        checkbox:SetPoint('TOPLEFT', offset[1], offset[2])
        checkbox:SetWidth(25)
        checkbox:SetHeight(25)
        checkbox:SetChecked(checked)
        checkbox:SetScript('OnClick', onClick)
        return checkbox
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

    function FrameRule:onRemove()
        
    end

    function FrameRule:specOnClick(id)
        utils.log(id)
    end

    function FrameRule:placeOnClick(id)
        utils.log(id)
    end

    for id, rule in pairs(rules) do
        framesRules[id] = FrameRule:new(rule)
    end

    -- TODO: убрать потом
    TrGCDGUITESTPAN = frame
    -- /run InterfaceOptionsFrame_OpenToCategory(TrGCDGUITESTPAN)

    return frame
end)
