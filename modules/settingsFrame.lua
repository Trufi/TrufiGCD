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

    local function createCheckbox(parent, point, offset, text, name, enable, tooltip)
        local button = CreateFrame('CheckButton', name, parent, 'ChatConfigCheckButtonTemplate')
        button:SetPoint(point, offset[1], offset[2])
        button:SetChecked(enable)

        _G[name .. 'Text']:SetText(text)

        button:SetScript('OnEnter', function(self)
            if tooltip then
                GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
                GameTooltip:SetText(tooltip, nil, nil, nil, nil, 1)
            end
        end )

        button:SetScript('OnLeave', function(self)
            GameTooltip:Hide()
        end)

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
        _G[obj.chboxEnable:GetName() .. 'Text']:SetText(options.text)
        obj.chboxEnable:SetScript('OnClick', self.changeEnable)

        -- dropdown menu of direction
        obj.dropdownDirection = CreateFrame('Frame', 'TrGCDDropdownDirection' .. obj.name, obj.frame, 'UIDropDownMenuTemplate')
        obj.dropdownDirection:SetPoint('TOPLEFT', 70, -10)
        UIDropDownMenu_SetWidth(obj.dropdownDirection, 55)
        UIDropDownMenu_SetText(obj.dropdownDirection, unitSettings[obj.name].direction)
        UIDropDownMenu_Initialize(obj.dropdownDirection, function() self:dropdownDirectionInit() end)



        self.__index = self

        return setmetatable(obj, self)
    end

    function FrameUnitSettings:changeEnable()
        unitSettings[unitName].enable = not unitSettings[unitName].enable

        self:settingChanged()
    end

    function FrameUnitSettings:changeDropDownDirection()
        -- TODO
    end

    function FrameUnitSettings:dropdownDirectionInit()
        for i, el in pairs(config.directionsList) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = el
            info.menuList = i
            info.func = self:changeDropDownDirection(i, el)

            if i == 1 then info.notCheckable = true end

            UIDropDownMenu_AddButton(info)
        end
    end

    function FrameUnitSettings:settingChanged()
        -- TODO
    end

    function createViewTabSettings(list, parentFrame)
        local paddingTop = 10
        local height = 50

        for i, unitName in pairs(list) do
            local frameUnit = FrameUnitSettings:new({
                name = unitName,
                text = config.unitText[unitName],
                parentFrame = parentFrame,
                width = settingsWidth,
                height = height,
                offset = {0, -paddingTop - (i - 1) * height}
            })
        end
    end

    -- create party settings
    local partyList = {'player', 'party1', 'party2', 'party3', 'party4'}

    createViewTabSettings(partyList, frameParty)

    InterfaceOptions_AddCategory(frameView)

    -- убрать потом
    TrGCDGUITEST = frameView
end)
