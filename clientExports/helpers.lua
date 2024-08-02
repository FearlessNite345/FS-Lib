-- FS-Lib: Utility Functions for FiveM

-- Constants
local SEARCH_RADIUS = 10.0
local MOVE_SPEED = 0.01
local VERTICAL_SPEED = 0.01
local ROTATE_SPEED = 0.7

-- Get the closest model within a certain distance
function GetClosestModelWithinDistance(maxDistance, models)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed, false)

    local closestModelCoords, closestModelHandle
    local closestDistance = maxDistance + 1

    local function checkAndUpdateClosest(modelHash)
        local modelHandle = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, SEARCH_RADIUS, modelHash, false, false, false)
        if DoesEntityExist(modelHandle) then
            local modelCoords = GetEntityCoords(modelHandle, false)
            local distance = #(playerCoords - modelCoords)
            if distance <= maxDistance and distance < closestDistance then
                closestModelCoords = modelCoords
                closestModelHandle = modelHandle
                closestDistance = distance
            end
        end
    end

    if type(models) == "table" then
        for _, modelHash in ipairs(models) do
            checkAndUpdateClosest(modelHash)
        end
    else
        checkAndUpdateClosest(models)
    end

    return closestModelCoords, closestModelHandle
end

-- Get the closest pedestrian within a certain distance
function GetClosestPedWithinDistance(maxDistance)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed, false)

    local closestPed, closestDistance = nil, maxDistance + 1

    for ped in EnumeratePeds() do
        if ped ~= playerPed then
            local pedCoords = GetEntityCoords(ped, false)
            local distance = #(playerCoords - pedCoords)
            if distance <= maxDistance and distance < closestDistance then
                closestPed, closestDistance = ped, distance
            end
        end
    end

    return closestPed, closestDistance
end

-- Enumerate through all pedestrians
function EnumeratePeds()
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

-- Load and set up a model
function SetupModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
    SetModelAsNoLongerNeeded(model)
end

-- Generate a random number within a range, ensuring it's above a certain limit
function RandomLimited(min, max, limit)
    local result
    repeat
        result = math.random(min, max)
    until math.abs(result) >= limit
    return result
end

-- Draw a 3D notification
function DrawNotification3D(coords, text, seconds, color)
    local startTime = GetGameTimer()
    local duration = seconds * 1000

    while GetGameTimer() - startTime < duration do
        DrawText3D(coords.x, coords.y, coords.z, 0.6, '~' .. color .. '~' .. text)
        Citizen.Wait(0)
    end
end

-- Draw a 2D notification
function DrawNotification2D(text, seconds, color)
    local startTime = GetGameTimer()
    local duration = seconds * 1000

    while GetGameTimer() - startTime < duration do
        DrawText2D(0.5, 0.8, '~' .. color .. '~' .. text, 0.6, true)
        Citizen.Wait(0)
    end
end

-- Draw 3D text at specified coordinates
function DrawText3D(x, y, z, scale, text)
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
end

-- Draw 2D text at specified screen coordinates
function DrawText2D(x, y, text, scale, center)
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
end

-- Create a preview model for placement
local function CreatePreviewModel(model, position, rotation)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end

    local previewModel = CreateObject(model, position.x, position.y, position.z, true, true, false)
    SetEntityRotation(previewModel, rotation.x, rotation.y, rotation.z, 2, true)
    SetEntityAlpha(previewModel, 100, false)
    SetEntityCollision(previewModel, false, false)

    return previewModel
end

-- Update the position of a model
local function UpdateModelPosition(previewModel, position, rotation)
    SetEntityCoords(previewModel, position.x, position.y, position.z, true, true, true, false)
    SetEntityRotation(previewModel, rotation.x, rotation.y, rotation.z, 2, true)
end

-- Display keybind hints for model placement
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

-- Control model placement with keyboard input
local function ControlPlacement(previewModel, callback)
    Citizen.CreateThread(function()
        local currentPos = GetEntityCoords(previewModel, false)
        local currentRot = GetEntityRotation(previewModel, 2)
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

            UpdateModelPosition(previewModel, currentPos, currentRot)

            if IsControlJustPressed(0, 191) then
                SetEntityAlpha(previewModel, 255, false)
                SetEntityCollision(previewModel, true, true)
                FreezeEntityPosition(previewModel, true)
                if callback then
                    callback(true, previewModel, currentPos, currentRot)
                else
                    LogMessage('Callback for the PlaceModel export is nil', true, false, LogLevel.WARN)
                end
                break
            end

            if IsControlJustPressed(0, 194) then
                DeleteEntity(previewModel)
                if callback then
                    callback(false, nil)
                else
                    LogMessage('Callback for the PlaceModel export is nil', true, false, LogLevel.WARN)
                end
                break
            end
        end
    end)
end

-- Place a model at a specified position with keyboard control
function PlaceModel(model, position, rotation, callback)
    local previewModel = CreatePreviewModel(model, position, rotation)
    ControlPlacement(previewModel, callback)
end

-- Convert heading to cardinal direction
function HeadingToCardinal(heading)
    local directions = { 'N', 'NW', 'W', 'SW', 'S', 'SE', 'E', 'NE', 'N' }
    local normalizedHeading = ((heading % 360) + 360) % 360
    local index = math.floor((normalizedHeading + 22.5) / 45)
    return directions[index + 1]
end
