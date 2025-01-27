-- FS-Lib: Utility Functions for FiveM

-- Constants
local MOVE_SPEED = 0.01
local VERTICAL_SPEED = 0.01
local ROTATE_SPEED = 0.7

exports('GetKeyString', function(keyID)
    if not keyID then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'keyID param in GetKeyStringFromKeyID is nil')
        return
    end

    return Keys[keyID] or '(NONE)'
end)

-- Get the closest object within a certain distance
exports('GetClosestObject', function(maxDistance)
    if not maxDistance then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'maxDistance param in GetClosestObjectWithinDist is nil')
        return
    end

    local playerCoords = GetEntityCoords(PlayerPedId(), false)
    local objPool = GetGamePool('CObject')
    local closestObj, closestDist, closestCoords = nil, 9999, nil

    for i = 1, #objPool do
        local obj = objPool[i]
        local objCoords = GetEntityCoords(obj, false)
        local dist = #(playerCoords - objCoords)

        if dist <= maxDistance and dist < closestDist then
            closestObj, closestDist, closestCoords = obj, dist, objCoords
        end
    end

    return closestObj, closestDist, closestCoords
end)

-- Get the closest pedestrian within a certain distance
-- Specify searchType as "players" to find only real players or "npcs" to find only NPCs
exports('GetClosestPed', function(maxDistance, searchType)
    if not maxDistance then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'maxDistance param in GetClosestPedWithinDist is nil')
        return
    elseif not searchType then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'searchType param in GetClosestPedWithinDist is nil')
        return
    end

    local playerCoords = GetEntityCoords(PlayerPedId(), false)
    local pedPool = GetGamePool('CPed')
    local closestPed, closestDist, closestCoords = nil, 9999, nil

    for i = 1, #pedPool do
        local ped = pedPool[i]
        local pedCoords = GetEntityCoords(ped, false)
        local dist = #(playerCoords - pedCoords)

        local isPlayer = IsPedAPlayer(ped)

        if dist <= maxDistance and dist < closestDist then
            if searchType == 'players' and isPlayer or searchType == 'npcs' and not isPlayer or searchType == 'both' then
                closestPed, closestDist, closestCoords = ped, dist, pedCoords
            end
        end
    end

    return closestPed, closestDist, closestCoords
end)

exports('GetClosestVehicle', function(maxDistance)
    if not maxDistance then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'maxDistance param in GetClosestVehicleWithinDist is nil')
        return
    end

    local playerCoords = GetEntityCoords(PlayerPedId(), false)
    local vehPool = GetGamePool('CVehicle')
    local closestVeh, closestDist, closestCoords = nil, 9999, nil

    for i = 1, #vehPool do
        local veh = vehPool[i]
        local vehCoords = GetEntityCoords(veh, false)
        local dist = #(playerCoords - vehCoords)

        if dist <= maxDistance and dist < closestDist then
            closestVeh, closestDist, closestCoords = veh, dist, vehCoords
        end
    end

    return closestVeh, closestDist, closestCoords
end)

exports('GetClosestTrailerToHitch', function(maxDistance)
    if not maxDistance then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'maxDistance param in GetClosestTrailer is nil')
        return nil, nil, nil
    end

    local playerPed = PlayerPedId()
    local playerVehicle = GetVehiclePedIsIn(playerPed, false)

    if not playerVehicle or playerVehicle == 0 then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'Player is not in a vehicle')
        return nil, nil, nil
    end

    local femaleCoords = GetEntityBonePosition_2(playerVehicle, GetEntityBoneIndexByName(playerVehicle, 'attach_female'))
    local nearest = nil
    local dist = maxDistance

    if not IsVehicleAttachedToTrailer(playerVehicle) then
        for _, veh in pairs(GetGamePool("CVehicle")) do
            if veh ~= playerVehicle then
                if GetEntityBoneIndexByName(veh, 'attach_male') ~= -1 then
                    local newDist = #(femaleCoords - GetEntityBonePosition_2(veh, GetEntityBoneIndexByName(veh, 'attach_male')))
                    if newDist < dist then
                        dist = newDist
                        nearest = veh
                    end
                end
            end
        end
    end

    if dist < 1.2 then
        return nearest, dist
    end

    return nil, nil
end)

exports('GetNearbyObjects', function(maxDistance)
    if not maxDistance then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'maxDistance param in GetObjectsWithinDist is nil')
        return
    end

    local playerCoords = GetEntityCoords(PlayerPedId(), false)
    local objPool = GetGamePool('CObject')
    local objects = {}

    for i = 1, #objPool do
        local obj = objPool[i]
        local objCoords = GetEntityCoords(obj, false)
        local dist = #(playerCoords - objCoords)

        if dist <= maxDistance then
            table.insert(objects, { object = obj, dist = dist, objCoords = objCoords })
        end
    end

    return objects
end)

exports('GetNearbyPeds', function(maxDistance, searchType)
    if not maxDistance then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'maxDistance param in GetPedsWithinDist is nil')
        return
    elseif not searchType then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'searchType param in GetPedsWithinDist is nil')
        return
    end

    local playerCoords = GetEntityCoords(PlayerPedId(), false)
    local pedPool = GetGamePool('CPed')
    local peds = {}

    for i = 1, #pedPool do
        local ped = pedPool[i]
        local pedCoords = GetEntityCoords(ped, false)
        local dist = #(playerCoords - pedCoords)

        local isPlayer = IsPedAPlayer(ped)

        if dist <= maxDistance then
            if searchType == 'players' and isPlayer or searchType == 'npcs' and not isPlayer or searchType == 'both' then
                table.insert(peds, { ped = ped, dist = dist, pedCoords = pedCoords })
            end
        end
    end

    return peds
end)

exports('GetNearbyVehicles', function(maxDistance)
    if not maxDistance then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'maxDistance param in GetPedsWithinDist is nil')
        return
    end

    local playerCoords = GetEntityCoords(PlayerPedId(), false)
    local vehPool = GetGamePool('CVehicle')
    local vehs = {}

    for i = 1, #vehPool do
        local veh = vehPool[i]
        local vehCoords = GetEntityCoords(veh, false)
        local dist = #(playerCoords - vehCoords)

        if dist <= maxDistance then
            table.insert(vehs, { vehicle = veh, dist = dist, vehCoords = vehCoords })
        end
    end

    return vehs
end)

-- Load and set up a model
exports('SetupModel', function(object)
    if not object then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'object param in SetupModel is nil')
        return
    end

    RequestModel(object)
    while not HasModelLoaded(object) do
        Citizen.Wait(0)
    end
    SetModelAsNoLongerNeeded(object)
end)

-- Draw 3D text at specified coordinates
exports('DrawText3D', function(x, y, z, scale, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(true)
        BeginTextCommandDisplayText("STRING")
        SetTextCentre(true)
        SetTextColour(255, 255, 255, 255)
        SetTextOutline()
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(_x, _y)
    end
end)

-- Draw 2D text at specified screen coordinates
exports('DrawText2D', function(x, y, text, scale, center)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    if center then SetTextJustification(0) end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end)

-- Convert heading to cardinal direction
exports('HeadingToCardinal', function(heading)
    if not heading then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'heading param in HeadingToCardinal is nil')
        return
    end

    local directions = { 'N', 'NW', 'W', 'SW', 'S', 'SE', 'E', 'NE', 'N' }
    local normalizedHeading = ((heading % 360) + 360) % 360
    local index = math.floor((normalizedHeading + 22.5) / 45)
    return directions[index + 1]
end)

exports('IsInInterior', function()
    local interior = GetInteriorFromEntity(PlayerPedId())

    if interior ~= 0 then
        return true
    else
        return false
    end
end)

exports('GetStreetName', function(x, y, z)
    local streetHash = GetStreetNameAtCoord(x, y, z)
    return GetStreetNameFromHashKey(streetHash)
end)

exports('IsVehicleEmpty', function(vehicle)
    -- Ensure the vehicle is valid
    if not DoesEntityExist(vehicle) then return false end

    -- Get the number of seats in the vehicle
    local maxSeats = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))

    -- Check each seat to see if it's occupied
    for seat = -1, maxSeats - 2 do
        if not IsVehicleSeatFree(vehicle, seat) then
            return false -- If any seat is occupied, the vehicle is not empty
        end
    end

    return true -- All seats are free, the vehicle is empty
end)

exports('Notify', function(message, duration, type)
    duration *= 1000 or 5000
    type = type or 'info'

    SendNUIMessage({
        action = 'FS-Lib:notify',
        msg = message,
        type = type,
        duration = duration
    })
end)

exports('LogMessage', function(invokingResource, message, logLevel)
    local logPrefixes = {
        [LogLevel["INFO"]] = "^2[INFO]",
        [LogLevel["WARN"]] = "^3[WARN]",
        [LogLevel["ERROR"]] = "^1[ERROR]",
    }

    logLevel = logLevel or LogLevel.ERROR

    local logPrefix = logPrefixes[logLevel] or logPrefixes[LogLevel.ERROR]

    local formattedMessage = string.format("%s [FS-Lib] [Invoking Resource: %s] %s", logPrefix, invokingResource, message)

    print(formattedMessage)
end)
