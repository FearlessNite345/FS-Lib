-- Define log level constants
LogLevel = {
    INFO = "INFO",
    WARN = "WARN",
    ERROR = "ERROR"
}

-- Function to print a formatted error message with logging levels
function LogMessage(message, broadcast, serverOnly, logLevel)
    -- Define log level prefixes
    local logPrefixes = {
        [LogLevel.INFO] = "^2[INFO]",
        [LogLevel.WARN] = "^3[WARN]",
        [LogLevel.ERROR] = "^1[ERROR]",
    }

    -- Default log level if not provided
    logLevel = logLevel or LogLevel.ERROR

    -- Determine the log prefix based on the provided log level
    local logPrefix = logPrefixes[logLevel] or logPrefixes[LogLevel.ERROR]

    -- Get the current date and time
    local date = os.date("%Y-%m-%d %H:%M:%S")

    -- Format the error message with the log level prefix
    local formattedMessage = string.format("%s [%s] [FS-Lib] %s", logPrefix, date, message)

    if serverOnly then
        if not IsDuplicityVersion() then
            -- If running on the client and serverOnly is true, send the message to the server
            TriggerServerEvent("FS_Lib:printErrorMessageServer", formattedMessage)
            return
        end
    else
        -- Print the message locally
        print(formattedMessage)
    end

    if broadcast then
        if IsDuplicityVersion() then
            -- If running on the server, broadcast to all clients
            TriggerClientEvent("FS_Lib:printErrorMessageClient", -1, formattedMessage)
        else
            -- If running on the client, send the message to the server
            TriggerServerEvent("FS_Lib:printErrorMessageServer", formattedMessage)
        end
    end
end
