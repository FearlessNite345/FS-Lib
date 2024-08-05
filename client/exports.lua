-- FS-Lib: Utility Functions for FiveM

-- Constants
local MOVE_SPEED = 0.01
local VERTICAL_SPEED = 0.01
local ROTATE_SPEED = 0.7

exports('GetKeyStringFromKeyID', function(keyID)
    if not keyID then
        LogMessage('keyID param in GetKeyStringFromKeyID is nil', false, false, LogLevel.ERROR)
        return
    end

    if IsUsingKeyboard(0) then
        return Keys[keyID] or '(NONE)', 0
    else
        return ControllerKeys[keyID] or '(NONE)', 1
    end
end)

-- Get the closest object within a certain distance
exports('GetClosestObjectWithinDist', function(maxDistance, objects)
    if not maxDistance then
        LogMessage('maxDistance param in GetClosestObjectWithinDist is nil', false, false, LogLevel.ERROR)
        return
    elseif not objects then
        LogMessage('objects param in GetClosestObjectWithinDist is nil', false, false, LogLevel.ERROR)
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed, false)

    local closestObjectCoords, closestObjectHandle
    local closestDistance = maxDistance + 1

    local function checkAndUpdateClosest(objectHash)
        local objectHandle = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, maxDistance, objectHash, false, false, false)
        if DoesEntityExist(objectHandle) then
            local objectCoords = GetEntityCoords(objectHandle, false)
            local distance = #(playerCoords - objectCoords)
            if distance <= maxDistance and distance < closestDistance then
                closestObjectCoords = objectCoords
                closestObjectHandle = objectHandle
                closestDistance = distance
            end
        end
    end

    if type(objects) == "table" then
        for _, objectHash in ipairs(objects) do
            checkAndUpdateClosest(objectHash)
        end
    else
        checkAndUpdateClosest(objects)
    end

    return closestObjectCoords, closestObjectHandle
end)

-- Get the closest pedestrian within a certain distance
-- Specify searchType as "players" to find only real players or "npcs" to find only NPCs
exports('GetClosestPedWithinDist', function(maxDistance, searchType)
    if not maxDistance then
        LogMessage('maxDistance param in GetClosestPedWithinDist is nil', false, false, LogLevel.ERROR)
        return
    elseif not searchType then
        LogMessage('searchType param in GetClosestPedWithinDist is nil', false, false, LogLevel.ERROR)
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed, false)

    local closestPed, closestDistance = nil, maxDistance + 1

    local function EnumeratePeds()
        return coroutine.wrap(function()
            local handle, ped = FindFirstPed()
            local success
            repeat
                if not IsEntityDead(ped) then
                    coroutine.yield(ped)
                end
                success, ped = FindNextPed(handle)
            until not success
            EndFindPed(handle)
        end)
    end

    for ped in EnumeratePeds() do
        if ped ~= playerPed then
            local isPlayer = IsPedAPlayer(ped)
            local pedCoords = GetEntityCoords(ped, false)
            local distance = #(playerCoords - pedCoords)

            if distance <= maxDistance and distance < closestDistance then
                if searchType == 'players' and isPlayer or searchType == 'npcs' and not isPlayer or searchType == 'both' then
                    closestPed, closestDistance = ped, distance
                end
            end
        end
    end

    return closestPed, closestDistance
end)

exports('GetObjectsWithinDist', function(maxDistance, objects)
    if not maxDistance then
        LogMessage('maxDistance param in GetObjectsWithinDist is nil', false, false, LogLevel.ERROR)
        return
    elseif not objects then
        LogMessage('objects param in GetObjectsWithinDist is nil', false, false, LogLevel.ERROR)
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed, false)

    local objectsWithinDist = {}

    local function checkAndUpdateClosest(objectHash)
        local objectHandle = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, maxDistance, objectHash, false, false, false)
        if DoesEntityExist(objectHandle) then
            local objectCoords = GetEntityCoords(objectHandle, false)
            local distance = #(playerCoords - objectCoords)
            if distance <= maxDistance then
                table.insert(objectsWithinDist, { object = objectHandle, objectCoords = objectCoords, objectDist = distance })
            end
        end
    end

    if type(objects) == "table" then
        for _, objectHash in ipairs(objects) do
            checkAndUpdateClosest(objectHash)
        end
    else
        checkAndUpdateClosest(objects)
    end

    return objectsWithinDist
end)

exports('GetPedsWithinDist', function(maxDistance, searchType)
    if not maxDistance then
        LogMessage('maxDistance param in GetPedsWithinDist is nil', false, false, LogLevel.ERROR)
        return
    elseif not searchType then
        LogMessage('searchType param in GetPedsWithinDist is nil', false, false, LogLevel.ERROR)
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed, false)

    local pedsWithinDist = {}

    local function EnumeratePeds()
        return coroutine.wrap(function()
            local handle, ped = FindFirstPed()
            local success
            repeat
                if not IsEntityDead(ped) then
                    coroutine.yield(ped)
                end
                success, ped = FindNextPed(handle)
            until not success
            EndFindPed(handle)
        end)
    end

    for ped in EnumeratePeds() do
        if ped ~= playerPed then
            local isPlayer = IsPedAPlayer(ped)
            local pedCoords = GetEntityCoords(ped, false)
            local distance = #(playerCoords - pedCoords)

            if distance <= maxDistance then
                if searchType == 'players' and isPlayer or searchType == 'npcs' and not isPlayer or searchType == 'both' then
                    table.insert(pedsWithinDist, { ped = ped, distance = distance })
                end
            end
        end
    end

    return pedsWithinDist
end)

-- Load and set up a model
exports('SetupModel', function(object)
    if not object then
        LogMessage('object param in SetupModel is nil', false, false, LogLevel.ERROR)
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

    local previewObject = CreateObject(object, position.x, position.y, position.z, true, true, false)
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
        LogMessage('object param in PlaceObject is nil', false, false, LogLevel.ERROR)
        return
    elseif not position then
        LogMessage('position param in PlaceObject is nil', false, false, LogLevel.ERROR)
        return
    elseif not rotation then
        LogMessage('rotation param in PlaceObject is nil', false, false, LogLevel.ERROR)
        return
    end

    local previewObject = CreatePreviewObject(object, position, rotation)
    ControlPlacement(previewObject, callback)
end)

-- Convert heading to cardinal direction
exports('HeadingToCardinal', function(heading)
    if not heading then
        LogMessage('heading param in HeadingToCardinal is nil', false, false, LogLevel.ERROR)
        return
    end
    
    local directions = { 'N', 'NW', 'W', 'SW', 'S', 'SE', 'E', 'NE', 'N' }
    local normalizedHeading = ((heading % 360) + 360) % 360
    local index = math.floor((normalizedHeading + 22.5) / 45)
    return directions[index + 1]
end)
