LogLevel = {
    ["INFO"] = "INFO",
    ["WARN"] = "WARN",
    ["ERROR"] = "ERROR"
}

exports('VersionCheck', function(resourceName, githubRepo, downloadFromGithub)
    if downloadFromGithub == nil then
        downloadFromGithub = true
    end

    if not resourceName or not githubRepo then
        exports['FS-Lib']:LogMessage(GetInvokingResource(),
            resourceName and 'githubRepo param in VersionCheck is nil' or 'resourceName param in VersionCheck is nil')
        return
    end

    local finalName = ('^3[%s] ^7'):format(resourceName)
    --local header = "^5--- Version Info ---"
    local changelogHeader = '^5------------------- Changelog v%s ------------------ '

    local function printVersion(messages)
        for _, msg in ipairs(messages) do
            if msg then
                print(finalName .. msg .. '^7')
            end
        end
    end

    local function versionToNumber(version)
        local major, minor, patch = version:match("v?(%d+)%.(%d+)%.(%d+)")
        return (tonumber(major) or 0) * 10000 + (tonumber(minor) or 0) * 100 + (tonumber(patch) or 0)
    end

    local function getCurrentVersion()
        return GetResourceMetadata(GetInvokingResource(), "version", 0):match("v?(%d+%.%d+%.%d+)")
    end

    local function parseChangelog(content, version)
        local lines = {}
        for line in content:gmatch('[^\r\n]+') do
            table.insert(lines, line)
        end

        local pattern = '^%s*#%s*Changelog%s+v?' .. version:gsub('%.', '%%.') .. '%s*$'
        for i, line in ipairs(lines) do
            if line:lower():match(pattern:lower()) then
                local changes = {}
                for j = i + 1, #lines do
                    local ln = lines[j]
                    if ln:match('^%s*#%s*Changelog') then
                        break
                    end
                    if ln:match('%S') then
                        table.insert(changes, ln)
                    end
                end
                return changes
            end
        end

        return nil
    end

    local function fetchRemoteChangelog(version, callback)
        local branches = { "main", "master" }
        local tried = 0

        local function tryFetch()
            tried = tried + 1
            local branch = branches[tried]
            PerformHttpRequest(('https://raw.githubusercontent.com/%s/%s/CHANGELOG.md'):format(githubRepo, branch),
                function(statusCode, data)
                    if statusCode == 200 then
                        local changelog = parseChangelog(data, version)
                        callback(changelog)
                    elseif tried < #branches then
                        tryFetch()
                    else
                        callback(nil)
                    end
                end)
        end

        tryFetch()
    end

    local function fetchRemoteVersionTxt(callback)
        local branches = { "main", "master" }
        local tried = 0

        local function tryFetch()
            tried = tried + 1
            local branch = branches[tried]
            PerformHttpRequest(
                ('https://raw.githubusercontent.com/%s/refs/heads/%s/version.txt'):format(githubRepo, branch),
                function(statusCode, response)
                    if statusCode == 200 then
                        callback(response)
                    elseif tried < #branches then
                        tryFetch()
                    else
                        callback(nil, statusCode)
                    end
                end)
        end

        tryFetch()
    end

    local currentVersion = getCurrentVersion()
    if not currentVersion then
        printVersion({
            '^1Current version: Invalid format',
            '^1Latest version: Skipped (invalid current version)',
            '^1Status: Error'
        })
        return
    end

    fetchRemoteVersionTxt(function(response, errorCode)
        if not response then
            printVersion({
                ('Current version: %s'):format(currentVersion),
                '^1Latest version: Failed to fetch',
                ('^1Status code: %s'):format(errorCode or 'Unknown')
            })
            return
        end

        local latestVersion = response:match("v?(%d+%.%d+%.%d+)")
        if not latestVersion then
            printVersion({
                ('Current version: %s'):format(currentVersion),
                '^1Latest version: Invalid format',
                '^1Status: Error'
            })
            return
        end

        local currentVersionNumber = versionToNumber(currentVersion)
        local latestVersionNumber = versionToNumber(latestVersion)
        local statusMessage = '^2' .. resourceName .. ' is up to date!'
        local outdated = latestVersionNumber > currentVersionNumber

        if latestVersionNumber < currentVersionNumber then
            statusMessage = '^3' ..
            resourceName .. ' version is from the future! Great Scott! Are you time traveling with Doc?'
        elseif outdated then
            statusMessage = '^1' .. resourceName .. ' version is outdated. Please update.'
        end

        -- Now fetch changelog *first* before printing anything
        if outdated then
            fetchRemoteChangelog(latestVersion, function(changelog)
                local messages = {
                    ('Current version: %s'):format(currentVersion),
                    ('Latest version: %s'):format(latestVersion),
                    statusMessage,
                    downloadFromGithub and
                    ('^3Update available: https://github.com/%s/releases/latest'):format(githubRepo)
                    or '^3Update available: You can download it from https://portal.cfx.re/'
                }

                printVersion(messages)

                if changelog then
                    printVersion({ (changelogHeader):format(latestVersion) })
                    for _, line in ipairs(changelog) do
                        print(finalName .. line .. '^7')
                    end
                end
            end)
        else
            -- if not outdated, print normally right away
            printVersion({
                ('Current version: %s'):format(currentVersion),
                ('Latest version: %s'):format(latestVersion),
                statusMessage
            })
        end
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
    print(("%s [Invoking Resource: %s] %s"):format(logPrefix, invokingResource, message))
end)

exports['FS-Lib']:VersionCheck('FS-Lib', 'fearlessnite345/fs-lib')
