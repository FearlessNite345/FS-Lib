LogLevel = {
    ["INFO"] = "INFO",
    ["WARN"] = "WARN",
    ["ERROR"] = "ERROR"
}

exports('VersionCheck', function(resourceName, githubRepo)
    if not resourceName or not githubRepo then
        exports['FS-Lib']:LogMessage(GetInvokingResource(),
            resourceName and 'githubRepo param in VersionCheck is nil' or 'resourceName param in VersionCheck is nil')
        return
    end

    local finalName = ('^3[%s] ^7'):format(resourceName)

    local function printVersion(messages)
        for _, msg in ipairs(messages) do
            print(finalName .. msg .. '^7')
        end
    end

    local function versionToNumber(version)
        local major, minor, patch = version:match("v?(%d+)%.(%d+)%.(%d+)")
        return (tonumber(major) or 0) * 10000 + (tonumber(minor) or 0) * 100 + (tonumber(patch) or 0)
    end

    local currentVersion = GetResourceMetadata(GetInvokingResource(), "version", 0):match("v?(%d+%.%d+%.%d+)")
    if not currentVersion then
        printVersion({
            '^4Checking for update...',
            '^1Current version: Invalid version format',
            '^1Latest version: Not fetched due to incorrect current version format',
            '^1Error'
        })
        return
    end

    PerformHttpRequest(('https://raw.githubusercontent.com/%s/refs/heads/main/version.txt'):format(githubRepo),
        function(statusCode, response)
            if statusCode ~= 200 then
                printVersion({
                    '^4Checking for update...',
                    ('Current version: %s'):format(currentVersion),
                    '^1Latest version: Failed to fetch',
                    ('^1Status Code: %s'):format(statusCode)
                })
                return
            end

            local latestVersion = response:match("v?(%d+%.%d+%.%d+)")
            if not latestVersion then
                printVersion({
                    '^4Checking for update...',
                    ('Current version: %s'):format(currentVersion),
                    '^1Latest version: Invalid version format',
                    '^1Error'
                })
                return
            end

            local currentVersionNumber = versionToNumber(currentVersion)
            local latestVersionNumber = versionToNumber(latestVersion)
            local statusMessage = '^2' .. resourceName .. ' is up to date!'
            local outdated = latestVersionNumber > currentVersionNumber

            if latestVersionNumber < currentVersionNumber then
                statusMessage = '^3' .. resourceName .. ' version is from the future!'
            elseif outdated then
                statusMessage = '^1' .. resourceName .. ' version is outdated. Please update.'
            end

            printVersion({
                '^4Checking for update...',
                ('Current version: %s'):format(currentVersion),
                ('Latest version: %s'):format(latestVersion),
                statusMessage,
                outdated and ('^3Update here: %s'):format('https://github.com/' .. githubRepo .. '/releases/latest') or
                nil
            })
        end)
end)

exports('LogMessage', function(invokingResource, message, logLevel)
    local logPrefixes = {
        [LogLevel["INFO"]] = "^2[INFO]",
        [LogLevel["WARN"]] = "^3[WARN]",
        [LogLevel["ERROR"]] = "^1[ERROR]",
    }

    logLevel = logLevel or LogLevel.ERROR

    local logPrefix = logPrefixes[logLevel] or logPrefixes[LogLevel.ERROR]

    local formattedMessage = string.format("%s [Invoking Resource: %s] %s", logPrefix, invokingResource, message)

    print(formattedMessage)
end)

exports['FS-Lib']:VersionCheck('FS-Lib', 'fearlessnite345/fs-lib')

