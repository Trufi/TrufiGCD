-- TrufiGCD stevemyz@gmail.com

local modules = {}

TrufiGCD = {
    define = function(self, name, module)
        modules[name] = module()
    end,

    require = function(self, name)
        return modules[name]
    end
}
