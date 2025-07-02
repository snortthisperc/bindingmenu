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

function KEYBIND.Storage:Initialize()
    file.CreateDir("bindmenu")
    
    self:LoadBinds()
end

function KEYBIND.Storage:SaveBinds()
    local data = {
        currentProfile = self.CurrentProfile,
        profiles = {}
    }

    for profileName, profileData in pairs(self.Profiles) do
        data.profiles[profileName] = {
            binds = profileData.binds or {},
            name = profileData.name,
            displayName = profileData.displayName
        }
    end

    local jsonData = util.TableToJSON(data, true)
    file.Write("bindmenu/profiles.txt", jsonData)
    
    if not self.silentSave then
        print("[KEYBIND] Saved profiles to disk")
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
            self.CurrentProfile = data.currentProfile
            print("[KEYBIND] Loaded profiles from disk")
        else
            print("[KEYBIND] Error parsing saved profiles")
            self:InitializeDefaultProfiles()
        end
    else
        print("[KEYBIND] No saved profiles found, creating defaults")
        self:InitializeDefaultProfiles()
    end

    self:ValidateProfiles()
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

hook.Add("Initialize", "KEYBIND_Storage_Init", function()
    KEYBIND.Storage:Initialize()
end)

hook.Add("InitPostEntity", "KEYBIND_LoadData", function()
    timer.Simple(1, function()
        KEYBIND.Storage:LoadBinds()
    end)
end)

hook.Add("ShutDown", "KEYBIND_SaveData", function()
    KEYBIND.Storage:SaveBinds()
end)

hook.Add("Initialize", "KEYBIND_Settings_Init", function()
    KEYBIND.Settings:LoadSettings()
end)

hook.Add("ShutDown", "KEYBIND_Settings_Save", function()
    KEYBIND.Settings:SaveSettings()
end)

timer.Create("KEYBIND_AutoSave", 300, 0, function() 
    KEYBIND.Storage.silentSave = true  
    KEYBIND.Storage:SaveBinds()
end)
