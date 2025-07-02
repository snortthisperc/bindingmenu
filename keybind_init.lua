KEYBIND = KEYBIND or {}
KEYBIND.Storage = KEYBIND.Storage or {}
KEYBIND.Storage.Profiles = KEYBIND.Storage.Profiles or {}

util.AddNetworkString("KEYBIND_SelectProfile")
util.AddNetworkString("KEYBIND_SelectedProfile")

hook.Add("PlayerInitialSpawn", "KEYBIND_AutoSelectProfile", function(ply)
    local storedProfile = ply:GetInfo("KEYBIND_LastProfile")

    if not KEYBIND.Storage.Profiles["Profile 1"] then
        KEYBIND.Storage.Profiles["Profile 1"] = {
            binds = {},
            settings = {
                showFeedback = true
            }
        }
    end

    if storedProfile and KEYBIND.Storage.Profiles[storedProfile] then
        KEYBIND.Storage.CurrentProfile = storedProfile
    else
        KEYBIND.Storage.CurrentProfile = "Profile 1"
    end

    net.Start("KEYBIND_SelectedProfile")
    net.WriteString(KEYBIND.Storage.CurrentProfile)
    net.Send(ply)
    
end)

local function SavePlayerProfile(ply, profileName)
    ply:SetInfo("KEYBIND_LastProfile", profileName)
    local filePath = "keybind_profiles/" .. ply:SteamID() .. ".txt"
    file.CreateDir("keybind_profiles")
    file.Write(filePath, profileName)
end

net.Receive("KEYBIND_SelectProfile", function(len, ply)
    local selectedProfile = net.ReadString()
    if KEYBIND.Storage.Profiles[selectedProfile] then
        KEYBIND.Storage.CurrentProfile = selectedProfile
        KEYBIND.Storage:SaveBinds()

        net.Start("KEYBIND_SelectedProfile")
        net.WriteString(selectedProfile)
        net.Send(ply)
    end
end)

hook.Add("KEYBIND_ProfileSelected", "KEYBIND_SaveSelectedProfile", function(ply, profileName)
    SavePlayerProfile(ply, profileName)
end)
