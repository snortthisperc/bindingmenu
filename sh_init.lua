-- sh_init.lua
-- Initialize the KEYBIND table if it doesn't exist
KEYBIND = KEYBIND or {}

-- Set up sub-tables for organization
KEYBIND.Menu = KEYBIND.Menu or {}
KEYBIND.Config = KEYBIND.Config or {}
KEYBIND.Storage = KEYBIND.Storage or {}
KEYBIND.Settings = KEYBIND.Settings or {}
KEYBIND.Colors = KEYBIND.Colors or {}
KEYBIND.Handler = KEYBIND.Handler or {}
KEYBIND.Storage.Profiles = KEYBIND.Storage.Profiles or {}

if SERVER then
    util.AddNetworkString("KEYBIND_SelectProfile")
    util.AddNetworkString("KEYBIND_SelectedProfile")
end

-- Define menu colors
KEYBIND.Colors = {
    background = Color(25, 25, 25, 255),
    keyDefault = Color(35, 35, 35, 255),
    keyHover = Color(45, 45, 45, 255),
    keyBound = Color(0, 0, 0, 0),
    text = Color(200, 200, 200, 255),
    profileSelected = Color(221, 225, 221, 255),
    profileUnselected = Color(45, 45, 45, 255),
    sectionBackground = Color(25, 25, 25, 255),
    border = Color(60, 60, 60, 255),
    shadow = Color(0, 0, 0, 100),
    accent = Color(100, 150, 200, 255),
    keyBackground = Color(50, 50, 55),
    keyBackgroundHover = Color(60, 60, 65),
    sectionHeader = Color(30, 30, 35, 255)
}

-- Define default configuration
KEYBIND.Config = {
    DefaultProfiles = {
        "Profile1",
        "Profile2",
        "Profile3",
        "Premium1",
        "Premium2",
        "Premium3",
        "Premium4"
    },
    WhitelistedCommands = {
        "say",
        "me",
        "advert",
        "!unbox",
        "!",
        "!goto",
        "!return",
        "!bring",
        "!tp"
    }
}

-- Initialize storage with defaults
KEYBIND.Storage = {
    CurrentProfile = KEYBIND.Config.DefaultProfiles[1],
    Profiles = {}
}

-- Initialize profiles with default settings
for _, profile in pairs(KEYBIND.Config.DefaultProfiles) do
    KEYBIND.Storage.Profiles[profile] = {
        -- Add default profile settings here (e.g., keybindings, settings)
    }
end

function KEYBIND:Initialize()
    -- Initialize all components in the correct order
    if SERVER then
        -- Server-side initialization
        print("[BindMenu] Server-side initialization")
    end
    
    if CLIENT then
        -- Client-side initialization
        print("[BindMenu] Client-side initialization")
        
        -- Wait for client to be fully ready before showing UI
        timer.Simple(1, function()
            if KEYBIND.Storage and KEYBIND.Storage.Initialize then
                KEYBIND.Storage:Initialize()
            end
            
            if KEYBIND.Handler and KEYBIND.Handler.Initialize then
                KEYBIND.Handler:Initialize()
            end
            
            if KEYBIND.Settings and KEYBIND.Settings.LoadSettings then
                KEYBIND.Settings:LoadSettings()
            end
        end)
    end
end

-- Replace the existing InitPostEntity hook with this
hook.Add("InitPostEntity", "KEYBIND_Initialize", function()
    KEYBIND:Initialize()
end)

-- Method skeletons (implement in respective files)
function KEYBIND.Menu:Create()
    -- Create the menu frame
    self.Frame = vgui.Create("DFrame")
    self.Frame:SetSize(800, 600)
    self.Frame:Center()
    self.Frame:SetTitle("Keybind Menu")
    self.Frame:MakePopup()

    -- Create the menu panels
    self.ProfilePanel = vgui.Create("DPanel", self.Frame)
    self.ProfilePanel:SetSize(200, 400)
    self.ProfilePanel:SetPos(10, 10)

    self.KeybindPanel = vgui.Create("DPanel", self.Frame)
    self.KeybindPanel:SetSize(400, 400)
    self.KeybindPanel:SetPos(220, 10)

    -- Initialize the profile selector
    self:CreateProfileSelector(self.ProfilePanel)

    -- Initialize the keybind list
    self:CreateKeybindList(self.KeybindPanel)
end

function KEYBIND.Menu:Update()
    -- Update the profile selector
    self:UpdateProfileSelector()

    -- Update the keybind list
    self:UpdateKeybindList()
end

function KEYBIND.Menu:RenderCompleteKeyboard(parent)
    -- Render the complete keyboard layout
    local keyboardLayout = vgui.Create("DPanel", parent)
    keyboardLayout:Dock(TOP)
    keyboardLayout:SetTall(400)

    -- Add keyboard key buttons
    for i, key in pairs(KEYBIND.Menu.CompleteKeyboardLayout) do
        local keyButton = vgui.Create("DButton", keyboardLayout)
        keyButton:SetText(key)
        keyButton:Dock(LEFT)
        keyButton:SetWide(50)
        keyButton:SetTall(50)
    end
end

function KEYBIND:GetUserAccessLevel(ply)
    local userGroup = ply:GetUserGroup()
    if userGroup == "loyalty" then
        return 2 -- Highest access
    elseif userGroup == "premium" then
        return 1 -- Medium access
    else
        return 0 -- Basic access
    end
end

function KEYBIND:GetMaxProfilesForUser(ply)
    local accessLevel = self:GetUserAccessLevel(ply)
    if accessLevel == 2 then
        return 7
    elseif accessLevel == 1 then
        return 5
    else
        return 3
    end
end

function KEYBIND.Settings:Create()
    -- Create the settings frame
    self.Frame = vgui.Create("DFrame")
    self.Frame:SetSize(400, 300)
    self.Frame:Center()
    self.Frame:SetTitle("Settings")
    self.Frame:MakePopup()

    -- Create the settings panels
    self.GeneralPanel = vgui.Create("DPanel", self.Frame)
    self.GeneralPanel:SetSize(200, 200)
    self.GeneralPanel:SetPos(10, 10)

    self.AdvancedPanel = vgui.Create("DPanel", self.Frame)
    self.AdvancedPanel:SetSize(200, 200)
    self.AdvancedPanel:SetPos(220, 10)

    -- Initialize the general settings
    self:CreateGeneralSettings(self.GeneralPanel)

    -- Initialize the advanced settings
    self:CreateAdvancedSettings(self.AdvancedPanel)
end

function KEYBIND.Settings:Update()
    -- Update the general settings
    self:UpdateGeneralSettings()

    -- Update the advanced settings
    self:UpdateAdvancedSettings()
end

function KEYBIND.Settings:Save()
    -- Save the general settings
    self:SaveGeneralSettings()

    -- Save the advanced settings
    self:SaveAdvancedSettings()

    print("Settings saved!")
    return true
end

function KEYBIND.Handler:Bind(key, action)
    -- Check if the key is already bound
    if self:IsKeyBound(key) then return end

    -- Bind the key to the action
    self.Keybinds[key] = action

    print("Key bound: " .. key .. " -> " .. action)
end

function KEYBIND.Handler:Unbind(key)
    -- Check if the key is bound
    if not self:IsKeyBound(key) then return end

    -- Unbind the key from the action
    self.Keybinds[key] = nil

    print("Key unbound: " .. key)
end

function KEYBIND.Handler:HandleInput(input)
    -- Check if the input is a key press
    if input == "KeyDown" then
        -- Get the pressed key
        local key = input:GetKey()

        -- Check if the key is bound to an action
        if self:IsKeyBound(key) then
            -- Perform the bound action
            self:PerformAction(self.Keybinds[key])
        end
    end
end

