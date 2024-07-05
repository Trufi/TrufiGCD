---@type string, Namespace
local _, ns = ...

---@class FrameUtils
local frameUtils = {}
ns.frameUtils = frameUtils

---@class CheckButtonOptions
---@field frame any
---@field x number
---@field y number
---@field position Point
---@field text string
---@field name string
---@field checked boolean
---@field tooltip? string
---@field onClick fun(button: any): nil

---@param opts CheckButtonOptions
frameUtils.createCheckButton = function(opts)
    local button = CreateFrame("CheckButton", opts.name, opts.frame, "ChatConfigCheckButtonTemplate")
    button:SetPoint(opts.position, opts.x, opts.y)
    button:SetChecked(opts.checked)
    _G[opts.name .. 'Text']:SetText(opts.text)
    button:SetScript("OnEnter", function(self)
        if opts.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(opts.tooltip, nil, nil, nil, nil, 1)
        end
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    button:SetScript("OnClick", function()
        opts.onClick(button)
    end)
    return button
end
