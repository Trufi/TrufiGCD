---@type string, Namespace
local _, ns = ...

---@class Settings
local Settings = {}
Settings.__index = Settings

local temporalProfileId = "-1"

function Settings:New()
    ---@class Settings
    local obj = setmetatable({}, Settings)

    obj.activeProfile = ns.ProfileSettings:New({
        id = temporalProfileId,
        name = "Default",
    })

    ---@type {[string]: ProfileSettings}
    obj.profiles = {
        [obj.activeProfile.id] = obj.activeProfile
    }

    return obj
end

function Settings:Load()
    ---@type CharacterSavedVariablesV0 | CharacterSavedVariablesV1
    TrufiGCDChSave = TrufiGCDChSave or {}

    ---@type GlobalSavedVariablesV0 | GlobalSavedVariablesV1
    TrufiGCDGlSave = TrufiGCDGlSave or {}

    self.profiles = {}

    -- Load only a new version of the global saved variables
    if type(TrufiGCDGlSave.profiles) == "table" then
        local newGlobalVariables = TrufiGCDGlSave --[[@as GlobalSavedVariablesV1]]
        for _, profileVariables in pairs(newGlobalVariables.profiles) do
            local profile = ns.ProfileSettings:New(profileVariables)
            self.profiles[profile.id] = profile
        end
    end

    -- Old version of the character saved variables
    if type(TrufiGCDChSave.TrGCDQueueFr) == "table" then
        local profile = ns.ProfileSettings:New(TrufiGCDChSave --[[@as CharacterSavedVariablesV0]])
        self.profiles[profile.id] = profile
        self.activeProfile = profile
    elseif type(TrufiGCDChSave.profileId) == "string" and self.profiles[TrufiGCDChSave.profileId] then
        self.activeProfile = self.profiles[TrufiGCDChSave.profileId]
    end

    if next(self.profiles) == nil then
        local defaultProfile = ns.ProfileSettings:New({
            id = ns.utils.uuid(),
            name = UnitName("player") .. " - " .. GetRealmName(),
        })
        self.profiles[defaultProfile.id] = defaultProfile
        self.activeProfile = defaultProfile
    end

    if self.activeProfile.id == temporalProfileId then
        if type(TrufiGCDGlSave.lastUsedProfileId) == "string" and self.profiles[TrufiGCDGlSave.lastUsedProfileId] then
            self.activeProfile = self.profiles[TrufiGCDGlSave.lastUsedProfileId]
        else
            local _, profile = next(self.profiles)
            self.activeProfile = profile
        end
    end

    self:Save()
end

function Settings:Save()
    ---@type GlobalSavedVariablesV1
    TrufiGCDGlSave = {
        version = 1,
        profiles = {},
        lastUsedProfileId = self.activeProfile.id,
    }

    for _, profile in pairs(self.profiles) do
        TrufiGCDGlSave.profiles[profile.id] = profile:GetSavedVariables()
    end

    ---@type CharacterSavedVariablesV1
    TrufiGCDChSave = {
        version = 1,
        profileId = self.activeProfile.id,
    }
end

---@param name string
function Settings:CreateNewProfile(name)
    local profile = ns.ProfileSettings:New(self.activeProfile:GetSavedVariables())
    profile.id = ns.utils.uuid()
    profile.name = name

    self.profiles[profile.id] = profile
    self.activeProfile = profile
end

function Settings:DeleteCurrentProfile()
    self.profiles[self.activeProfile.id] = nil

    if next(self.profiles) == nil then
        local defaultProfile = ns.ProfileSettings:New({
            id = ns.utils.uuid(),
            name = ns.utils.defaultProfileName(),
        })
        self.profiles[defaultProfile.id] = defaultProfile
        self.activeProfile = defaultProfile
    else
        local _, profile = next(self.profiles)
        self.activeProfile = profile
    end
end

ns.settings = Settings:New()
