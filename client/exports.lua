-- FS-Lib: Utility Functions for FiveM

-- Constants
local MOVE_SPEED = 0.01
local VERTICAL_SPEED = 0.01
local ROTATE_SPEED = 0.7

exports('GetKeyString', function(keyID)
    if not keyID then
        LogMessage(GetInvokingResource(), 'keyID param in GetKeyStringFromKeyID is nil', false, false)
        return
    end

    return Keys[keyID] or '(NONE)'
end)

-- Get the closest object within a certain distance
exports('GetClosestObject', function(maxDistance)
    if not maxDistance then
        LogMessage(GetInvokingResource(), 'maxDistance param in GetClosestObjectWithinDist is nil', false, false)
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
        LogMessage(GetInvokingResource(), 'maxDistance param in GetClosestPedWithinDist is nil', false, false)
        return
    elseif not searchType then
        LogMessage(GetInvokingResource(), 'searchType param in GetClosestPedWithinDist is nil', false, false)
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
        LogMessage(GetInvokingResource(), 'maxDistance param in GetClosestVehicleWithinDist is nil', false, false)
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
        LogMessage(GetInvokingResource(), 'maxDistance param in GetClosestTrailer is nil', false, false)
        return nil, nil, nil
    end

    local playerPed = PlayerPedId()
    local playerVehicle = GetVehiclePedIsIn(playerPed, false)

    if not playerVehicle or playerVehicle == 0 then
        LogMessage(GetInvokingResource(), 'Player is not in a vehicle', false, false)
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
        LogMessage(GetInvokingResource(), 'maxDistance param in GetObjectsWithinDist is nil', false, false)
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
        LogMessage(GetInvokingResource(), 'maxDistance param in GetPedsWithinDist is nil', false, false)
        return
    elseif not searchType then
        LogMessage(GetInvokingResource(), 'searchType param in GetPedsWithinDist is nil', false, false)
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
        LogMessage(GetInvokingResource(), 'maxDistance param in GetPedsWithinDist is nil', false, false)
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
        LogMessage(GetInvokingResource(), 'object param in SetupModel is nil', false, false)
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

-- Create a preview object for placement
local function CreatePreviewObject(object, position, rotation)
    RequestModel(object)
    while not HasModelLoaded(object) do
        Citizen.Wait(0)
    end

    local previewObject = CreateObject(object, position.x, position.y, position.z, false, true, false)
    SetEntityRotation(previewObject, rotation.x, rotation.y, rotation.z, 2, true)
    SetEntityAlpha(previewObject, 100, false)
    SetEntityCollision(previewObject, false, false)

    return previewObject
end

-- Update the position of a object
local function UpdateObjectPosition(previewObject, position, rotation)
    SetEntityCoords(previewObject, position.x, position.y, position.z, true, true, true, false)
    SetEntityRotation(previewObject, rotation.x, rotation.y, rotation.z, 2, true)
end

-- Display keybind hints for object placement
local function DisplayKeybindHints(scaleform)
    BeginScaleformMovieMethod(scaleform, "CLEAR_ALL")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamTextureNameString("~INPUT_FRONTEND_RRIGHT~")
    ScaleformMovieMethodAddParamTextureNameString("Cancel Placement")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(1)
    ScaleformMovieMethodAddParamTextureNameString("~INPUT_FRONTEND_RDOWN~")
    ScaleformMovieMethodAddParamTextureNameString("Confirm Placement")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(2)
    ScaleformMovieMethodAddParamTextureNameString("~INPUT_PICKUP~")
    ScaleformMovieMethodAddParamTextureNameString("~INPUT_CONTEXT_SECONDARY~")
    ScaleformMovieMethodAddParamTextureNameString("Rotate")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(3)
    ScaleformMovieMethodAddParamTextureNameString("~INPUT_SCRIPTED_FLY_ZUP~")
    ScaleformMovieMethodAddParamTextureNameString("~INPUT_SCRIPTED_FLY_ZDOWN~")
    ScaleformMovieMethodAddParamTextureNameString("Up/Down")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(4)
    ScaleformMovieMethodAddParamTextureNameString("~INPUT_CELLPHONE_UP~")
    ScaleformMovieMethodAddParamTextureNameString("~INPUT_CELLPHONE_DOWN~")
    ScaleformMovieMethodAddParamTextureNameString("~INPUT_CELLPHONE_LEFT~")
    ScaleformMovieMethodAddParamTextureNameString("~INPUT_CELLPHONE_RIGHT~")
    ScaleformMovieMethodAddParamTextureNameString("Move")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    ScaleformMovieMethodAddParamInt(0)
    EndScaleformMovieMethod()

    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
end

-- Control object placement with keyboard input
local function ControlPlacement(previewObject, callback)
    Citizen.CreateThread(function()
        local currentPos = GetEntityCoords(previewObject, false)
        local currentRot = GetEntityRotation(previewObject, 2)
        local currentZRot = currentRot.z

        local scaleform = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS")
        while not HasScaleformMovieLoaded(scaleform) do
            Citizen.Wait(0)
        end

        while true do
            Citizen.Wait(0)

            DisplayKeybindHints(scaleform)

            if IsControlPressed(0, 172) then
                currentPos = vector3(currentPos.x, currentPos.y + MOVE_SPEED, currentPos.z)
            end
            if IsControlPressed(0, 173) then
                currentPos = vector3(currentPos.x, currentPos.y - MOVE_SPEED, currentPos.z)
            end
            if IsControlPressed(0, 174) then
                currentPos = vector3(currentPos.x - MOVE_SPEED, currentPos.y, currentPos.z)
            end
            if IsControlPressed(0, 175) then
                currentPos = vector3(currentPos.x + MOVE_SPEED, currentPos.y, currentPos.z)
            end

            if IsControlPressed(0, 10) then
                currentPos = vector3(currentPos.x, currentPos.y, currentPos.z + VERTICAL_SPEED)
            end
            if IsControlPressed(0, 11) then
                currentPos = vector3(currentPos.x, currentPos.y, currentPos.z - VERTICAL_SPEED)
            end

            if IsControlPressed(0, 52) then
                currentZRot -= ROTATE_SPEED
            end
            if IsControlPressed(0, 38) then
                currentZRot += ROTATE_SPEED
            end

            if currentZRot < 0 then
                currentZRot += 360
            elseif currentZRot >= 360 then
                currentZRot -= 360
            end

            currentRot = vector3(currentRot.x, currentRot.y, currentZRot)

            UpdateObjectPosition(previewObject, currentPos, currentRot)

            if IsControlJustPressed(0, 191) then
                SetEntityAlpha(previewObject, 255, false)
                SetEntityCollision(previewObject, true, true)
                FreezeEntityPosition(previewObject, true)
                if callback then
                    callback(true, previewObject, currentPos, currentRot)
                end
                break
            end

            if IsControlJustPressed(0, 194) then
                DeleteEntity(previewObject)
                if callback then
                    callback(false)
                end
                break
            end
        end
    end)
end

-- Place a object at a specified position with keyboard control
exports('PlaceObject', function(object, position, rotation, callback)
    if not object then
        LogMessage(GetInvokingResource(), 'object param in PlaceObject is nil', false, false)
        return
    elseif not position then
        LogMessage(GetInvokingResource(), 'position param in PlaceObject is nil', false, false)
        return
    elseif not rotation then
        LogMessage(GetInvokingResource(), 'rotation param in PlaceObject is nil', false, false)
        return
    end

    local previewObject = CreatePreviewObject(object, position, rotation)
    ControlPlacement(previewObject, callback)
end)

-- Convert heading to cardinal direction
exports('HeadingToCardinal', function(heading)
    if not heading then
        LogMessage(GetInvokingResource(), 'heading param in HeadingToCardinal is nil', false, false)
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
