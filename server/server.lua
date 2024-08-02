-- Register the server event to print the error message
RegisterNetEvent("FS_Lib:FS_Lib:printErrorMessageServer")
AddEventHandler("FS_Lib:printErrorMessageServer", function(formattedMessage)
    print(formattedMessage)
end)
