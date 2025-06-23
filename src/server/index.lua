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

    local header = "^5--- Version Info ---"
    local changelogHeader = '^5------------------- Changelog ------------------ '

    local function printVersion(messages)
        for _, msg in ipairs(messages) do
            print(finalName .. msg .. '^7')
        end
    end

    -- Read changelog lines for a specific version from CHANGELOG.md
    local function getChangelog(version)
        local files = { 'CHANGELOG.md', 'changelog.md' }

        for _, fileName in ipairs(files) do
            local fileData = LoadResourceFile(GetInvokingResource(), fileName)
            if fileData then
                local lines = {}
                for line in fileData:gmatch('[^\r\n]+') do
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
                        if #changes > 0 then
                            return changes
                        end
                        return nil
                    end
                end
            end
        end

        return nil
    end

    -- Extracts numeric and pre-release versions
    local function versionToNumber(version)
        local major, minor, patch, pre_release = version:match("v?(%d+)%.(%d+)%.(%d+)-?(.*)")
        if pre_release then pre_release = pre_release:lower() end -- Normalize to lowercase
        local version_number = (tonumber(major) or 0) * 10000 + (tonumber(minor) or 0) * 100 + (tonumber(patch) or 0)
        return version_number, pre_release ~= "" and pre_release or nil
    end


    -- Function to compare versions including pre-release tags
    local function isOutdated(currentVer, currentPre, latestVer, latestPre)
        if latestVer > currentVer then return true end
        if latestVer < currentVer then return false end

        -- If both have the same numeric version, compare pre-release identifiers
        if currentPre == nil and latestPre ~= nil then return true end  -- Stable > Pre-release
        if currentPre ~= nil and latestPre == nil then return false end -- Pre-release < Stable

        -- Compare pre-release identifiers (alpha < beta < rc)
        local pre_order = { alpha = 1, beta = 2, rc = 3 }
        local currentRank = pre_order[currentPre] or 99 -- Default higher for unknown pre-release
        local latestRank = pre_order[latestPre] or 99
        return latestRank > currentRank
    end

    -- Fetch current resource version
    local currentVersion = GetResourceMetadata(GetInvokingResource(), "version", 0):match("v?(%d+%.%d+%.%d+.-?%w*)")
    if not currentVersion then
        printVersion({
            header,
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
                    header,
                    ('Current version: %s'):format(currentVersion),
                    '^1Latest version: Failed to fetch',
                    ('^1Status Code: %s'):format(statusCode)
                })
                return
            end

            local latestVersion = response:match("v?(%d+%.%d+%.%d+.-?%w*)")
            if not latestVersion then
                printVersion({
                    header,
                    ('Current version: %s'):format(currentVersion),
                    '^1Latest version: Invalid version format',
                    '^1Error'
                })
                return
            end

            local currentVersionNumber, currentPreRelease = versionToNumber(currentVersion)
            local latestVersionNumber, latestPreRelease = versionToNumber(latestVersion)

            local outdated = isOutdated(currentVersionNumber, currentPreRelease, latestVersionNumber, latestPreRelease)
            local statusMessage = '^2' .. resourceName .. ' is up to date!'

            if latestVersionNumber < currentVersionNumber then
                statusMessage = '^3' .. resourceName .. ' version is from the future!'
            elseif outdated then
                statusMessage = '^1' .. resourceName .. ' version is outdated. Please update.'
            end

            printVersion({
                header,
                ('Current version: %s'):format(currentVersion),
                ('Latest version: %s'):format(latestVersion),
                statusMessage,
                outdated and ('^3Update here: %s'):format('https://github.com/' .. githubRepo .. '/releases/latest') or
                nil
            })

            if outdated then
                local changelog = getChangelog(latestVersion)
                if changelog then
                    printVersion({changelogHeader .. ('v%s'):format(latestVersion)})
                    for _, line in ipairs(changelog) do
                        print(finalName .. line .. '^7')
                    end
                end
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

    local formattedMessage = string.format("%s [Invoking Resource: %s] %s", logPrefix, invokingResource, message)

    print(formattedMessage)
end)

exports['FS-Lib']:VersionCheck('FS-Lib', 'fearlessnite345/fs-lib')
