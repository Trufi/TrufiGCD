TrufiGCD:define('settingsFrame', function()
    local savedVariables = TrufiGCD:require('savedVariables')
    local utils = TrufiGCD:require('utils')

    local commonSaves = nil
    local settings = nil

    -- new <-> old settings
    local unitsNames = {
        'player',
        'party1', 'party2', 'party3', 'party4',
        'arena1', 'arena2', 'arena3', 'arena4', 'arena5',
        'target', 'focus'
    }

    local numberOfUnitsNames = {
        player = 1,
        party1 = 2, party2 = 3, party3 = 4, party4 = 5,
        arena1 = 6, arena2 = 7, arena3 = 8, arena4 = 9, arena5 = 10,
        target = 11, focus = 12
    }

    local function convertUnitFramesToNewSettings(unitFrames)
        local res = {}

        for i, el in pairs(unitFrames) do
            if unitsNames[i] then
                res[unitsNames[i]] = {
                    offset = {el.x, el.y},
                    position = el.point,
                    direction = el.fade,
                    sizeIcons = el.size,
                    numberIcons = el.width,
                    enable = el.enable,
                    text = unitsNames[i]
                }
            end
        end

        return res
    end

    local function convertUnitFramesToOldSettings(unitFrames)
        local res = {}

        for i, el in pairs(unitFrames) do
            if numberOfUnitsNames[el] then
                res[numberOfUnitsNames[el]] = {
                    x = el.offset[1],
                    y = el.offset[2],
                    point = el.position,
                    fade = el.direction,
                    size = el.sizeIcons,
                    width = el.numberIcons,
                    enable = el.enable,
                    text = numberOfUnitsNames[el]
                }
            end
        end

        return res
    end

    local defaultSettings = {
        tooltip = {
            enable = true,
            showInChatId = false,
            stopMove = false
        },
        enableLocations = {
            Enable = true,
            PvE = true,
            Raid = true,
            Arena = true,
            Bg = true,
            World = true
        },
        typeMovingIcon = true,
        unitFrame = {}
    }

    for i, el in pairs(unitsNames) do
        defaultSettings.unitFrame = {
            offset = {0, 0},
            position = 'CENTER',
            sizeIcons = 30,
            numberIcons = '4',
            direction = 'Left',
            text = el
        }
    end

    local function initSettings()
        commonSaves = savedVariables:getCommon('all')

        if commonSaves == nil then
            commonSaves = utils.clone(defaultSettings)
            savedVariables:setCommon('all', commonSaves)
        end

        commonSaves.unitFrame = convertUnitFramesToNewSettings(commonSaves.unitFrame)

        settings = savedVariables:getCharacter('all')

        if settings == nil then 
            settings = utils.clone(commonSaves)
            savedVariables:setCharacter('all', settings)
        end

        settings.unitFrame = convertUnitFramesToNewSettings(settings.unitFrame)
    end

    initSettings()

    local function createButton(parent, position, offset, text, options)
        options = options or {}
        options.template = options.template or 'UIPanelButtonTemplate'

        local button = CreateFrame('Button', nil, parent, options.template)
        button:SetWidth(options.width or 100)
        button:SetHeight(options.height or 22)
        button:SetPoint(position, offset[1], offset[2])
        button:SetText(text)
        if options.enable == false then button:Disable() end

        if options.topText and options.topText.text then
            local size = options.topText.size or 10
            local pos = options.topText.position or 'TOP'
            local ofs = options.topText.offset or {0, 10}

            button.topText = button:CreateFontString(nil, 'BACKGROUND')
            button.topText:SetFont('Fonts\\FRIZQT__.TTF', size)
            button.topText:SetText(options.topText.text)
            button.topText:SetPoint(pos, button, pos, ofs[1], ofs[2])
        end

        return button
    end

    local function createCheckbox(parent, position, offset, text, name, enable, tooltip)
        local button = CreateFrame('CheckButton', name, parent, 'ChatConfigCheckButtonTemplate')
        button:SetPoint(position, offset[1], offset[2])
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

--local function AddButton(parent,position,x,y,height,width,text,font,texttop,template) --шаблон кнопки
--local function createButton(parent, position, offset, text, options)

    -- main settings frame
    local frame = CreateFrame('Frame', nil, UIParent, 'OptionsBoxTemplate')
    frame:Hide()
    frame.name = 'TrufiGCD'

    -- show/hide anchors button and frame
    -- local buttonShowAnchors = createButton(frame, 'TOPLEFT', {10, -30}, 'Show', 'Show/Hide anchors')

    -- local isShowAnchors = false

    -- function showHideAnchors()
    --     if not isShowAnchors then
    --         buttonShowAnchors:SetText('Hide')
    --         TrGCDFixEnable:Show()

    --         for i=1,12 do
    --             if (TrGCDQueueOpt[i].enable) thenx
    --                 TrGCDQueueFr[i].texture:SetAlpha(0.5)
    --                 TrGCDQueueFr[i].text:SetAlpha(0.5)
    --             end
    --         end
    --         main.showFramesAnchor()
    --     else
    --         TrGCDGUI.buttonfix:SetText("Show")
    --         TrGCDFixEnable:Hide()
    --         for i=1,12 do
    --             if (TrGCDQueueOpt[i].enable) then
    --                 TrGCDQueueFr[i]:SetMovable(false)
    --                 TrGCDQueueFr[i]:EnableMouse(false)
    --                 TrGCDQueueFr[i].texture:SetAlpha(0) 
    --                 TrGCDQueueFr[i].text:SetAlpha(0)
    --                 TrGCDQueueOpt[i].point, _, _, TrGCDQueueOpt[i].x, TrGCDQueueOpt[i].y = TrGCDQueueFr[i]:GetPoint()
    --                 TrufiGCDChSave["TrGCDQueueFr"][i]["x"] = TrGCDQueueOpt[i].x
    --                 TrufiGCDChSave["TrGCDQueueFr"][i]["y"] = TrGCDQueueOpt[i].y
    --                 TrufiGCDChSave["TrGCDQueueFr"][i]["point"] = TrGCDQueueOpt[i].point
    --                 TrufiGCDChSave["TrGCDQueueFr"][i]["enable"] = TrGCDQueueOpt[i].enable
    --             end
    --         end
    --     end
    -- end

    buttonShowAnchors:SetScript('OnClick', showHideAnchors)
end)
