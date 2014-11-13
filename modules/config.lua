TrufiGCD:define('config', function()
    local config = {}

    config.timeGcd = 1.6

    config.fastSpeedModificator = 3

    config.minTimeInterval = 0.03

    config.unitNames = {
        'player',
        'party1', 'party2', 'party3', 'party4',
        'arena1', 'arena2', 'arena3', 'arena4', 'arena5',
        'target', 'focus'
    }

    config.unitText = {
        player = 'Player',
        party1 = 'Party 1',
        party2 = 'Party 2',
        party3 = 'Party 3',
        party4 = 'Party 4',
        arena1 = 'Arena 1',
        arena2 = 'Arena 2',
        arena3 = 'Arena 3',
        arena4 = 'Arena 4',
        arena5 = 'Arena 5',
        target = 'Target',
        focus = 'Focus'
    }

    config.directionsList = {'Left', 'Right', 'Top', 'Down'}

    -- list of buff of instance spells
    config.instanceSpellBuffs = {
        -- Pyroblast! - Pyroblast
        [48108] = {11366},
        -- Shooting Stars - Starsurge
        [93400] = {78674},
        -- Predatory Swiftness - Entangling Roots, Cyclone, Healing Touch, Rebirth
        [69369] = {339, 33786, 5185, 20484},
        -- Glyph of Mind Spike - Mind Blast
        [81292] = {8092},
        -- Surge of Darkness - Mind Spike
        [87160] = {87160},
        -- Surge of Light - Flash Heal
        [114255] = {2061},
        -- Shadowy Insight - Mind Blast
        [124430] = {8092}
    } 

    return config
end)
