-- Register the client event to print the error message
RegisterNetEvent("FS_Lib:logMessageClient")
AddEventHandler("FS_Lib:logMessageClient", function(formattedMessage)
    print(formattedMessage)
end)
