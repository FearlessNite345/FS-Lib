-- Exports for FS-Lib functions
exports('GetKeyStringFromKeyID', function(keyId)
    return GetKeyStringFromKeyID(keyId)
end)

exports('GetClosestModelWithinDistance', function(maxDistance, items)
    return GetClosestModelWithinDistance(maxDistance, items)
end)

exports('GetClosestPedWithinDistance', function(maxDistance)
    return GetClosestPedWithinDistance(maxDistance)
end)

exports('EnumeratePeds', function()
    return EnumeratePeds()
end)

exports('SetupModel', function(model)
    SetupModel(model)
end)

exports('RandomLimited', function(min, max, limit)
    return RandomLimited(min, max, limit)
end)

exports('DrawNotification3D', function(coords, text, seconds, color)
    DrawNotification3D(coords, text, seconds, color)
end)

exports('DrawNotification2D', function(text, seconds, color)
    DrawNotification2D(text, seconds, color)
end)

exports('DrawText3D', function(x, y, z, scale, text)
    DrawText3D(x, y, z, scale, text)
end)

exports('DrawText2D', function(x, y, text, scale, center)
    DrawText2D(x, y, text, scale, center)
end)

exports('PlaceModel', function(model, position, rotation, callback)
    PlaceModel(model, position, rotation, callback)
end)

exports('HeadingToCardinal', function(heading)
    return HeadingToCardinal()
end)
