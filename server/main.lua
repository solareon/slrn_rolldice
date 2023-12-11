local config = require 'config.shared'

lib.callback.register('slrn-rolldice:server:getNote', function(source, randomType, noteString)
    local metadata
    if randomType == 'roll' then 
        metadata = {
            label = 'Dice Roll Slip',
            diceRoll = string.sub(noteString, 7)
        }
    elseif randomType == 'flip' then
        metadata = {
            label = 'Coin Flip Slip',
            diceRoll = string.sub(noteString, 7)
        }
    end
    exports.ox_inventory:AddItem(source, 'stickynote', 1, metadata)
end)

RegisterServerEvent('slrn-rolldice:server:random', function(sourceId, dices, sides)
    local callerLoc = GetEntityCoords(GetPlayerPed(sourceId))
    local tabler = {}
    for i=1, dices do
        table.insert(tabler, math.random(1, sides))
    end
    local event = sides == 2 and 'slrn-rolldice:client:flipCoin' or 'slrn-rolldice:client:rollDice'
    TriggerClientEvent(event, -1, sourceId, tabler, sides, callerLoc)
end)

if config.useCommand then
    lib.addCommand(config.rollCommand, {
        params = {
            { name = 'sides', type = 'number', help = 'How many sides of dice - Max: '.. config.maxSides, optional = true},
            { name = 'dice', type = 'number', help = 'How many dice to roll - Max: '.. config.maxDices, optional = true},
        },
    }, function(source, args)
        local dice, sides = args.dice or 1, args.sides or 6
        if (sides > 2 and sides <= config.maxSides) and (dice > 0 and dice <= config.maxDices) then
            TriggerEvent('slrn-rolldice:server:random', source, dice, sides)
        else
            exports.qbx_core:Notify(source, 'Invalid amount. Try again')
        end
    end)
    lib.addCommand(config.flipCommand, {
        params = {
            { name = 'flips', type = 'number', help = 'How many coin flips - Max: '.. config.maxFlips, optional = true}
        },
    }, function(source, args)
        local flips = args.flips or 1
        if flips > 0 and flips <= config.maxFlips then
            TriggerEvent('slrn-rolldice:server:random', source, flips, 2)
        else
            exports.qbx_core:Notify(source, 'Invalid amount. Try again')
        end
    end)
end