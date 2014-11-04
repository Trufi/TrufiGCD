TrufiGCD:define('eventEmitter', function()
    local Emitter = {}

    function Emitter:new()
        local obj = {}

        obj.events = {}
        obj.idCounter = 0;

        self.__index = self
        return setmetatable(obj, self)
    end

    function Emitter:on(name, callback)
        if type(self.events[name]) == 'nil' then
            self.events[name] = {}
        end

        self.idCounter = self.idCounter + 1;

        self.events[name][self.idCounter] = {
            id = self.idCounter,
            callback = callback
        }
    end

    function Emitter:once(name, callback)
        if type(self.events[name]) == 'nil' then
            self.events[name] = {}
        end

        self.idCounter = self.idCounter + 1;

        self.events[name][self.idCounter] = {
            id = self.idCounter,
            callback = callback,
            once = true
        }
    end

    function Emitter:emit(name, data)
        if self.events[name] then
            data = data or {}

            for i, el in pairs(self.events[name]) do
                el.callback(data)

                if el.once then
                    table.remove(self.events[name], el.id)
                end
            end
        end
    end

    return Emitter
end)
