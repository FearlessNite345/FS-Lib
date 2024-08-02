-- Register the client event to print the error message
RegisterNetEvent("FS_Lib:printErrorMessageClient")
AddEventHandler("FS_Lib:printErrorMessageClient", function(formattedMessage)
    print(formattedMessage)
end)
