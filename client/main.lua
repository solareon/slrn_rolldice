local config = require 'config.shared'

local function distCheck(location)
    local coords = GetEntityCoords(cache.ped, false)
	local dist = #(location - coords)

	if dist > config.maxDistance then
        return false
    end
    return true
end

local function createFlipString(flipTable)
    local text = 'Flip: '
    for k, roll in pairs(flipTable) do
        local side = roll == 1 and 'Heads' or 'Tails'
        if k == 1 then
            text = text .. side
        else
            text = text .. ' | ' .. side
        end
    end

    return text
end

local function createRollString(rollTable, sides)
    local text = 'Roll: '
    local total = 0

    for k, roll in pairs(rollTable) do
        total = total + roll
        if k == 1 then
            text = text .. roll .. '/' .. sides
        else
            text = text .. ' | ' .. roll .. '/' .. sides
        end
    end

    text = text .. ' | (Total: '..total..')'
    return text
end

local function requestAnimDictLoad(animDict)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(0)
    end
end

local function diceRollAnimation(animDict)
    TaskPlayAnim(cache.ped, animDict ,'wank' ,8.0, -8.0, -1, 49, 0, false, false, false)
    Wait(2400)
    ClearPedTasks(cache.ped)
end

local function flipCoinAnimation(animDict)
    TaskPlayAnim(cache.ped, animDict ,'coin_roll_and_toss' ,8.0, -8.0, -1, 49, 0, false, false, false)
    Wait(4800)
    ClearPedTasks(cache.ped)
end

local function showRoll(text, sourceId)
    local currentCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(GetPlayerFromServerId(sourceId)), 0.0, 1.5, -0.7)
    CreateThread(function()
        local displayTime = config.showTime * 1000 + GetGameTimer()
        while displayTime > GetGameTimer() do
            DrawText3D(text, currentCoords)
            Wait(0)
        end
    end)
end

local function showFlip(text, sourceId)
    CreateThread(function()
        local displayTime = config.showTime * 1000 + GetGameTimer()
        while displayTime > GetGameTimer() do
            local currentCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(GetPlayerFromServerId(sourceId)), 0.0, 0.5, 0.4)
            DrawText3D(text, currentCoords)
            Wait(0)
        end
    end)
end

RegisterNetEvent('slrn-rolldice:client:rollDice', function(sourceId, rollTable, sides, location)
    if not distCheck(location) then return end
	local rollString = createRollString(rollTable, sides)
    SetTimeout(2200, function()
        showRoll(rollString, sourceId)
    end)
	if cache.serverId == sourceId then
        local animDict = 'anim@mp_player_intcelebrationmale@wank'
        requestAnimDictLoad(animDict)
        diceRollAnimation(animDict)
        if config.giveCoinSlip then lib.callback('slrn-rolldice:server:getNote', false, function () end, 'roll', rollString) end
	end
	
end)

RegisterNetEvent('slrn-rolldice:client:flipCoin', function(sourceId, flipTable, _, location)
    if not distCheck(location) then return end
	local flipString = createFlipString(flipTable)
    SetTimeout(3050, function()
        showFlip(flipString, sourceId)
    end)
	if cache.serverId == sourceId then
        local animDict = 'anim@mp_player_intcelebrationmale@coin_roll_and_toss'
        requestAnimDictLoad(animDict)
        flipCoinAnimation(animDict)
        if config.giveFlipSlip then lib.callback('slrn-rolldice:server:getNote', false, function () end, 'flip', flipString) end
	end
end)

exports.ox_inventory:displayMetadata({
    diceRoll = 'Roll',
    coinFlip = 'Flip'
})