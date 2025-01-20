-- Localize functions
local GetResourceMetadata = GetResourceMetadata
local PerformHttpRequest = PerformHttpRequest
local GetInvokingResource = GetInvokingResource

exports('VersionCheck', function(resourceName, githubRepo)
    if not resourceName or not githubRepo then
        LogMessage(GetInvokingResource(), resourceName and 'githubRepo param in VersionCheck is nil' or 'resourceName param in VersionCheck is nil', false, false)
        return
    end

    local finalName = ('^3[%s] ^7'):format(resourceName)

    local function printVersion(messages)
        for _, msg in ipairs(messages) do
            print(finalName .. msg)
        end
    end

    local function versionToNumber(version)
        local major, minor, patch = version:match("v?(%d+)%.(%d+)%.(%d+)")
        return (tonumber(major) or 0) * 10000 + (tonumber(minor) or 0) * 100 + (tonumber(patch) or 0)
    end

    local currentVersion = GetResourceMetadata(GetInvokingResource(), "version", 0):match("v?(%d+%.%d+%.%d+)")
    if not currentVersion then
        printVersion({
            '^4Checking for update...^7',
            '^1Current version: Invalid version format',
            '^1Latest version: Not fetched due to incorrect current version format',
            '^1Error'
        })
        return
    end

    PerformHttpRequest(('https://raw.githubusercontent.com/%s/refs/heads/main/version.txt'):format(githubRepo), function(statusCode, response)
        if statusCode ~= 200 then
            printVersion({
                '^4Checking for update...^7',
                ('Current version: %s'):format(currentVersion),
                '^1Latest version: Failed to fetch',
                ('^1Status Code: %s'):format(statusCode)
            })
            return
        end

        local latestVersion = response:match("v?(%d+%.%d+%.%d+)")
        if not latestVersion then
            printVersion({
                '^4Checking for update...^7',
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
            '^4Checking for update...^7',
            ('Current version: %s'):format(currentVersion),
            ('Latest version: %s'):format(latestVersion),
            statusMessage,
            outdated and ('^3Update here: %s'):format('https://github.com/' .. githubRepo .. '/releases/latest') or nil
        })
    end)
end)
