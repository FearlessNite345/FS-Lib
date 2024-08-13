exports('VersionCheck', function(resourceName, githubRepo)
    -- GitHub info to check the version

    if not resourceName then
        LogMessage(GetInvokingResource(), 'resourceName param in VersionCheck is nil', false, false)
        return
    elseif not githubRepo then
        LogMessage(GetInvokingResource(), 'githubRepo param in VersionCheck is nil', false, false)
        return
    end

    local finalName = '^3[' .. resourceName .. '] ^7'

    local function printVersion(cur, late, status, updateLink)
        print(finalName .. '^4Checking for update...^7')
        print(finalName .. '^4' .. cur .. '^7')
        print(finalName .. '^4' .. late .. '^7')
        print(finalName .. status .. '^7')

        if updateLink then
            print(finalName .. '^3' .. updateLink)
        end
    end

    local function versionToNumber(version)
        local major, minor, patch = version:match("v?(%d+)%.(%d+)%.(%d+)")

        major = tonumber(major) or 0
        minor = tonumber(minor) or 0
        patch = tonumber(patch) or 0
        return major * 10000 + minor * 100 + patch
    end

    local cur = ''
    local late = ''
    local status = ''

    local current = GetResourceMetadata(GetInvokingResource(), "version", 0)
    current = current:match("v?(%d+%.%d+%.%d+)")
    if not current then
        printVersion('Current version: ^1Invalid version format',
            'Latest version: ^1Not fetched due to incorrect current version format', '^1Error')
        return
    end
    cur = "Current version: " .. current

    PerformHttpRequest(('https://api.github.com/repos/%s/releases/latest'):format(githubRepo),
        function(statusCode, response)
            if statusCode ~= 200 then
                printVersion(cur, 'Latest version: ^1Failed to fetch', '^1' .. statusCode)
                return
            end

            response = json.decode(response)
            if not response or not response.tag_name then
                printVersion(cur, 'Latest version: ^1Failed to parse response', '^1Error')
                return
            end

            local latestVersion = response.tag_name:match("v?(%d+%.%d+%.%d+)")
            if not latestVersion then
                printVersion(cur, 'Latest version: ^1Invalid version format', '^1Error')
                return
            end

            late = "Latest version: " .. latestVersion

            local currentVersionNumber = versionToNumber(current)
            local newToCheckNumber = versionToNumber(latestVersion)

            local outdated = false

            if newToCheckNumber < currentVersionNumber then
                status = "^3" .. resourceName .. " version is from the future!"
            elseif newToCheckNumber > currentVersionNumber then
                outdated = true
                status = "^1" .. resourceName .. " version is outdated. Please update."
            elseif newToCheckNumber == currentVersionNumber then
                status = "^2" .. resourceName .. " is up to date!"
            end

            if outdated then
                printVersion(cur, late, status, response.html_url)
            else
                printVersion(cur, late, status)
            end
        end)
end)
