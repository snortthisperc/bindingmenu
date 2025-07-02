--[[
    File for settings menu, majority can go untouched unless adding your own settings or altering default profiles/rank limits.
                                                                                                                                ]]--

KEYBIND.Settings = KEYBIND.Settings or {}

-- Default settings configuration
KEYBIND.Settings.Config = {
    showFeedback = true
    -- Add any other settings here
}

local function SafeDrawGradient(material, x, y, w, h, color)
    if not material or material:IsError() then return end
    
    surface.SetDrawColor(color or Color(255, 255, 255, 10))
    surface.SetMaterial(material)
    surface.DrawTexturedRect(x, y, w, h)
end

local GRADIENT = Material("gui/gradient_up")
local GRADIENT_DOWN = Material("gui/gradient_down")

surface.CreateFont("KeybindSettingsFont", {
    font = "Roboto",
    size = 17,  
    weight = 500,
    antialias = true
})

-- Settings Save/Load Functions
function KEYBIND.Settings:SaveSettings()
    local data = {
        showFeedback = self.Config.showFeedback
        -- Add other settings here
    }
    
    file.CreateDir("bindmenu")
    file.Write("bindmenu/settings.txt", util.TableToJSON(data, true))
    print("[BindMenu] Saved settings to disk")
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

-- Initialize settings
hook.Add("Initialize", "KEYBIND_Settings_Init", function()
    KEYBIND.Settings:LoadSettings()
end)

-- Save settings on shutdown
hook.Add("ShutDown", "KEYBIND_Settings_Save", function()
    if KEYBIND and KEYBIND.Settings then
        KEYBIND.Settings:SaveSettings()
    end
end)

function KEYBIND.Settings:Create()
    if IsValid(self.Frame) then
        self.Frame:Remove()
    end

    -- Create fonts for the settings menu
    surface.CreateFont("KeybindSettingsTitle", {
        font = "Roboto",
        size = 20,
        weight = 600,
        antialias = true
    })
    
    surface.CreateFont("KeybindSettingsText", {
        font = "Roboto",
        size = 16,
        weight = 500,
        antialias = true
    })
    
    surface.CreateFont("KeybindSettingsButton", {
        font = "Roboto",
        size = 15,
        weight = 500,
        antialias = true
    })

    -- Create the main frame
    self.Frame = vgui.Create("DFrame")
    self.Frame:SetSize(450, 500)
    self.Frame:Center()
    self.Frame:SetTitle("")
    self.Frame:MakePopup()
    self.Frame:ShowCloseButton(false)
    self.Frame:SetDraggable(true)
    
    -- Add blur effect
    self.Frame.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0)
        
        -- Main background
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 35, 245))
        
        -- Header
        draw.RoundedBoxEx(8, 0, 0, w, 40, Color(40, 40, 45, 255), true, true, false, false)
        
        -- Title
        draw.SimpleText("Settings", "KeybindSettingsTitle", 20, 20, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Bottom bar
        draw.RoundedBoxEx(8, 0, h-50, w, 50, Color(35, 35, 40, 255), false, false, true, true)
    end
    
    -- Close button
    local closeBtn = vgui.Create("DButton", self.Frame)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(self.Frame:GetWide() - 40, 5)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local color = self:IsHovered() and Color(255, 80, 80) or Color(200, 60, 60)
        draw.SimpleText("✕", "KeybindSettingsTitle", w/2, h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function() self.Frame:Remove() end
    
    -- Create scroll panel for settings
    local scroll = vgui.Create("DScrollPanel", self.Frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 50, 10, 60)
    
    -- Custom scrollbar
    local scrollbar = scroll:GetVBar()
    scrollbar:SetWide(6)
    scrollbar.Paint = function(self, w, h) end
    scrollbar.btnUp.Paint = function(self, w, h) end
    scrollbar.btnDown.Paint = function(self, w, h) end
    scrollbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(80, 80, 85, 180))
    end
    
    -- Add general settings section
    self:AddGeneralSettingsSection(scroll)
    
    -- Add profile settings sections based on user rank
    self:AddProfileSettingsSections(scroll)
    
    -- Add reset all button at the bottom
    local resetAllBtn = vgui.Create("DButton", self.Frame)
    resetAllBtn:SetSize(200, 36)
    resetAllBtn:SetPos(self.Frame:GetWide()/2 - 100, self.Frame:GetTall() - 43)
    resetAllBtn:SetText("")
    
    resetAllBtn.Paint = function(self, w, h)
        local baseColor = self:IsHovered() and Color(180, 50, 50) or Color(150, 40, 40)
        draw.RoundedBox(6, 0, 0, w, h, baseColor)
        
        -- Add gradient
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        
        draw.SimpleText("Reset All Profiles", "KeybindSettingsButton", w/2, h/2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    resetAllBtn.DoClick = function()
        Derma_Query(
            "Are you sure you want to reset ALL profiles?\nThis cannot be undone!",
            "Confirm Reset",
            "Yes",
            function()
                self:DeleteAllProfiles()
            end,
            "No",
            function() end
        )
    end
end

function KEYBIND.Settings:CreateStyledButton(parent, text)
    local btn = vgui.Create("DButton", parent)
    btn:SetText("")
    btn:SetHeight(36)
    
    btn.Paint = function(self, w, h)
        local baseColor = self.CustomColor or Color(60, 60, 65)
        local hoverColor = self:IsHovered() and Color(
            math.min(baseColor.r + 20, 255),
            math.min(baseColor.g + 20, 255),
            math.min(baseColor.b + 20, 255)
        ) or baseColor
        
        draw.RoundedBox(6, 0, 0, w, h, hoverColor)
        
        -- Add gradient
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        
        draw.SimpleText(text, "KeybindSettingsButton", w/2, h/2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    return btn
end

-- Custom dialog style
function KEYBIND.Settings:CreateStyledDialog(title, text, w, h)
    local frame = vgui.Create("DFrame")
    frame:SetSize(w or 400, h or 150)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    
    frame.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0)
        draw.RoundedBox(8, 0, 0, w, h, KEYBIND.Colors.background)
        draw.RoundedBoxEx(8, 0, 0, w, 30, KEYBIND.Colors.sectionHeader, true, true, false, false)
        draw.SimpleText(title, "DermaDefaultBold", 10, 15, KEYBIND.Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    return frame
end

function KEYBIND.Settings:ResetProfile(profile)
    if KEYBIND.Storage.Profiles[profile] then
        KEYBIND.Storage.Profiles[profile].binds = {}
        KEYBIND.Storage:SaveBinds()
        
        if KEYBIND.Settings.Config.showFeedback then
            chat.AddText(Color(0, 255, 0), "[BindMenu] Reset all binds for profile: " .. profile)
        end
        
        -- Refresh menus
        if IsValid(KEYBIND.Menu.Frame) then
            KEYBIND.Menu:RefreshKeyboardLayout()
        end
    end
end

function KEYBIND.Settings:DeleteAllProfiles()
    -- Initialize with default profiles based on rank
    local accessLevel = KEYBIND:GetUserAccessLevel(LocalPlayer())
    local maxProfiles = KEYBIND:GetMaxProfilesForUser(LocalPlayer())
    
    KEYBIND.Storage.Profiles = {}
    
    -- Define base profiles with proper access levels
    local baseProfiles = {
        {name = "Profile1", displayName = "Profile 1", access = 0}, -- User
        {name = "Profile2", displayName = "Profile 2", access = 0},
        {name = "Profile3", displayName = "Profile 3", access = 0},
        {name = "Premium1", displayName = "Premium 4", access = 1}, -- Premium
        {name = "Premium2", displayName = "Premium 5", access = 1},
        {name = "Premium3", displayName = "Loyalty 6", access = 2}, -- Loyalty
        {name = "Premium4", displayName = "Loyalty 7", access = 2}
    }
    
    -- Reset only accessible profiles
    for i, profile in ipairs(baseProfiles) do
        local hasAccess = profile.access <= accessLevel and i <= maxProfiles
        
        if hasAccess then
            KEYBIND.Storage.Profiles[profile.name] = {
                binds = {},
                name = profile.name,
                displayName = profile.displayName
            }
        end
    end
    
    KEYBIND.Storage.CurrentProfile = "Profile1"
    KEYBIND.Storage:SaveBinds()
    
    if KEYBIND.Settings.Config.showFeedback then
        chat.AddText(Color(255, 0, 0), "[BindMenu] Profiles & Binds reset")
    end
    
    -- Refresh menus
    if IsValid(KEYBIND.Menu.Frame) then
        KEYBIND.Menu:RefreshKeyboardLayout()
    end
    self:Create()
end

function KEYBIND.Settings:ResetProfile(profile)
    if KEYBIND.Storage.Profiles[profile] then
        KEYBIND.Storage.Profiles[profile].binds = {}
        KEYBIND.Storage:SaveBinds()
        
        if self.Config.showFeedback then
            chat.AddText(Color(0, 255, 0), "[BindMenu] Reset all binds for profile: " .. 
                (KEYBIND.Storage.Profiles[profile].displayName or profile))
        end
        
        if IsValid(KEYBIND.Menu.Frame) then
            KEYBIND.Menu:RefreshKeyboardLayout()
        end
        
        -- Refresh the settings menu
        timer.Simple(0.1, function()
            if IsValid(self.Frame) then
                self:Create()
            end
        end)
    end
end

function KEYBIND.Settings:AddGeneralSettingsSection(parent)
    local section = vgui.Create("DPanel", parent)
    section:Dock(TOP)
    section:SetHeight(80)
    section:DockMargin(0, 0, 0, 10)
    section:SetPaintBackground(false)
    
    -- Section header
    local header = vgui.Create("DPanel", section)
    header:Dock(TOP)
    header:SetHeight(30)
    header:SetPaintBackground(false)
    
    header.Paint = function(self, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, Color(50, 50, 55), true, true, false, false)
        draw.SimpleText("General Settings", "KeybindSettingsText", 10, h/2, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- Section content
    local content = vgui.Create("DPanel", section)
    content:Dock(FILL)
    content:DockMargin(0, 0, 0, 0)
    
    content.Paint = function(self, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, Color(40, 40, 45), false, false, true, true)
    end
    
    -- Feedback checkbox
    local feedbackCheck = vgui.Create("DCheckBoxLabel", content)
    feedbackCheck:SetPos(15, 15)
    feedbackCheck:SetText("Show Feedback Messages")
    feedbackCheck:SetTextColor(Color(210, 210, 210))
    feedbackCheck:SetFont("KeybindSettingsText")
    feedbackCheck:SizeToContents()
    feedbackCheck:SetValue(self.Config.showFeedback)
    
    feedbackCheck.OnChange = function(self, val)
        KEYBIND.Settings.Config.showFeedback = val
        KEYBIND.Settings:SaveSettings()
        
        if val then
            chat.AddText(Color(0, 255, 0), "[BindMenu] Feedback messages enabled")
        else
            chat.AddText(Color(255, 0, 0), "[BindMenu] Feedback messages disabled")
        end
    end
    
    -- Custom checkbox style
    feedbackCheck.Button.Paint = function(self, w, h)
        local checkColor = self:GetChecked() and Color(80, 150, 220) or Color(60, 60, 65)
        draw.RoundedBox(3, 0, 0, w, h, checkColor)
        
        if self:GetChecked() then
            draw.SimpleText("✓", "KeybindSettingsText", w/2, h/2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    return section
end

function KEYBIND.Settings:AddProfileSettingsSections(parent)
    local userGroup = LocalPlayer():GetUserGroup()
    local accessLevel = KEYBIND:GetUserAccessLevel(LocalPlayer())
    local maxProfiles = KEYBIND:GetMaxProfilesForUser(LocalPlayer())
    
    -- Define base profiles with proper access levels
    local baseProfiles = {
        {name = "Profile1", displayName = "Profile 1", access = 0}, -- User
        {name = "Profile2", displayName = "Profile 2", access = 0},
        {name = "Profile3", displayName = "Profile 3", access = 0},
        {name = "Premium1", displayName = "Premium 4", access = 1}, -- Premium
        {name = "Premium2", displayName = "Premium 5", access = 1},
        {name = "Premium3", displayName = "Loyalty 6", access = 2}, -- Loyalty
        {name = "Premium4", displayName = "Loyalty 7", access = 2}
    }
    
    -- Add sections for profiles the user has access to
    for i, profileData in ipairs(baseProfiles) do
        -- Check if user has access to this profile
        local hasAccess = false
        
        if profileData.access <= accessLevel and i <= maxProfiles then
            hasAccess = true
        end
        
        if hasAccess then
            self:AddProfileSection(parent, profileData.name)
        end
    end
end

function KEYBIND.Settings:AddProfileSection(parent, profileName)
    local storedProfile = KEYBIND.Storage.Profiles[profileName]
    if not storedProfile then return end
    
    local displayName = storedProfile.displayName or profileName
    
    local section = vgui.Create("DPanel", parent)
    section:Dock(TOP)
    section:SetHeight(90)
    section:DockMargin(0, 0, 0, 10)
    section:SetPaintBackground(false)
    
    -- Section header
    local header = vgui.Create("DPanel", section)
    header:Dock(TOP)
    header:SetHeight(30)
    header:SetPaintBackground(false)
    
    header.Paint = function(self, w, h)
        local isCurrentProfile = KEYBIND.Storage.CurrentProfile == profileName
        local headerColor = isCurrentProfile and Color(60, 100, 150) or Color(50, 50, 55)
        
        draw.RoundedBoxEx(6, 0, 0, w, h, headerColor, true, true, false, false)
        draw.SimpleText(displayName, "KeybindSettingsText", 10, h/2, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        if isCurrentProfile then
            draw.SimpleText("Current", "KeybindSettingsText", w - 10, h/2, Color(230, 230, 230), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Section content
    local content = vgui.Create("DPanel", section)
    content:Dock(FILL)
    content:DockMargin(0, 0, 0, 0)
    
    content.Paint = function(self, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, Color(40, 40, 45), false, false, true, true)
    end
    
    -- Button container
    local buttonPanel = vgui.Create("DPanel", content)
    buttonPanel:Dock(FILL)
    buttonPanel:DockMargin(10, 10, 10, 10)
    buttonPanel:SetPaintBackground(false)
    
    -- Rename button
    local renameBtn = self:CreateStyledButton(buttonPanel, "Rename Profile")
    renameBtn:Dock(LEFT)
    renameBtn:DockMargin(0, 0, 5, 0)
    renameBtn:SetWide(parent:GetWide() / 2 - 25)
    
    renameBtn.DoClick = function()
        self:OpenRenameDialog(profileName, displayName)
    end
    
    -- Reset binds button
    local resetBtn = self:CreateStyledButton(buttonPanel, "Reset Binds")
    resetBtn:Dock(RIGHT)
    resetBtn:DockMargin(5, 0, 0, 0)
    resetBtn:SetWide(parent:GetWide() / 2 - 25)
    resetBtn.CustomColor = Color(150, 40, 40)
    
    resetBtn.DoClick = function()
        Derma_Query(
            "Are you sure you want to reset all binds for " .. displayName .. "?",
            "Confirm Reset",
            "Yes",
            function()
                self:ResetProfile(profileName)
            end,
            "No",
            function() end
        )
    end
    
    return section
end

function KEYBIND.Settings:OpenRenameDialog(profileName, currentName)
    local dialog = vgui.Create("DFrame")
    dialog:SetSize(300, 130)
    dialog:Center()
    dialog:SetTitle("")
    dialog:MakePopup()
    dialog:ShowCloseButton(false)
    
    dialog.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 35, 245))
        draw.RoundedBoxEx(8, 0, 0, w, 30, Color(40, 40, 45), true, true, false, false)
        draw.SimpleText("Rename Profile", "KeybindSettingsText", 10, 15, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    local closeBtn = vgui.Create("DButton", dialog)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(dialog:GetWide() - 35, 0)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local color = self:IsHovered() and Color(255, 80, 80) or Color(200, 60, 60)
        draw.SimpleText("✕", "KeybindSettingsTitle", w/2, h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function() dialog:Remove() end
    
    local textEntry = vgui.Create("DTextEntry", dialog)
    textEntry:SetPos(15, 45)
    textEntry:SetSize(270, 30)
    textEntry:SetValue(currentName)
    textEntry:SelectAllText()
    
    textEntry.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 55))
        self:DrawTextEntryText(Color(230, 230, 230), Color(80, 150, 220), Color(230, 230, 230))
    end
    
    local saveBtn = vgui.Create("DButton", dialog)
    saveBtn:SetPos(15, 85)
    saveBtn:SetSize(270, 30)
    saveBtn:SetText("")
    
    saveBtn.Paint = function(self, w, h)
        local baseColor = self:IsHovered() and Color(80, 150, 220) or Color(60, 120, 190)
        draw.RoundedBox(4, 0, 0, w, h, baseColor)
        
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        
        draw.SimpleText("Save", "KeybindSettingsButton", w/2, h/2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    saveBtn.DoClick = function()
        local newName = textEntry:GetValue()
        if newName ~= "" then
            KEYBIND.Storage:RenameProfile(profileName, newName)
            dialog:Remove()
            
            -- Refresh the settings menu
            timer.Simple(0.1, function()
                if IsValid(self.Frame) then
                    self:Create()
                end
            end)
        end
    end
end
