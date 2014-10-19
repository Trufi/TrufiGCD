TrufiGCD:define('blacklist', function()
    local savedVariables = TrufiGCD:require('savedVariables')
    local utils = TrufiGCD:require('utils')

    --закрытый черный список, по ID
    local innerList = {
        61391, -- Тайфун x2
        5374, -- Расправа х3
        27576, -- Расправа (левая рука) х3
        88263, -- Молот Праведника х3
        98057, -- Великий воин Света
        32175, -- Удар бури
        32176, -- Удар бури (левая рука)
        96103, -- Яростный выпад
        85384, -- Яростный выпад (левая рука)
        57794, -- Героический прыжок
        52174, -- Героический прыжок
        135299, -- Ледяная ловушка
        121473, -- Теневой клинок
        121474, -- Второй теневой клинок
        114093, -- Хлещущий ветер (левая рука)
        114089, -- Хлещущий ветер
        115357, -- Свирепость бури
        115360, -- Свирепость бури (левая рука)
        127797, -- Вихрь урсола
        102794, -- Вихрь урсола
        50622, -- Вихрь клинков
        122128, -- Божественная звезда (шп)
        110745, -- Божественная звезда (не шп)
        120696, -- Сияние (шп)
        120692, -- Сияние (не шп)
        115464, -- Целительная сфера
        126526, -- Целительная сфера
        132951, -- Осветительная ракета
        107270, -- Танцующий журавль
        137584, -- Бросок сюрикена
        137585, -- Бросок сюрикена левой рукой
        117993, -- Ци-полет (дамаг)
        124040, -- Ци-полет (хил)
        166646 -- Стремительность
    }

    local defaultBlacklist = {
        6603, -- автоатака
        75, -- автовыстрел
        7384 -- превосходствo
    }

    local commonSaves = nil
    local list = nil

    function initSettings()
        commonSaves = savedVariables:getCommon('blacklist')

        if commonSaves == nil then
            commonSaves = utils.clone(defaultBlacklist)
            savedVariables:setCommon('blacklist', commonSaves)
        end

        list = savedVariables:getCharacter('blacklist')

        if list == nil then 
            list = utils.clone(commonSaves)
            savedVariables:setCharacter('blacklist', list)
        end
    end

    initSettings()

    local blacklist = {}

    blacklist.has = function(self, el)
        for i, listElement in pairs(list) do
            -- check eqls ids
            if listElement == el then return true end
            -- check eqls spellnames
            if listElement == GetSpellInfo(el) then return true end
        end

        for i, listElement in pairs(innerList) do
            if listElement == el then return true end
        end

        return false
    end

    -- TODO: delete this after frames blacklist done here
    blacklist.getList = function()
        return list;
    end

    blacklist.add = function(self, el)
        if #list > 60 then return end

        for i = 1, #list do
            if list[i] == el then return end
        end

        local numEl = tonumber(el)

        if numEl ~= nil then
            table.insert(list, numEl)
        else
            table.insert(list, el)
        end
    end

    blacklist.remove = function(self, el)
        for i = 1, #list do
            if list[i] == el then 
                table.remove(list, i)
            end
        end
    end

    local function createButton(parent, position, offset, text, options)
        options = options or {}
        options.template = options.template or 'UIPanelButtonTemplate'

        local button = CreateFrame('Button', nil, parent, options.template)
        button:SetWidth(options.width or 100)
        button:SetHeight(options.height or 22)
        button:SetPoint(position, parent, position, offset[1], offset[2])
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
            position = 'TOPLEFT',
            offset = {5, 15}
        }
    })

    local selectedSpell = nil

    for i = 1, 60 do
        listSpells[i] = createButton(listFrame, 'TOP', {0, -(i - 1) * 16}, '', {
            width = 192,
            height = 15,
            template = true,
            topText = {text = '', position = 'CENTER', offset = {0, 0}},
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
            table.remove(list, selectedSpell.Number)
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
            position = 'TOPLEFT',
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

    -- кнопка загрузки настроек сохраненных в кэше
    local loadSettingsButton = createButton(settingFrame, 'TOPRIGHT', {-145, -30}, 'Load', {
        topText = {
            size = 10,
            text = 'Load saving blacklist'
        }
    })
    loadSettingsButton:SetScript('OnClick', function()
        list = utils.clone(commonSaves)
        initListFrame()
    end)

    -- кнопки сохранения настроек в кэш
    local saveSettingsButton = createButton(settingFrame, 'TOPRIGHT', {-260, -30}, 'Save', {
        topText = {
            size = 10,
            text = 'Save blacklist to cache'
            }
    })
    saveSettingsButton:SetScript('OnClick', function()
        commonSaves = utils.clone(list)
    end)

    -- кнопка восстановления стандартных настроек
    local defaultSettingsButton = createButton(settingFrame, 'TOPRIGHT', {-30, -30}, 'Default', {
        topText = {
            size = 10,
            text = 'Restore default blacklist'
        }
    })
    defaultSettingsButton:SetScript('OnClick', function()
        list = utils.clone(defaultBlacklist)
        initListFrame()
    end)

    settingFrame.okay = function()
        savedVariables:setCommon('blacklist', commonSaves)
        savedVariables:setCharacter('blacklist', list)
        initSettings()
    end

    settingFrame.cancel = function()
        initSettings()
        initListFrame()
    end 

    settingFrame.parent = 'TrufiGCD'

    --InterfaceOptions_AddCategory(settingFrame)

    blacklist.getSettingsFrame = function()
        return settingFrame
    end

    return blacklist;
end)
