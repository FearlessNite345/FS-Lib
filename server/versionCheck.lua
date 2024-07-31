local authorName = 'FearlessStudios' -- Your author name
local resourceName = 'FS-Lib'        -- The name of your FiveM resource
local fullName = ('^3[%s-%s] '):format(authorName, resourceName)

-- Github info to check the version
local githubUsername = 'FearlessNite345'            -- Your GitHub username
local githubRepo = 'FearlessStudios-VersionChecker' -- Your GitHub repository name
local githubVersionFilename = 'fslib-version.txt'   -- The filename on GitHub containing the version information

local function printVersion(current, latest, status)
    print(fullName .. '^4Checking for update...')
    print(fullName .. '^4' .. current)
    print(fullName .. '^4' .. latest)
    print(fullName .. status)
end

local function versionToNumber(version)
    local major, minor, patch = version:match("(%d+)%.?(%d*)%.?(%d*)")
    major = tonumber(major) or 0
    minor = tonumber(minor) or 0
    patch = tonumber(patch) or 0
    return major * 10000 + minor * 100 + patch
end

local function checkVersion()
    local current = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
    local currentVersionMessage = "Current version: " .. current

    PerformHttpRequest(
        ('https://raw.githubusercontent.com/%s/%s/main/%s'):format(githubUsername, githubRepo, githubVersionFilename),
        function(error, version, header)
            if error ~= 200 then
                printVersion(currentVersionMessage, 'Latest version: ^1Failed to fetch', '^1' .. error)
                return
            end

            local latestVersionMessage = "Latest version: " .. version

            local currentVersionNumber = versionToNumber(current)
            local latestVersionNumber = versionToNumber(version)

            local status
            if latestVersionNumber > currentVersionNumber then
                status = "^1" .. resourceName .. " version is outdated. Please update."
            elseif latestVersionNumber < currentVersionNumber then
                status = "^1" .. resourceName .. " version is from the future!"
            elseif latestVersionNumber == currentVersionNumber then
                status = "^2" .. resourceName .. " is up to date!"
            else
                status = "^1Error parsing version. Ensure format is (1.0.0), (1.0), or (1)."
            end

            printVersion(currentVersionMessage, latestVersionMessage, status)
        end
    )
end

checkVersion()
