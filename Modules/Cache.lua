---@type string, Namespace
local _, ns = ...

---@class Cache
local Cache = {}
Cache.__index = Cache
ns.Cache = Cache

---@generic T
---@param maxSize number
function Cache:New(maxSize)
    ---@class Cache
    local obj = setmetatable({}, Cache)

    ---@private
    ---@type number Maximum number of items in the cache
    obj.maxSize = maxSize

    ---@type { [string]: any } Table to store items by key
    obj.items = {}

    ---@type string[] Table to track insertion order (FIFO)
    obj.order = {}

    return obj
end

---@generic T
---@param key string
---@param item T
function Cache:Add(key, item)
    if self.items[key] ~= nil then
        -- If the key already exists, update its position in the order table
        for i, existingKey in ipairs(self.order) do
            if existingKey == key then
                table.remove(self.order, i)
                break
            end
        end
    elseif #self.order >= self.maxSize then
        -- If the key is new and the cache is full, remove the oldest item
        local oldestKey = table.remove(self.order, 1)
        self.items[oldestKey] = nil
    end

    -- Add the new key to the end of the order table
    table.insert(self.order, key)

    -- Store the item in the cache
    self.items[key] = item
end

---@generic T
---@param key string
---@return T | nil
function Cache:Get(key)
    return self.items[key]
end

function Cache:Clear()
    self.items = {}
    self.order = {}
end

--- Copy the contents of another Cache instance into this one
---@param other Cache
function Cache:Copy(other)
    self:Clear()
    self.maxSize = other.maxSize
    for _, key in ipairs(other.order) do
        self:Add(key, other.items[key])
    end
end
