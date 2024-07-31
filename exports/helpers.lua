function GetClosestModelWithinDistance(maxDistance, models)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed, false)

    local closestModelCoords, closestModelHandle
    local closestDistance = maxDistance + 1

    -- Helper function to check and update the closest model
    local function checkAndUpdateClosest(modelHash)
        local modelHandle = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 10.0, modelHash, false,
            false, false)

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

    -- Check if models is a table of model data or a single model hash
    if type(models) == "table" then
        for _, modelHash in ipairs(models) do
            checkAndUpdateClosest(modelHash)
        end
    else
        -- If models is not a table, treat it as a single model hash
        checkAndUpdateClosest(models)
    end

    return closestModelCoords, closestModelHandle
end

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

function SetupModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
    SetModelAsNoLongerNeeded(model)
end

function RandomLimited(min, max, limit)
    local result
    repeat
        result = math.random(min, max)
    until math.abs(result) >= limit
    return result
end

function DrawNotification3D(coords, text, seconds, color)
    local startTime = GetGameTimer()
    local duration = seconds * 1000

    while GetGameTimer() - startTime < duration do
        DrawText3D(coords.x, coords.y, coords.z, 0.6, '~' .. color .. '~' .. text)
        Citizen.Wait(0)
    end
end

function DrawNotification2D(text, seconds, color)
    local startTime = GetGameTimer()
    local duration = seconds * 1000

    while GetGameTimer() - startTime < duration do
        DrawText2D(0.5, 0.8, '~' .. color .. '~' .. text, 0.6, true)
        Citizen.Wait(0)
    end
end

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

local function CreatePreviewModel(model, position, rotation)
    -- Load the model
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end

    -- Create the model
    local previewModel = CreateObject(model, position.x, position.y, position.z, true, true, false)
    SetEntityRotation(previewModel, rotation.x, rotation.y, rotation.z, 2, true)
    SetEntityAlpha(previewModel, 100, false)       -- Make the model see-through
    SetEntityCollision(previewModel, false, false) -- Disable collision

    return previewModel
end

local function UpdateModelPosition(previewModel, position, rotation)
    SetEntityCoords(previewModel, position.x, position.y, position.z, true, true, true, false)
    SetEntityRotation(previewModel, rotation.x, rotation.y, rotation.z, 2, true)
end

local function ControlPlacement(previewModel, callback)
    local moveSpeed = 1.0
    local verticalSpeed = 1.0

    Citizen.CreateThread(function()
        local currentPos = GetEntityCoords(previewModel, false)
        local currentRot = GetEntityRotation(previewModel, 2)

        while true do
            Citizen.Wait(0)

            -- Movement controls
            if IsControlPressed(0, 172) then     -- Arrow Up
                currentPos.y += moveSpeed
            elseif IsControlPressed(0, 173) then -- Arrow Down
                currentPos.y -= moveSpeed
            elseif IsControlPressed(0, 174) then -- Arrow Left
                currentPos.x -= moveSpeed
            elseif IsControlPressed(0, 175) then -- Arrow Right
                currentPos.x += moveSpeed
            end

            -- Vertical movement
            if IsControlPressed(0, 44) then     -- Page Up
                currentPos.z += verticalSpeed
            elseif IsControlPressed(0, 36) then -- Page Down
                currentPos.z -= verticalSpeed
            end

            -- Update model position
            UpdateModelPosition(previewModel, currentPos, currentRot)

            -- Confirm placement
            if IsControlJustPressed(0, 191) then             -- Enter key
                -- Finalize the model: make the preview model visible and enable collision
                SetEntityAlpha(previewModel, 255, false)     -- Make the model visible
                SetEntityCollision(previewModel, true, true) -- Enable collision

                -- Call the callback function with true
                if callback then
                    callback(true)
                end

                -- Cleanup
                break
            end

            -- Cancel placement
            if IsControlJustPressed(0, 194) then             -- Backspace key
                -- Delete the preview model
                DeleteEntity(previewModel)

                -- Call the callback function with false
                if callback then
                    callback(false)
                end

                -- Cleanup
                break
            end
        end
    end)
end

function PlaceModel(model, position, rotation, callback)
    local previewModel = CreatePreviewModel(model, position, rotation)
    ControlPlacement(previewModel, callback)
end
