TrufiGCD:define('profilesWidget', function()
    local settings = TrufiGCD:require('settings')
    local config = TrufiGCD:require('config')
    local utils = TrufiGCD:require('utils')

    local widget = {}

    local _idCounter = 0

    local currentProfileName = nil
    local profilesList = nil

    local function getDataFromSettings()
        currentProfileName = settings:getName()
        profilesList = settings:getProfilesList()
    end

    getDataFromSettings()
    settings:on('change', getDataFromSettings)

    -- simple profile manager
    -- only dropdown menu
    local WidgetSimple = {}

    function WidgetSimple:new(options)
        local obj = {}

        _idCounter = _idCounter + 1

        obj.id = _idCounter

        self.__index = self

        local metatable = setmetatable(obj, self)

        metatable:create(options)

        settings:on('change', function() metatable:update() end)

        return metatable
    end

    function WidgetSimple:create(options)
        self.frame = CreateFrame('Frame', nil, options.parentFrame)
        self.frame:SetPoint(options.point, options.offset[1], options.offset[2])
        self.frame:SetWidth(200)
        self.frame:SetHeight(30)

        self.frameDropdownCurrent = CreateFrame('Frame', 'TrGCDProfilesWidgetDropdown' .. self.id, self.frame, 'UIDropDownMenuTemplate')
        self.frameDropdownCurrent:SetPoint('TOPLEFT', 0, 0)

        UIDropDownMenu_SetWidth(self.frameDropdownCurrent, 200)
        UIDropDownMenu_SetText(self.frameDropdownCurrent, currentProfileName)
        UIDropDownMenu_Initialize(self.frameDropdownCurrent, function() self:initMenu() end)
    end

    function WidgetSimple:update()
        UIDropDownMenu_SetText(self.frameDropdownCurrent, currentProfileName)
    end

    function WidgetSimple:initMenu()
        local info = UIDropDownMenu_CreateInfo()

        for i, el in pairs(profilesList) do
            info.text = el
            info.menuList = i
            info.func = function() self:menuItemOnClick(el) end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info)
        end
    end

    function WidgetSimple:menuItemOnClick(profileName)
        if currentProfileName == profileName then return end

        settings:setCurrentProfile(profileName)
    end


    -- profile manager
    -- dropdown, and delete button
    -- editbox and Create new button
    local ProfileManager = {}

    function ProfileManager:new(options)
        local obj = {}

        _idCounter = _idCounter + 1

        obj.id = _idCounter

        self.__index = self

        local metatable = setmetatable(obj, self)

        metatable:create(options)

        settings:on('change', function() metatable:update() end)

        return metatable
    end

    function ProfileManager:create(options)
        self.frame = CreateFrame('Frame', nil, options.parentFrame)
        self.frame:SetPoint(options.point, options.offset[1], options.offset[2])
        self.frame:SetWidth(400)
        self.frame:SetHeight(300)

        self.frameDropdownCurrent = CreateFrame('Frame', 'TrGCDProfilesWidgetDropdown' .. self.id, self.frame, 'UIDropDownMenuTemplate')
        self.frameDropdownCurrent:SetPoint('TOPLEFT', 0, 0)

        UIDropDownMenu_SetWidth(self.frameDropdownCurrent, 200)
        UIDropDownMenu_SetText(self.frameDropdownCurrent, currentProfileName)
        UIDropDownMenu_Initialize(self.frameDropdownCurrent, function() self:initMenu() end)

        -- delete confirm frame
        self.frameConfirmDelete = CreateFrame('Frame', 'TrGCDProfilesWidgetConfirm' .. self.id, options.parentFrame, 'OptionsBoxTemplate')
        self.frameConfirmDelete:Hide()
        self.frameConfirmDelete:SetPoint('CENTER', 0, 0)
        self.frameConfirmDelete:SetWidth(230)
        self.frameConfirmDelete:SetHeight(60)
        self.textureConfirmDelete = self.frameConfirmDelete:CreateTexture(nil, 'BACKGROUND')
        self.textureConfirmDelete:SetAllPoints(self.frameConfirmDelete)
        self.textureConfirmDelete:SetColorTexture(0, 0, 0)
        self.textureConfirmDelete:SetAlpha(0.8)

        self.textConfirmDelete = self.frameConfirmDelete:CreateFontString(nil, 'BACKGROUND')
        self.textConfirmDelete:SetFont('Fonts\\FRIZQT__.TTF', 12)
        self.textConfirmDelete:SetText('Confirm delete')
        self.textConfirmDelete:SetPoint('TOP', 0, -10)

        self.buttonConfirmDeleteYes = CreateFrame('Button', nil, self.frameConfirmDelete, 'UIPanelButtonTemplate')
        self.buttonConfirmDeleteYes:SetWidth(100)
        self.buttonConfirmDeleteYes:SetHeight(22)
        self.buttonConfirmDeleteYes:SetPoint('TOP', 55, -30)
        self.buttonConfirmDeleteYes:SetText('Yes')
        self.buttonConfirmDeleteYes:SetScript('OnClick', function() self:deleteProfile() end)

        self.buttonConfirmDeleteNo = CreateFrame('Button', nil, self.frameConfirmDelete, 'UIPanelButtonTemplate')
        self.buttonConfirmDeleteNo:SetWidth(100)
        self.buttonConfirmDeleteNo:SetHeight(22)
        self.buttonConfirmDeleteNo:SetPoint('TOP', -55, -30)
        self.buttonConfirmDeleteNo:SetText('No')
        self.buttonConfirmDeleteNo:SetScript('OnClick', function() self:closeFrameConfirm() end)

        -- delete button
        self.buttonDelete = CreateFrame('Button', nil, self.frame, 'UIPanelButtonTemplate')
        self.buttonDelete:SetWidth(100)
        self.buttonDelete:SetHeight(22)
        self.buttonDelete:SetPoint('TOPLEFT', 240, -3)
        self.buttonDelete:SetText('Delete')
        self.buttonDelete:SetScript('OnClick', function() self:deleteOnClick() end)

        -- editbox
        self.exitboxNewProfile = CreateFrame('EditBox', nil, self.frame, 'InputBoxTemplate')
        self.exitboxNewProfile:SetWidth(210)
        self.exitboxNewProfile:SetHeight(20)
        self.exitboxNewProfile:SetPoint('TOPLEFT', 23, -40)
        self.exitboxNewProfile:SetAutoFocus(false)

        -- create new button
        self.buttonCreateNew = CreateFrame('Button', nil, self.frame, 'UIPanelButtonTemplate')
        self.buttonCreateNew:SetWidth(100)
        self.buttonCreateNew:SetHeight(22)
        self.buttonCreateNew:SetPoint('TOPLEFT', 240, -40)
        self.buttonCreateNew:SetText('Create new')
        self.buttonCreateNew:SetScript('OnClick', function() self:createOnClick() end)

        -- rename button
        self.buttonRename = CreateFrame('Button', nil, self.frame, 'UIPanelButtonTemplate')
        self.buttonRename:SetWidth(100)
        self.buttonRename:SetHeight(22)
        self.buttonRename:SetPoint('TOPLEFT', 350, -40)
        self.buttonRename:SetText('Rename')
        self.buttonRename:SetScript('OnClick', function() self:renameOnClick() end)
    end

    function ProfileManager:initMenu()
        local info = UIDropDownMenu_CreateInfo()

        for i, el in pairs(profilesList) do
            info.text = el
            info.menuList = i
            info.func = function() self:menuItemOnClick(el) end
            info.notCheckable = true

            UIDropDownMenu_AddButton(info)
        end
    end

    function ProfileManager:update()
        UIDropDownMenu_SetText(self.frameDropdownCurrent, currentProfileName)
    end

    function ProfileManager:menuItemOnClick(profileName)
        if currentProfileName == profileName then return end

        settings:setCurrentProfile(profileName)
    end

    function ProfileManager:deleteProfile()
        self.frameConfirmDelete:Hide()
        settings:deleteProfile(currentProfileName)
    end

    function ProfileManager:closeFrameConfirm()
        self.frameConfirmDelete:Hide()
    end

    function ProfileManager:deleteOnClick()
        self.frameConfirmDelete:Show()
    end

    function ProfileManager:createOnClick()
        local name = self.exitboxNewProfile:GetText()

        if not name then return end

        if utils.contain(profilesList, name) then name = name .. 'New' end

        settings:createProfile(name, settings:get())
        settings:setCurrentProfile(name)
    end

    function ProfileManager:renameOnClick()
        local name = self.exitboxNewProfile:GetText()

        if not name then return end

        if utils.contain(profilesList, name) then name = name .. 'Rename' end

        settings:rename(name)
    end


    widget.simple = function(options)
        return WidgetSimple:new(options)
    end

    widget.full = function(options)
        return ProfileManager:new(options)
    end

    return widget
end)
