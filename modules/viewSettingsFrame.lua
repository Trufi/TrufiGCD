TrufiGCD:define('viewSettingsFrame', function()
    local settings = TrufiGCD:require('settings')
    local config = TrufiGCD:require('config')
    local utils = TrufiGCD:require('utils')
    local units = TrufiGCD:require('units')

    local settingsWidth = 600


    -- settings of view
    local frameView = CreateFrame('Frame', nil, UIParent, 'OptionsBoxTemplate')
    frameView.name = 'View'
    frameView.parent = 'TrufiGCD'



    -- show/hide anchors button and frame
    local buttonShowAnchors = CreateFrame('Button', nil, frameView, 'UIPanelButtonTemplate')
    buttonShowAnchors:SetWidth(100)
    buttonShowAnchors:SetHeight(22)
    buttonShowAnchors:SetPoint('TOPLEFT', 10, -30)
    buttonShowAnchors:SetText('Show')

    local buttonShowAnchorstopText = buttonShowAnchors:CreateFontString(nil, 'BACKGROUND')
    buttonShowAnchorstopText:SetFont('Fonts\\FRIZQT__.TTF', 10)
    buttonShowAnchorstopText:SetText('Show/Hide anchors')
    buttonShowAnchorstopText:SetPoint('TOP', 0, 10)

    -- frame after push show/hide button
    local frameShowAnchors = CreateFrame('Frame', nil, UIParent)
    frameShowAnchors:SetWidth(160)
    frameShowAnchors:SetHeight(50)
    frameShowAnchors:SetPoint('TOP', 0, -150)
    frameShowAnchors:Hide()   
    frameShowAnchors:RegisterForDrag('LeftButton')
    frameShowAnchors:SetScript('OnDragStart', frameShowAnchors.StartMoving)
    frameShowAnchors:SetScript('OnDragStop', frameShowAnchors.StopMovingOrSizing)
    frameShowAnchors:SetMovable(true)
    frameShowAnchors:EnableMouse(true)

    local frameShowAnchorsTexture = frameShowAnchors:CreateTexture(nil, 'BACKGROUND')
    frameShowAnchorsTexture:SetAllPoints(frameShowAnchors)
    frameShowAnchorsTexture:SetTexture(0, 0, 0)
    frameShowAnchorsTexture:SetAlpha(0.5)

    local frameShowAnchorsButton = CreateFrame('Button', nil, frameShowAnchors, 'UIPanelButtonTemplate')
    frameShowAnchorsButton:SetWidth(150)
    frameShowAnchorsButton:SetHeight(22)
    frameShowAnchorsButton:SetPoint('BOTTOM', 0, 5)
    frameShowAnchorsButton:SetText('Return to options')

    local frameShowAnchorsButtonText = frameShowAnchorsButton:CreateFontString(nil, 'BACKGROUND')
    frameShowAnchorsButtonText:SetFont('Fonts\\FRIZQT__.TTF', 12)
    frameShowAnchorsButtonText:SetText('TrufiGCD')
    frameShowAnchorsButtonText:SetPoint('TOP', 0, 15)

    frameShowAnchorsButton:SetScript('OnClick', function()
        InterfaceOptionsFrame_OpenToCategory(frameView)
    end)


    local isShowAnchors = false

    function showHideAnchors()
        if not isShowAnchors then
            buttonShowAnchors:SetText('Hide')
            frameShowAnchors:Show()
            units.showAnchorFrames()
            isShowAnchors = true
        else
            buttonShowAnchors:SetText('Show')
            frameShowAnchors:Hide()
            units.hideAnchorFrames()
            isShowAnchors = false

            settings:set('unitFrames', units.framesPositions())
        end
    end

    buttonShowAnchors:SetScript('OnClick', showHideAnchors)



    -- create tabs
    local frameTabs = CreateFrame('Frame', 'TrGCDViewTabsFrame', frameView)
    frameTabs:SetPoint('TOPLEFT', 10, -125)
    frameTabs:SetWidth(settingsWidth)
    frameTabs:SetHeight(500)

    local buttonParty = CreateFrame('Button', 'TrGCDViewTabsFrameTab1', frameTabs, 'TabButtonTemplate')
    buttonParty:SetPoint('TOPLEFT', 10, 0)
    buttonParty:SetText('Party')
    buttonParty:SetWidth(buttonParty:GetTextWidth() + 31);
    PanelTemplates_TabResize(buttonParty, 0);

    local buttonArena = CreateFrame('Button', 'TrGCDViewTabsFrameTab2', frameTabs, 'TabButtonTemplate')
    buttonArena:SetPoint('TOPLEFT', buttonParty:GetWidth() + 15, 0)
    buttonArena:SetText('Arena')
    buttonArena:SetWidth(buttonArena:GetTextWidth() + 31);
    PanelTemplates_TabResize(buttonArena, 0);

    PanelTemplates_SetNumTabs(frameTabs, 2)
    PanelTemplates_SetTab(frameTabs, 1)

    local frameParty = CreateFrame('Frame', 'TrGCDViewTabsFramePage1', frameTabs, 'OptionsBoxTemplate')
    frameParty:SetPoint('TOPLEFT', 0, -30)
    frameParty:SetWidth(settingsWidth)
    frameParty:SetHeight(400)

    local frameArena = CreateFrame('Frame', 'TrGCDViewTabsFramePage2', frameTabs, 'OptionsBoxTemplate')
    frameArena:SetPoint('TOPLEFT', 0, -30)
    frameArena:SetWidth(settingsWidth)
    frameArena:SetHeight(400)
    frameArena:Hide()

    buttonParty:SetScript('OnClick', function()
        frameArena:Hide()
        frameParty:Show()
        PanelTemplates_SetTab(frameTabs, 1)
    end)

    buttonArena:SetScript('OnClick', function()
        frameParty:Hide()
        frameArena:Show()
        PanelTemplates_SetTab(frameTabs, 2)
    end)



    local ignoreNextChangeSettings = false
    local unitSettings = settings:get('unitFrames')

    local _idCounter = 0

    local FrameUnitSettings = {}

    function FrameUnitSettings:new(options)
        local obj = {}

        _idCounter = _idCounter + 1

        obj.id = _idCounter
        obj.name = options.name or config.unitText[options.unitName]
        obj.unitName = options.unitName
        obj.parentFrame = options.parentFrame
        obj.width = options.width
        obj.height = options.height

        self.__index = self

        local metatable = setmetatable(obj, self)

        metatable:create(options)

        return metatable
    end

    function FrameUnitSettings:create(options)
        -- common frame
        self.frame = CreateFrame('Frame', nil, self.parentFrame)
        self.frame:SetPoint('TOPLEFT', options.offset[1], options.offset[2])
        self.frame:SetWidth(self.width)
        self.frame:SetHeight(self.height)

        -- checkbox enable
        self.chboxEnable = CreateFrame('CheckButton', 'TrGCDChboxEnable' .. self.id, self.frame, 'OptionsSmallCheckButtonTemplate')
        self.chboxEnable:SetPoint('TOPLEFT', 10, -10)
        self.chboxEnable:SetChecked(unitSettings[self.unitName].enable)
        _G[self.chboxEnable:GetName() .. 'Text']:SetText(self.name)
        self.chboxEnable:SetScript('OnClick', function() self:changeEnable() end)

        -- dropdown menu of direction
        self.dropdownDirection = CreateFrame('Frame', 'TrGCDDropdownDirection' .. self.id, self.frame, 'UIDropDownMenuTemplate')
        self.dropdownDirection:SetPoint('TOPLEFT', 60, -10)
        UIDropDownMenu_SetWidth(self.dropdownDirection, 55)
        UIDropDownMenu_SetText(self.dropdownDirection, unitSettings[self.unitName].direction)
        UIDropDownMenu_Initialize(self.dropdownDirection, function(_self, level, menuList) self:dropdownDirectionInit(menuList) end)

        -- size icons slider        
        self.sizeSlider = CreateFrame('Slider', 'TrGCDSizeSlider' .. self.id, self.frame, 'OptionsSliderTemplate')
        self.sizeSlider:SetWidth(170)
        self.sizeSlider:SetPoint('TOPLEFT', 165, -15)
        _G[self.sizeSlider:GetName() .. 'Low']:SetText('10')
        _G[self.sizeSlider:GetName() .. 'High']:SetText('100')
        _G[self.sizeSlider:GetName() .. 'Text']:SetText(unitSettings[self.unitName].sizeIcons)
        self.sizeSlider:SetMinMaxValues(10, 100)
        self.sizeSlider:SetValueStep(1)
        self.sizeSlider:SetValue(unitSettings[self.unitName].sizeIcons)
        self.sizeSlider:SetScript('OnValueChanged', function(_, value) self:sizeSliderChanged(value) end)
        self.sizeSlider:Show()

        -- number icons slider
        self.numberSlider = CreateFrame('Slider', 'TrGCDNumberIconsSlider' .. self.id, self.frame, 'OptionsSliderTemplate')
        self.numberSlider:SetWidth(100)
        self.numberSlider:SetPoint('TOPLEFT', 355, -15)
        _G[self.numberSlider:GetName() .. 'Low']:SetText('1')
        _G[self.numberSlider:GetName() .. 'High']:SetText('8')
        _G[self.numberSlider:GetName() .. 'Text']:SetText(unitSettings[self.unitName].numberIcons)
        self.numberSlider:SetMinMaxValues(1, 8)
        self.numberSlider:SetValueStep(1)
        self.numberSlider:SetValue(unitSettings[self.unitName].numberIcons)
        self.numberSlider:SetScript('OnValueChanged', function (_,value) self:numberSliderChanged(value) end)
        self.numberSlider:Show()

        -- transparency icons slider
        self.transparencySlider = CreateFrame('Slider', 'TrGCDTransparencyIconsSlider' .. self.id, self.frame, 'OptionsSliderTemplate')
        self.transparencySlider:SetWidth(100)
        self.transparencySlider:SetPoint('TOPLEFT', 480, -15)
        _G[self.transparencySlider:GetName() .. 'Low']:SetText('0')
        _G[self.transparencySlider:GetName() .. 'High']:SetText('100')
        _G[self.transparencySlider:GetName() .. 'Text']:SetText(unitSettings[self.unitName].transparencyIcons * 100)
        self.transparencySlider:SetMinMaxValues(0, 100)
        self.transparencySlider:SetValueStep(1)
        self.transparencySlider:SetValue(unitSettings[self.unitName].transparencyIcons)
        self.transparencySlider:SetScript('OnValueChanged', function (_,value) self:transparencySliderChanged(value) end)
        self.transparencySlider:Show()

    end

    function FrameUnitSettings:getSetting(name)
        return unitSettings[self.unitName][name]
    end

    function FrameUnitSettings:setSetting(name, value)
        unitSettings[self.unitName][name] = value
    end

    function FrameUnitSettings:changeEnable()
        self:setSetting('enable', not self:getSetting('enable'))

        self:settingChanged()
    end

    function FrameUnitSettings:changeDropDownDirection(itemIndex)
        local direction = config.directionsList[itemIndex]
        UIDropDownMenu_SetText(self.dropdownDirection, direction)
        self:setSetting('direction', direction)

        self:settingChanged()
    end

    function FrameUnitSettings:dropdownDirectionInit()
        local info = UIDropDownMenu_CreateInfo()

        for i, el in pairs(config.directionsList) do
            info.text = el
            info.menuList = i
            info.func = function() self:changeDropDownDirection(i) end

            if i == 1 then info.notCheckable = true end

            UIDropDownMenu_AddButton(info)
        end
    end

    function FrameUnitSettings:sizeSliderChanged(value)
        value = math.ceil(value)
        _G[self.sizeSlider:GetName() .. 'Text']:SetText(value)
        self:setSetting('sizeIcons', value)

        self:settingChanged()
    end

    function FrameUnitSettings:numberSliderChanged(value)
        value = math.ceil(value)
        _G[self.numberSlider:GetName() .. 'Text']:SetText(value)
        self:setSetting('numberIcons', value)

        self:settingChanged()
    end

    function FrameUnitSettings:transparencySliderChanged(value)
        value = math.ceil(value)
        _G[self.transparencySlider:GetName() .. 'Text']:SetText(value)
        self:setSetting('transparencyIcons', value / 100)

        self:settingChanged()
    end

    function FrameUnitSettings:settingChanged()
        if self.onChange then
            self.onChange()
        end

        ignoreNextChangeSettings = true
        settings:set('unitFrames', unitSettings)
    end

    function FrameUnitSettings:updateViewFromSettings()
        self.chboxEnable:SetChecked(self:getSetting('enable'))
        UIDropDownMenu_SetText(self.dropdownDirection, self:getSetting('direction'))
        self.sizeSlider:SetValue(self:getSetting('sizeIcons'))
        self.numberSlider:SetValue(self:getSetting('numberIcons'))
        self.transparencySlider:SetValue(self:getSetting('transparencyIcons') * 100)
    end


    local listFrameUnitSettings = {}


    local FrameChangeAllSettings = {}

    function FrameChangeAllSettings:new(options)
        options.unitName = options.unitList[1]
        options.name = 'All'

        local obj = FrameUnitSettings:new(options)
        obj.unitList = options.unitList
        obj.disableApply = true
        obj.isEnable = true

        self.__index = self

        local metatable = setmetatable(obj, self)

        metatable:create(options)
        metatable:disable()

        return metatable
    end

    setmetatable(FrameChangeAllSettings, {__index = FrameUnitSettings})

    function FrameChangeAllSettings:create(options)
        for i, el in pairs(self.unitList) do
            listFrameUnitSettings[el].onChange = function() self:disable() end
        end
    end

    function FrameChangeAllSettings:settingChanged()
        -- none
    end

    -- set settings to all units
    function FrameChangeAllSettings:setSetting(name, value)
        self.disableApply = false
        self:enable()

        for i, el in pairs(self.unitList) do
            listFrameUnitSettings[el]:setSetting(name, value)
            listFrameUnitSettings[el]:updateViewFromSettings()
        end

        ignoreNextChangeSettings = true
        settings:set('unitFrames', unitSettings)
        self.disableApply = true
    end

    function FrameChangeAllSettings:enable()
        if self.isEnable then return end

        self.frame:SetAlpha(1)

        self.isEnable = true
    end

    function FrameChangeAllSettings:disable()
        if self.isEnable and self.disableApply then
            self.frame:SetAlpha(0.5)

            self.isEnable = false
        end
    end



    function updateAllFrameUnitSettings()
        for i, el in pairs(listFrameUnitSettings) do
            el:updateViewFromSettings()
        end
    end

    settings:on('change', function()
        if ignoreNextChangeSettings then
            ignoreNextChangeSettings = false
        else
            unitSettings = settings:get('unitFrames')
            updateAllFrameUnitSettings()
        end
    end)

    function createUpperOneText(parentFrame, text, ofsX, ofsY)
        local frame = parentFrame:CreateFontString(nil, 'BACKGROUND')
        frame:SetFont('Fonts\\FRIZQT__.TTF', 12)
        frame:SetText(text)
        frame:SetPoint('TOPLEFT', ofsX, ofsY)
    end

    function createUpperText(parentFrame)
        createUpperOneText(parentFrame, 'Enable', 20, -15)
        createUpperOneText(parentFrame, 'Direction', 85, -15)
        createUpperOneText(parentFrame, 'Size of icons', 210, -15)
        createUpperOneText(parentFrame, 'Number of icons', 360, -15)
        createUpperOneText(parentFrame, 'Transparency', 490, -15)
    end

    function createViewTabSettings(list, parentFrame)
        local paddingTop = 105
        local height = 60

        createUpperText(parentFrame)

        for i, unitName in pairs(list) do
            listFrameUnitSettings[unitName] = FrameUnitSettings:new({
                unitName = unitName,
                parentFrame = parentFrame,
                width = settingsWidth,
                height = height,
                offset = {0, -paddingTop - (i - 1) * height}
            })
        end

        -- add row that changed all frames
        FrameChangeAllSettings:new({
            unitList = list,
            parentFrame = parentFrame,
            width = settingsWidth,
            height = height,
            offset = {0, -35}
        })
    end

    -- create party settings
    local partyList = {'player', 'party1', 'party2', 'party3', 'party4'}
    createViewTabSettings(partyList, frameParty)

    -- create arena settings
    local arenaList = {'arena1', 'arena2', 'arena3', 'arena4', 'arena5'}
    createViewTabSettings(arenaList, frameArena)

    return frameView
end)
