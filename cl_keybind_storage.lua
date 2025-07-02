KEYBIND.Storage = KEYBIND.Storage or {}

local DEFAULT_PROFILES = {
    {name = "Profile1", displayName = "Profile 1"},
    {name = "Profile2", displayName = "Profile 2"},
    {name = "Profile3", displayName = "Profile 3"},
    {name = "Premium1", displayName = "Premium 4"},
    {name = "Premium2", displayName = "Premium 5"},
    {name = "Premium3", displayName = "Loyalty 6"},
    {name = "Premium4", displayName = "Loyalty 7"}
}

if CLIENT then
    CreateClientConVar("KEYBIND_LastProfile", "Profile1", true, false, "Last selected keybind profile")
end

function KEYBIND.Storage:Initialize()
    file.CreateDir("bindmenu")
    
    self:LoadBinds()
end

function KEYBIND.Storage:SaveBinds()
    local data = {
        currentProfile = self.CurrentProfile,
        profiles = {}
    }

    -- Add error handling
    if not self.Profiles then
        print("[BindMenu] Error: No profiles to save")
        return
    end

    for profileName, profileData in pairs(self.Profiles) do
        data.profiles[profileName] = {
            binds = profileData.binds or {},
            name = profileData.name,
            displayName = profileData.displayName
        }
    end

    local success, jsonData = pcall(util.TableToJSON, data, true)
    if not success then
        print("[BindMenu] Error converting profiles to JSON")
        return
    end
    
    file.Write("bindmenu/profiles.txt", jsonData)
    
    if not self.silentSave then
        print("[BindMenu] Saved profiles to disk")
    end
    self.silentSave = false
end

function KEYBIND.Settings:LoadSettings()
    local data = file.Read("bindmenu/settings.txt", "DATA")
    if data then
        local settings = util.JSONToTable(data)
        if settings then
            self.Config = settings
        end
    end
end

function KEYBIND.Storage:LoadBinds()
    local jsonData = file.Read("bindmenu/profiles.txt", "DATA")
    
    if jsonData then
        local data = util.JSONToTable(jsonData)
        if data then
            self.Profiles = data.profiles
            
            -- Get the last profile from client convar
            local lastProfile = GetConVar("KEYBIND_LastProfile"):GetString()
            if lastProfile and self.Profiles[lastProfile] then
                self.CurrentProfile = lastProfile
            else
                self.CurrentProfile = data.currentProfile
            end
            
            print("[BindMenu] Loaded profiles from disk, using profile: " .. self.CurrentProfile)
        else
            print("[BindMenu] Error parsing saved profiles")
            self:InitializeDefaultProfiles()
        end
    else
        print("[BindMenu] No saved profiles found, creating defaults")
        self:InitializeDefaultProfiles()
    end

    self:ValidateProfiles()
end

function KEYBIND.Storage:InitializeDefaultProfiles()
    self.CurrentProfile = "Profile1"
    self.Profiles = {}
    
    for _, profile in ipairs(DEFAULT_PROFILES) do
        self.Profiles[profile.name] = {
            binds = {},
            name = profile.name,
            displayName = profile.displayName
        }
    end
    
    self:SaveBinds()
end

function KEYBIND.Storage:ValidateProfiles()
    for _, profile in ipairs(DEFAULT_PROFILES) do
        if not self.Profiles[profile.name] then
            self.Profiles[profile.name] = {
                binds = {},
                name = profile.name,
                displayName = profile.displayName
            }
        end
    end

    if not self.CurrentProfile or not self.Profiles[self.CurrentProfile] then
        self.CurrentProfile = "Profile1"
    end

    self:SaveBinds()
end

function KEYBIND.Storage:RenameProfile(oldName, newName)
    if self.Profiles[oldName] then
        self.Profiles[oldName].name = newName
        self.Profiles[oldName].displayName = newName
        
        self:SaveBinds()
        
        if KEYBIND.Settings.Config.showFeedback then
            chat.AddText(Color(0, 255, 0), "[BindMenu] Profile renamed from " .. oldName .. " to " .. newName)
        end
        
        timer.Simple(0.1, function()
            if IsValid(KEYBIND.Menu.Frame) then
                KEYBIND.Menu:RefreshKeyboardLayout()
            end
            if IsValid(KEYBIND.Settings.Frame) then
                KEYBIND.Settings:Create()
            end
        end)
    end
end

function KEYBIND.Storage:DebugProfiles()
    print("[BindMenu] Current profile: " .. tostring(self.CurrentProfile))
    
    if not self.Profiles then
        print("[BindMenu] No profiles table found!")
        return
    end
    
    print("[BindMenu] Available profiles:")
    for name, profile in pairs(self.Profiles) do
        print("  - " .. name .. " (binds: " .. table.Count(profile.binds or {}) .. ")")
        
        if profile.binds then
            for key, command in pairs(profile.binds) do
                print("    * " .. key .. " -> " .. command)
            end
        end
    end
end

net.Receive("KEYBIND_SaveClientProfile", function()
    local profileName = net.ReadString()
    if profileName and profileName ~= "" then
        -- This is the proper way to set client-side info
        LocalPlayer():ConCommand("KEYBIND_LastProfile " .. profileName)
        
        -- Also store it in our local settings
        KEYBIND.Storage.CurrentProfile = profileName
        KEYBIND.Storage:SaveBinds()
        
        print("[BindMenu] Client received profile save: " .. profileName)
    end
end)

hook.Add("Initialize", "KEYBIND_Storage_Init", function()
    KEYBIND.Storage:Initialize()
end)

hook.Add("InitPostEntity", "KEYBIND_LoadData", function()
    timer.Simple(1, function()
        KEYBIND.Storage:LoadBinds()
    end)
end)

hook.Add("InitPostEntity2", "KEYBIND_DebugProfiles", function()
    timer.Simple(3, function()
        KEYBIND.Storage:DebugProfiles()
    end)
end)

hook.Add("ShutDown", "KEYBIND_SaveData", function()
    if KEYBIND and KEYBIND.Storage and KEYBIND.Storage.SaveBinds then
        pcall(function()
            KEYBIND.Storage:SaveBinds()
        end)
    end
end)

hook.Add("Initialize", "KEYBIND_Settings_Init", function()
    KEYBIND.Settings:LoadSettings()
end)

hook.Add("ShutDown", "KEYBIND_Settings_Save", function()
    if KEYBIND and KEYBIND.Settings and KEYBIND.Settings.SaveSettings then
        pcall(function()
            KEYBIND.Settings:SaveSettings()
        end)
    end
end)

timer.Create("KEYBIND_AutoSave", 300, 0, function() 
    KEYBIND.Storage.silentSave = true  
    KEYBIND.Storage:SaveBinds()
end)
