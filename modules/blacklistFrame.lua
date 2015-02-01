TrufiGCD:define('blacklistFrame', function()
    local blacklist = TrufiGCD:require('blacklist')
    local utils = TrufiGCD:require('utils')

    local list = blacklist:getList()

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

    -- add blacklist tab to addon settings
    local settingFrame = CreateFrame('Frame', nil, UIParent, 'OptionsBoxTemplate')
    settingFrame:Hide()
    settingFrame.name = "Blacklist"
    settingFrame.parent = "TrufiGCD"

    local listBorderFrame = CreateFrame("Frame", nil, settingFrame)
    listBorderFrame:SetPoint("TOPLEFT", settingFrame, "TOPLEFT",10, -25)
    listBorderFrame:SetWidth(200)
    listBorderFrame:SetHeight(501)
    listBorderFrame:SetBackdrop({
        bgFile = nil,
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16, 
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    })

    local listScrollFrame = CreateFrame("ScrollFrame", nil, settingFrame)
    listScrollFrame:SetPoint("TOPLEFT", settingFrame, "TOPLEFT",10, -30)
    listScrollFrame:SetWidth(200)
    listScrollFrame:SetHeight(488)

    local listScrollBar = CreateFrame("Slider", "TrGCDBLScroll", listScrollFrame, "UIPanelScrollBarTemplate")
    listScrollBar:SetPoint("TOPLEFT", listScrollFrame, "TOPRIGHT", 1, -16)
    listScrollBar:SetPoint("BOTTOMLEFT", listScrollFrame, "BOTTOMRIGHT", 1, 16)
    listScrollBar:SetMinMaxValues(1, 470)
    listScrollBar:SetValueStep(1)

    local listScrollBarBackground = listScrollBar:CreateTexture(nil, "BACKGROUND")
    listScrollBarBackground:SetAllPoints(listScrollBar)
    listScrollBarBackground:SetTexture(0, 0, 0, 0.4)

    listScrollBar:SetValue(0)
    listScrollBar:SetScript("OnValueChanged", function (self, value)
        self:GetParent():SetVerticalScroll(value)
    end)

    local listFrame = CreateFrame("Frame", nil, listScrollFrame)
    --listFrame:SetPoint("TOPLEFT", listScrollFrame, "TOPLEFT",10, -35)
    listFrame:SetWidth(200)
    listFrame:SetHeight(958)

    local listScrollText = listFrame:CreateFontString(nil, "BACKGROUND")
    listScrollText:SetFont("Fonts\\FRIZQT__.TTF", 12)
    listScrollText:SetText("Blacklist")
    listScrollText:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 15, 15)

    local listSpells = {}

    local deleteSpell = createButton(settingFrame, 'TOPLEFT', {260, -130}, 'Delete', {
        topText = {
            text = 'Select spell',
            size = 12,
            point = 'TOPLEFT',
            offset = {5, 15}
        }
    })

    local selectedSpell = nil

    for i = 1, 60 do
        listSpells[i] = createButton(listFrame, 'TOP', {0, -(i - 1) * 16}, '', {
            width = 192,
            height = 15,
            template = true,
            topText = {text = '', point = 'CENTER', offset = {0, 0}},
            enable = false
        })

        listSpells[i].Number = i

        listSpells[i].Texture = listSpells[i]:CreateTexture(nil, 'BACKGROUND')
        listSpells[i].Texture:SetAllPoints(listSpells[i])
        listSpells[i].Texture:SetTexture(255, 210, 0)
        listSpells[i].Texture:SetAlpha(0)

        listSpells[i]:SetScript('OnEnter', function(self)
            if (selectedSpell ~= self) then self.Texture:SetAlpha(0.3) end
        end)

        listSpells[i]:SetScript('OnLeave', function(self)
            if (selectedSpell ~= self) then self.Texture:SetAlpha(0) end
        end)

        listSpells[i]:SetScript('OnClick', function(self) 
            if (selectedSpell ~= nil) then selectedSpell.Texture:SetAlpha(0) end
            selectedSpell = self
            self.Texture:SetAlpha(0.6)
            deleteSpell.topText:SetText(self.topText:GetText())
        end)
    end

    -- initialize list frame from blacklist
    local function initListFrame()
        list = blacklist:getList()

        for i = 1, 60 do
            if (list[i] ~= nil) then
                local spellname = GetSpellInfo(list[i])

                if tonumber(list[i]) ~= nil and spellname ~= nil then
                    listSpells[i].topText:SetText(list[i] .. ' - ' .. spellname)
                else
                    listSpells[i].topText:SetText(list[i])
                end

                listSpells[i]:Enable()
            else
                listSpells[i]:Disable()
                listSpells[i].topText:SetText(nil)
                listSpells[i].Texture:SetAlpha(0)
            end
        end
    end

    initListFrame()

    deleteSpell:SetScript('OnClick', function()
        if (selectedSpell ~= nil) then
            blacklist:remove(list[selectedSpell.Number])
            deleteSpell.topText:SetText('Select spell')
            initListFrame()
        end
    end)

    listScrollFrame:SetScrollChild(listFrame)

    -- editbox and button for add spell
    local addSpellEditbox = CreateFrame('EditBox', nil, settingFrame, 'InputBoxTemplate')
    addSpellEditbox:SetWidth(200)
    addSpellEditbox:SetHeight(20)
    addSpellEditbox:SetPoint('TOPLEFT', settingFrame, 'TOPLEFT', 265, -200)
    addSpellEditbox:SetAutoFocus(false)

    local addSpellButton = createButton(settingFrame, 'TOPLEFT', {260, -225}, 'Add', {
        topText = {
            size = 12,
            text = 'Enter spell name or spell ID',
            point = 'TOPLEFT',
            offset = {5, 40}
        }
    })

    local function addSpellToList(self)
        if addSpellEditbox:GetText() ~= nil then
            local spellname = addSpellEditbox:GetText()
            blacklist:add(spellname)
            initListFrame()
            addSpellEditbox:ClearFocus()
        end
    end

    addSpellButton:SetScript('OnClick', function (self) addSpellToList(self) end)
    addSpellEditbox:SetScript('OnEnterPressed', function (self) addSpellToList(self) end)

    -- кнопка восстановления стандартных настроек
    local defaultSettingsButton = createButton(settingFrame, 'TOPRIGHT', {-30, -30}, 'Default', {
        topText = {
            size = 10,
            text = 'Restore default blacklist'
        }
    })

    defaultSettingsButton:SetScript('OnClick', function()
        blacklist:default()
        list = blacklist:getList()
        initListFrame()
    end)

    settingFrame.okay = function()
        blacklist:save()
    end

    settingFrame.cancel = function()
        blacklist:load()
        initListFrame()
    end

    settingFrame.default = function()
        blacklist:default()
        initListFrame()
    end

    settingFrame.parent = 'TrufiGCD'

    return settingFrame
end)
