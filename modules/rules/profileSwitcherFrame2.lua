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
        profileSwitcher:save()
    end

    frame.cancel = function()
        profileSwitcher:load()
    end

    frame.default = function()
        profileSwitcher:default()
    end

    local function addRule()
        profileSwitcher:createRule()
    end

    local buttonAddRule = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
    buttonAddRule:SetWidth(100)
    buttonAddRule:SetHeight(22)
    buttonAddRule:SetPoint('TOPLEFT', 10, -30)
    buttonAddRule:SetText('Add rule')
    buttonAddRule:SetScript('OnClick', addRule)

    local frameRules = CreateFrame('Frame', nil, frame)
    frameRules:SetPoint('TOPLEFT', 10, -100)
    frameRules:SetWidth(500)
    frameRules:SetHeight(500)

    local profilesList = nil

    local function getDataFromSettings()
        profilesList = settings:getProfilesList()
    end

    getDataFromSettings()
    settings:on('change', getDataFromSettings)

    local framesRules = {}

    local FrameRule = {}

    function FrameRule:new(rule, positionIndex)
        local obj = {}
        obj.rule = rule
        obj.positionIndex = positionIndex

        self.__index = self

        metatable = setmetatable(obj, self)

        metatable:create()

        return metatable
    end

    function FrameRule:create()
        self.frame = CreateFrame('Frame', nil, frameRules)
        self.frame:SetPoint('TOPLEFT', 0, -self.positionIndex * 40)
        self.frame:SetWidth(settingsWidth)
        self.frame:SetHeight(30)

        self.buttonRemove = CreateFrame('Button', nil, self.frame, 'UIPanelButtonTemplate')
        self.buttonRemove:SetWidth(25)
        self.buttonRemove:SetHeight(22)
        self.buttonRemove:SetPoint('TOPLEFT', 0, -2)
        self.buttonRemove:SetText('X')
        self.buttonRemove:SetScript('OnClick', function() self:onRemove() end)

        self.dropdownProfile = CreateFrame('Frame', 'TrGCDFrameRuleDropdownProfile' .. self.rule.id, self.frame, 'UIDropDownMenuTemplate')
        self.dropdownProfile:SetPoint('TOPLEFT', 10, 0)

        UIDropDownMenu_SetWidth(self.dropdownProfile, 100)
        UIDropDownMenu_SetText(self.dropdownProfile, profilesList[self.rule.profileId].name)
        UIDropDownMenu_Initialize(self.dropdownProfile, function() self:initMenu() end)

        local marginBetween = 50
        local offsetX = 155

        self.specCheckboxes = {}

        self.specCheckboxes[1] = self:createCheckbox('spec1' .. self.rule.id, self.rule.specConditions['1'], {offsetX, 0}, function() self:specOnClick('1') end)
        offsetX = offsetX + marginBetween
        self.specCheckboxes[2] = self:createCheckbox('spec2' .. self.rule.id, self.rule.specConditions['2'], {offsetX, 0}, function() self:specOnClick('2') end)
        offsetX = offsetX + marginBetween
        self.specCheckboxes[3] = self:createCheckbox('spec3' .. self.rule.id, self.rule.specConditions['3'], {offsetX, 0}, function() self:specOnClick('3') end)
        offsetX = offsetX + marginBetween
        self.specCheckboxes[4] = self:createCheckbox('spec4' .. self.rule.id, self.rule.specConditions['4'], {offsetX, 0}, function() self:specOnClick('4') end)

        offsetX = offsetX + 70
        self.placeCheckboxes = {}

        self.placeCheckboxes[places.WORLD] = self:createCheckbox('place1' .. self.rule.id, self.rule.placeConditions[places.WORLD],
            {offsetX, 0}, function() self:placeOnClick(places.WORLD) end)
        offsetX = offsetX + marginBetween

        self.placeCheckboxes[places.PARTY] = self:createCheckbox('place2' .. self.rule.id, self.rule.placeConditions[places.PARTY],
            {offsetX, 0}, function() self:placeOnClick(places.PARTY) end)
        offsetX = offsetX + marginBetween

        self.placeCheckboxes[places.RAID] = self:createCheckbox('place3' .. self.rule.id, self.rule.placeConditions[places.RAID],
            {offsetX, 0}, function() self:placeOnClick(places.RAID) end)
        offsetX = offsetX + marginBetween

        self.placeCheckboxes[places.ARENA] = self:createCheckbox('place4' .. self.rule.id, self.rule.placeConditions[places.ARENA],
            {offsetX, 0}, function() self:placeOnClick(places.ARENA) end)
        offsetX = offsetX + marginBetween

        self.placeCheckboxes[places.BATTLEGROUND] = self:createCheckbox('place5' .. self.rule.id,
            self.rule.placeConditions[places.BATTLEGROUND],
            {offsetX, 0},
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
            info.text = el.name
            info.menuList = i
            info.func = function() self:menuItemOnClick(el) end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info)
        end
    end

    function FrameRule:menuItemOnClick(profile)
        self.rule:changeProfile(profile.id)
        UIDropDownMenu_SetText(self.dropdownProfile, profile.name)
    end

    function FrameRule:onRemove()
        self.rule:remove()
    end

    function FrameRule:specOnClick(id)
        self.rule:toggleSpec(id)
    end

    function FrameRule:placeOnClick(id)
        self.rule:togglePlace(id)
    end

    function FrameRule:clear(id)
        self.frame:ClearAllPoints()
        self.frame:Hide()
    end

    function FrameRule:update(positionIndex)
        self.positionIndex = positionIndex
        self.frame:Show()
        self.frame:SetPoint('TOPLEFT', 0, -self.positionIndex * 40)
    end

    local function createUpperOneText(parentFrame, text, ofsX, ofsY)
        local frame = parentFrame:CreateFontString(nil, 'BACKGROUND')
        frame:SetFont('Fonts\\FRIZQT__.TTF', 11)
        frame:SetText(text)
        frame:SetPoint('TOPLEFT', ofsX, ofsY)
        frame:SetJustifyH('MIDDLE')
        frame:SetSize(50, 20)
    end

    local offsetY = 27
    local offsetX = 142
    local margin = 50

    createUpperOneText(frameRules, 'Profile', 40, offsetY)

    createUpperOneText(frameRules, 'Spec 1', offsetX, offsetY)
    offsetX = offsetX + margin

    createUpperOneText(frameRules, 'Spec 2', offsetX, offsetY)
    offsetX = offsetX + margin

    createUpperOneText(frameRules, 'Spec 3', offsetX, offsetY)
    offsetX = offsetX + margin

    createUpperOneText(frameRules, 'Spec 4', offsetX, offsetY)
    offsetX = offsetX + 70

    createUpperOneText(frameRules, config.placeText.WORLD, offsetX, offsetY)
    offsetX = offsetX + margin

    createUpperOneText(frameRules, config.placeText.PARTY, offsetX, offsetY)
    offsetX = offsetX + margin

    createUpperOneText(frameRules, config.placeText.RAID, offsetX, offsetY)
    offsetX = offsetX + margin

    createUpperOneText(frameRules, config.placeText.ARENA, offsetX, offsetY)
    offsetX = offsetX + margin

    createUpperOneText(frameRules, config.placeText.BATTLEGROUND, offsetX, offsetY)

    local function updateFrameRules()
        local rules = profileSwitcher.getRules()

        -- remove framesRules of deleted rules
        for id, frameRule in pairs(framesRules) do
            if rules[id] == nil then
                frameRule:clear()
            end
        end

        -- initialize framesRules for new rules
        local index = 0
        for id, rule in pairs(rules) do
            if framesRules[id] == nil then
                framesRules[id] = FrameRule:new(rule, index)
            else
                framesRules[id]:update(index)
            end
            index = index + 1
        end
    end

    updateFrameRules()
    profileSwitcher:on('change', updateFrameRules)

    -- TODO: убрать потом
    TrGCDGUITESTPAN = frame
    -- /run InterfaceOptionsFrame_OpenToCategory(TrGCDGUITESTPAN)

    return frame
end)
