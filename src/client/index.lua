LogLevel = {
    ["INFO"] = "INFO",
    ["WARN"] = "WARN",
    ["ERROR"] = "ERROR"
}

exports('GetKeyString', function(keyID)
    if not keyID then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'keyID param in GetKeyStringFromKeyID is nil')
        return
    end

    if IsUsingKeyboard(0) then
        return KeyboardKeys[keyID] or '(NONE)'
    else
        return ControllerKeys[keyID] or '(NONE)'
    end
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

        if ped == PlayerPedId() then goto continue end

        if dist <= maxDistance and dist < closestDist then
            if searchType == 'players' and isPlayer or searchType == 'npcs' and not isPlayer or searchType == 'both' then
                closestPed, closestDist, closestCoords = ped, dist, pedCoords
            end
        end

        ::continue::
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
    local dist = 9999

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

    if dist < maxDistance then
        return nearest, dist
    end

    return nil, nil
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

-- Return the current zone name the player is in
exports('GetCurrentZone', function()
    local coords = GetEntityCoords(PlayerPedId())
    local zoneHash = GetNameOfZone(coords.x, coords.y, coords.z)
    return GetLabelText(zoneHash)
end)

-- Check if a target entity is within a certain distance
-- If fromEntity is omitted the player's ped is used
exports('IsEntityWithinDistance', function(targetEntity, maxDistance, fromEntity)
    if not targetEntity or not DoesEntityExist(targetEntity) then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'targetEntity param in IsEntityWithinDistance is invalid')
        return false, nil
    elseif not maxDistance then
        exports['FS-Lib']:LogMessage(GetInvokingResource(), 'maxDistance param in IsEntityWithinDistance is nil')
        return false, nil
    end

    fromEntity = fromEntity or PlayerPedId()
    local fromCoords = GetEntityCoords(fromEntity)
    local targetCoords = GetEntityCoords(targetEntity)
    local dist = #(fromCoords - targetCoords)

    return dist <= maxDistance, dist
end)

-- Simple wrapper around DrawMarker for world coordinates
exports('DrawMarker3D', function(markerType, x, y, z, sx, sy, sz, r, g, b, a)
    markerType = markerType or 1
    DrawMarker(markerType, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, sx or 1.0, sy or 1.0, sz or 1.0, r or 255, g or 255, b or 255, a or 255, false, false, 2, false, '', '', false)
end)

exports('LogMessage', function(invokingResource, message, logLevel)
    local logPrefixes = {
        [LogLevel["INFO"]] = "^2[INFO]",
        [LogLevel["WARN"]] = "^3[WARN]",
        [LogLevel["ERROR"]] = "^1[ERROR]",
    }

    logLevel = logLevel or LogLevel.ERROR

    local logPrefix = logPrefixes[logLevel] or logPrefixes[LogLevel.ERROR]

    local formattedMessage = string.format("%s [Invoking Resource: %s] %s", logPrefix, invokingResource, message)

    print(formattedMessage)
end)
