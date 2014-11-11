TrufiGCD:define('settingsFrame', function()
    local savedVariables = TrufiGCD:require('savedVariables')
    local settings = TrufiGCD:require('settings')
    local utils = TrufiGCD:require('utils')
    local units = TrufiGCD:require('units')
    local config = TrufiGCD:require('config')

    local settingsWidth = 600

    local function createButton(parent, point, offset, text, options)
        options = options or {}
        options.template = options.template or 'UIPanelButtonTemplate'

        local button = CreateFrame('Button', options.name, parent, options.template)
        button:SetWidth(options.width or 100)
        button:SetHeight(options.height or 22)
        button:SetPoint(point, offset[1], offset[2])
        button:SetText(text)
        if options.enable == false then button:Disable() end

        if options.topText and options.topText.text then
            local size = options.topText.size or 10
            local pos = options.topText.point or 'TOP'
            local ofs = options.topText.offset or {0, 10}

            button.topText = button:CreateFontString(nil, 'BACKGROUND')
            button.topText:SetFont('Fonts\\FRIZQT__.TTF', size)
            button.topText:SetText(options.topText.text)
            button.topText:SetPoint(pos, button, pos, ofs[1], ofs[2])
        end

        return button
    end

    -- main settings frame
    local frame = CreateFrame('Frame', nil, UIParent, 'OptionsBoxTemplate')
    frame.name = 'TrufiGCD'

    -- show/hide anchors button and frame
    local buttonShowAnchors = createButton(frame, 'TOPLEFT', {10, -30}, 'Show', {topText = {text = 'Show/Hide anchors'}})

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
--local function AddButton(parent,point,x,y,height,width,text,font,texttop,template) --шаблон кнопки
--local function createButton(parent, point, offset, text, options)
    local frameShowAnchorsButton = createButton(frameShowAnchors, 'BOTTOM', {0, 5}, 'Return to options', {
        width = 150,
        topText = {
            size = 12,
            text = 'TrufiGCD',
            point = 'TOP',
            offset = {0, 15}
        }
    })
    frameShowAnchorsButton:SetScript('OnClick', function()
        InterfaceOptionsFrame_OpenToCategory(frame)
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

    InterfaceOptions_AddCategory(frame)

    -- settings of view
    local frameView = CreateFrame('Frame', nil, UIParent, 'OptionsBoxTemplate')
    frameView.name = 'Frames'
    frameView.parent = 'TrufiGCD'

    -- create tabs
    local frameTabs = CreateFrame('Frame', 'TrGCDViewTabsFrame', frameView)
    frameTabs:SetPoint('TOPLEFT', 10, -100)
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

    local FrameUnitSettings = {}

    function FrameUnitSettings:new(options)
        local obj = {}

        obj.name = options.name
        obj.parentFrame = options.parentFrame
        obj.width = options.width
        obj.height = options.height

        -- common frame
        obj.frame = CreateFrame('Frame', nil, obj.parentFrame)
        obj.frame:SetPoint('TOPLEFT', options.offset[1], options.offset[2])
        obj.frame:SetWidth(obj.width)
        obj.frame:SetHeight(obj.height)

        -- checkbox enable
        obj.chboxEnable = CreateFrame('CheckButton', 'TrGCDChboxEnable' .. obj.name, obj.frame, 'OptionsSmallCheckButtonTemplate')
        obj.chboxEnable:SetPoint('TOPLEFT', 10, -10)
        obj.chboxEnable:SetChecked(unitSettings[obj.name].enable)
        _G[obj.chboxEnable:GetName() .. 'Text']:SetText(config.unitText[unitName])
        obj.chboxEnable:SetScript('OnClick', self.changeEnable)

        -- dropdown menu of direction
        obj.dropdownDirection = CreateFrame('Frame', 'TrGCDDropdownDirection' .. obj.name, obj.frame, 'UIDropDownMenuTemplate')
        obj.dropdownDirection:SetPoint('TOPLEFT', 70, -10)
        UIDropDownMenu_SetWidth(obj.dropdownDirection, 55)
        UIDropDownMenu_SetText(obj.dropdownDirection, unitSettings[obj.name].direction)
        UIDropDownMenu_Initialize(obj.dropdownDirection, function() self:dropdownDirectionInit() end)

        -- size icons slider        
        obj.sizeSlider = CreateFrame('Slider', 'TrGCDSizeSlider' .. obj.name, obj.frame, 'OptionsSliderTemplate')
        obj.sizeSlider:SetWidth(170)
        obj.sizeSlider:SetPoint('TOPLEFT', 190, -10)
        _G[obj.sizeSlider:GetName() .. 'Low']:SetText('10')
        _G[obj.sizeSlider:GetName() .. 'High']:SetText('100')
        _G[obj.sizeSlider:GetName() .. 'Text']:SetText(unitSettings[obj.name].sizeIcons)
        obj.sizeSlider:SetMinMaxValues(10,100)
        obj.sizeSlider:SetValueStep(1)
        obj.sizeSlider:SetValue(unitSettings[obj.name].sizeIcons)
        obj.sizeSlider:SetScript('OnValueChanged', function(_, value) self:sizeSliderChanged(value) end)
        obj.sizeSlider:Show()

        -- number icons slider
        obj.numberSlider = CreateFrame('Slider', 'TrGCDNumberIconsSlider' .. obj.name, obj.frame, 'OptionsSliderTemplate')
        obj.numberSlider:SetWidth(100)
        obj.numberSlider:SetPoint('TOPLEFT', 390, -10)
        _G[obj.numberSlider:GetName() .. 'Low']:SetText('1')
        _G[obj.numberSlider:GetName() .. 'High']:SetText('8')
        _G[obj.numberSlider:GetName() .. 'Text']:SetText(unitSettings[obj.name].numberIcons)
        obj.numberSlider:SetMinMaxValues(1,8)
        obj.numberSlider:SetValueStep(1)
        obj.numberSlider:SetValue(unitSettings[obj.name].numberIcons)
        obj.numberSlider:SetScript('OnValueChanged', function (_,value) self:numberSliderChanged(value) end)
        obj.numberSlider:Show()

        -- transparency icons slider
        obj.transparencySliders = CreateFrame('Slider', 'TrGCDTransparencyIconsSlider' .. obj.name, obj.frame, 'OptionsSliderTemplate')
        obj.transparencySliders:SetWidth(100)
        obj.transparencySliders:SetPoint('TOPLEFT', 450, -10)
        _G[obj.transparencySliders:GetName() .. 'Low']:SetText('0')
        _G[obj.transparencySliders:GetName() .. 'High']:SetText('100')
        _G[obj.transparencySliders:GetName() .. 'Text']:SetText(unitSettings[obj.name].transparencyIcons)
        obj.transparencySliders:SetMinMaxValues(0, 100)
        obj.transparencySliders:SetValueStep(1)
        obj.transparencySliders:SetValue(unitSettings[obj.name].transparencyIcons)
        obj.transparencySliders:SetScript('OnValueChanged', function (_,value) self:transparencySliderChanged(value) end)
        obj.transparencySliders:Show()

        self.__index = self

        return setmetatable(obj, self)
    end

    function FrameUnitSettings:getSetting(name)
        return unitSettings[self.name][name]
    end

    function FrameUnitSettings:setSetting(name, value)
        unitSettings[self.name][name] = value
    end

    function FrameUnitSettings:changeEnable()
        self:setSetting('enable', not self:getSetting('enable'))

        self:settingChanged()
    end

    function FrameUnitSettings:changeDropDownDirection(itemIndex)
        local direction = config.directionsList[itemIndex]
        UIDropDownMenu_SetText(obj.dropdownDirection, direction)
        self:setSetting('direction', direction)

        self:settingChanged()
    end

    function FrameUnitSettings:dropdownDirectionInit()
        for i, el in pairs(config.directionsList) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = el
            info.menuList = i
            info.func = self:changeDropDownDirection(i)

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
        self.transparencySliders:SetValue(self:getSetting('transparencyIcons'))
    end


    local listFrameUnitSettings = {}


    local FrameChangeAllSettings = {}

    function FrameChangeAllSettings:new(options)
        options.name = options.unitList[1]

        local obj = FrameUnitSettings:new(options)

        for i, el in pairs(listFrameUnitSettings) do
            el.onChange = function() self:disable() end
        end

        self.__index = self

        return setmetatable(obj, self)
    end

    function FrameChangeAllSettings:settingChanged()
        -- none
    end

    -- set settings to all units
    function FrameChangeAllSettings:setSetting(name, value)
        self:enable()

        for i, el in pairs(self.unitList) do
            listFrameUnitSettings[el]:setSettings(name, value)
            listFrameUnitSettings[el]:updateViewFromSettings()
        end

        ignoreNextChangeSettings = true
        settings:set('unitFrames', unitSettings)
    end

    function FrameChangeAllSettings:enable()
        self.frame:SetAlpha(1)
    end

    function FrameChangeAllSettings:disable()
        self.frame:SetAlpha(0.5)
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
        frame:SetText('Enable')
        frame:SetPoint('TOPLEFT', ofsX, ofsY)
    end

    function createUpperText(parentFrame)
        createUpperOneText(parentFrame, 'Enable', 20, -10)
        createUpperOneText(parentFrame, 'Fade', 105, -10)
        createUpperOneText(parentFrame, 'Size icons', 245, -10)
        createUpperOneText(parentFrame, 'Number of icons', 390, -10)
        createUpperOneText(parentFrame, 'Transparency', 450, -10)
    end

    function createViewTabSettings(list, parentFrame)
        local paddingTop = 50
        local height = 50

        createUpperText(parentFrame)

        for i, unitName in pairs(list) do
            listFrameUnitSettings[unitName] = FrameUnitSettings:new({
                name = unitName,
                parentFrame = parentFrame,
                width = settingsWidth,
                height = height,
                offset = {0, -paddingTop - (i - 1) * height}
            })
        end

        -- add row that changed all frames
        FrameUnitSettings:new({
            unitList = list,
            parentFrame = parentFrame,
            width = settingsWidth,
            height = height,
            offset = {0, -10}
        })
    end

    -- create party settings
    local partyList = {'player', 'party1', 'party2', 'party3', 'party4'}
    createViewTabSettings(partyList, frameParty)

    -- create arena settings
    local arenaList = {'arena1', 'arena2', 'arena3', 'arena4', 'arena5'}
    createViewTabSettings(arenaList, frameArena)

    InterfaceOptions_AddCategory(frameView)

    -- убрать потом
    TrGCDGUITEST = frameView
end)
