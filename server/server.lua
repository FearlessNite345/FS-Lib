-- Register the server event to print the error message
RegisterNetEvent("FS_Lib:FS_Lib:logMessageServer")
AddEventHandler("FS_Lib:logMessageServer", function(formattedMessage)
    print(formattedMessage)
end)
