TrufiGCD:define('config', function()
    local config = {}

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

    return config
end)
