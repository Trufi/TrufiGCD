TrufiGCD:define('settingsFrame', function()
    local savedVariables = TrufiGCD:require('savedVariables')
    local settings = TrufiGCD:require('settings')
    local utils = TrufiGCD:require('utils')
    local units = TrufiGCD:require('units')

    local function createButton(parent, point, offset, text, options)
        options = options or {}
        options.template = options.template or 'UIPanelButtonTemplate'

        local button = CreateFrame('Button', nil, parent, options.template)
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

    -- party button
    local buttonParty = createButton(frameView, 'TOPLEFT', {20, -50}, '', {
        width = 192,
        height = 15,
        template = 'OptionsFrameTabButtonTemplate',
        topText = {text = '123', point = 'CENTER', offset = {0, 0}},
        enable = false
    })

    buttonParty.Texture = buttonParty:CreateTexture(nil, 'BACKGROUND')
    buttonParty.Texture:SetAllPoints(buttonParty)
    buttonParty.Texture:SetTexture(255, 210, 0)
    buttonParty.Texture:SetAlpha(0.5)

    buttonParty:SetScript('OnEnter', function(self)
        self.Texture:SetAlpha(0.3)
    end)

    buttonParty:SetScript('OnLeave', function(self)
        self.Texture:SetAlpha(0)
    end)

    InterfaceOptions_AddCategory(frameView)

    -- убрать потом
    TrGCDGUITEST = frame
end)
