--[[
    File for settings menu, majority can go untouched unless adding your own settings or altering default profiles/rank limits.
                                                                                                                                ]]--

KEYBIND.Settings = KEYBIND.Settings or {}

-- Default settings configuration
KEYBIND.Settings.Config = {
    showFeedback = true
    -- Add any other settings here
}

local GRADIENT = Material("gui/gradient_up")
local GRADIENT_DOWN = Material("gui/gradient_down")

-- Create fonts for the settings menu
surface.CreateFont("KeybindSettingsTitle", {
    font = "Roboto",
    size = 20,
    weight = 600,
    antialias = true
})

surface.CreateFont("KeybindSettingsCurrentTitle", {
    font = "Roboto",
    size = 16,
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

-- Settings Save/Load Functions
function KEYBIND.Settings:SaveSettings()
    local data = {
        showFeedback = self.Config.showFeedback
        -- Add other settings here
    }
    
    file.CreateDir("bindmenu")
    file.Write("bindmenu/settings.txt", util.TableToJSON(data, true))
    print("[KEYBIND] Saved settings to disk")
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

-- Safe gradient drawing function
function KEYBIND.Settings:SafeDrawGradient(material, x, y, w, h, color)
    if not material or material:IsError() then return end
    
    surface.SetDrawColor(color or Color(255, 255, 255, 10))
    surface.SetMaterial(material)
    surface.DrawTexturedRect(x, y, w, h)
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

    -- Create the main frame
    self.Frame = vgui.Create("DFrame")
    self.Frame:SetSize(500, 550)
    self.Frame:Center()
    self.Frame:SetTitle("")
    self.Frame:MakePopup()
    self.Frame:ShowCloseButton(false)
    self.Frame:SetDraggable(true)
    
    -- Modern dark theme
    self.Frame.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0)
        draw.RoundedBox(10, 0, 0, w, h, Color(20, 20, 25, 240))
        draw.RoundedBoxEx(10, 0, 0, w, 50, Color(40, 90, 140), true, true, false, false)
        draw.SimpleText("Bind Menu Settings", "KeybindSettingsTitle", 24, 24, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- Close button
    local closeBtn = vgui.Create("DButton", self.Frame)
    closeBtn:SetSize(36, 36)
    closeBtn:SetPos(self.Frame:GetWide() - 46, 7)
    closeBtn:SetText("X")
    closeBtn:SetFont("KeybindSettingsTitle")
    closeBtn:SetTextColor(Color(255, 255, 255))
    closeBtn.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, self:IsHovered() and Color(255, 80, 80, 200) or Color(255, 255, 255, 30))
    end
    closeBtn.DoClick = function() self.Frame:Remove() end
    
    -- Create scroll panel
    local scroll = vgui.Create("DScrollPanel", self.Frame)
    scroll:Dock(FILL)
    scroll:DockMargin(15, 60, 15, 60)
    
    -- Add general settings section
    self:AddSimpleGeneralSettings(scroll)
    
    -- Add profile sections
    self:AddSimpleProfileSettings(scroll)
    
    -- Add reset all button
    local resetAllBtn = vgui.Create("DButton", self.Frame)
    resetAllBtn:SetSize(200, 40)
    resetAllBtn:SetPos(self.Frame:GetWide()/2 - 100, self.Frame:GetTall() - 50)
    resetAllBtn:SetText("Reset All Profiles")
    resetAllBtn:SetFont("KeybindSettingsButton")
    resetAllBtn:SetTextColor(Color(255, 255, 255))
    
    resetAllBtn.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, self:IsHovered() and Color(200, 60, 60) or Color(170, 50, 50))
    end
    
    resetAllBtn.DoClick = function()
        Derma_Query(
            "Are you sure you want to reset ALL profiles?\nThis cannot be undone!",
            "Confirm Reset",
            "Yes", function() self:DeleteAllProfiles() end,
            "No", function() end
        )
    end
end


function KEYBIND.Settings:AddSimpleGeneralSettings(parent)
    -- General settings panel
    local panel = vgui.Create("DPanel", parent)
    panel:Dock(TOP)
    panel:SetHeight(80)
    panel:DockMargin(0, 0, 0, 10)
    
    panel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 40))
        draw.RoundedBoxEx(8, 0, 0, w, 30, Color(45, 45, 50), true, true, false, false)
        draw.SimpleText("General Settings", "KeybindSettingsText", 10, 15, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- Feedback checkbox
    local feedbackCheck = vgui.Create("DCheckBoxLabel", panel)
    feedbackCheck:SetPos(15, 45)
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
end

function KEYBIND.Settings:AddSimpleProfileSettings(parent)
    local userGroup = LocalPlayer():GetUserGroup()
    local accessLevel = 0
    
    if userGroup == "loyalty" then
        accessLevel = 2
    elseif userGroup == "premium" then
        accessLevel = 1
    end
    
    local maxProfiles = 3
    if accessLevel == 2 then
        maxProfiles = 7
    elseif accessLevel == 1 then
        maxProfiles = 5
    end
    
    -- Define base profiles with proper access levels
    local baseProfiles = {
        {name = "Profile1", displayName = "Profile 1", access = 0, color = Color(60, 130, 200)},
        {name = "Profile2", displayName = "Profile 2", access = 0, color = Color(60, 130, 200)},
        {name = "Profile3", displayName = "Profile 3", access = 0, color = Color(60, 130, 200)},
        {name = "Premium1", displayName = "Premium 4", access = 1, color = Color(200, 130, 60)},
        {name = "Premium2", displayName = "Premium 5", access = 1, color = Color(200, 130, 60)},
        {name = "Premium3", displayName = "Loyalty 6", access = 2, color = Color(130, 200, 60)},
        {name = "Premium4", displayName = "Loyalty 7", access = 2, color = Color(130, 200, 60)}
    }
    
    -- Add sections for profiles the user has access to
    for i, profileData in ipairs(baseProfiles) do
        if profileData.access <= accessLevel and i <= maxProfiles then
            self:AddSimpleProfileCard(parent, profileData.name, profileData.color)
        end
    end
end

function KEYBIND.Settings:AddSimpleProfileCard(parent, profileName, accentColor)
    local storedProfile = KEYBIND.Storage.Profiles[profileName]
    if not storedProfile then return end
    
    local displayName = storedProfile.displayName or profileName
    local isCurrentProfile = KEYBIND.Storage.CurrentProfile == profileName
    
    -- Create a container for the entire card including profile picture selector
    local container = vgui.Create("DPanel", parent)
    container:Dock(TOP)
    container:SetPaintBackground(false)
    container:DockMargin(0, 0, 0, 20)
    
    -- Create the main profile panel
    local panel = vgui.Create("DPanel", container)
    panel:Dock(TOP)
    panel:SetHeight(100)
    panel:DockMargin(0, 0, 0, 0)
    
    panel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 40))
        draw.RoundedBoxEx(8, 0, 0, w, 30, isCurrentProfile and accentColor or Color(45, 45, 50), true, true, false, false)
        
        -- Draw profile name
        draw.SimpleText(displayName, "KeybindSettingsText", 10, 15, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Draw current indicator if active
        if isCurrentProfile then
            draw.SimpleText("ACTIVE", "KeybindSettingsText", w - 10, 15, Color(230, 230, 230), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
        
        -- Draw profile icon
        local iconName = storedProfile.icon or "Profile1"
        local iconMat = KEYBIND.Menu.ProfileIcons[iconName]
        
        if iconMat then
            -- Draw icon in the header
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(iconMat)
            surface.DrawTexturedRect(w - 50, 5, 20, 20)
        end
    end
    
    -- Create buttons with standard Derma components
    local renameBtn = vgui.Create("DButton", panel)
    renameBtn:SetSize(panel:GetWide() / 2 - 20, 36)
    renameBtn:SetPos(10, 45)
    renameBtn:SetText("Rename Profile")
    renameBtn:SetFont("KeybindSettingsButton")
    renameBtn:SetTextColor(Color(255, 255, 255))
    
    renameBtn.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(70, 150, 220) or Color(60, 130, 200))
    end
    
    renameBtn.DoClick = function()
        self:OpenSimpleRenameDialog(profileName, displayName)
    end
    
    local resetBtn = vgui.Create("DButton", panel)
    resetBtn:SetSize(panel:GetWide() / 2 - 20, 36)
    resetBtn:SetPos(panel:GetWide() / 2 + 10, 45)
    resetBtn:SetText("Reset Binds")
    resetBtn:SetFont("KeybindSettingsButton")
    resetBtn:SetTextColor(Color(255, 255, 255))
    
    resetBtn.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(220, 70, 70) or Color(200, 60, 60))
    end
    
    resetBtn.DoClick = function()
        Derma_Query(
            "Are you sure you want to reset all binds for " .. displayName .. "?",
            "Confirm Reset",
            "Yes", function() self:ResetProfile(profileName) end,
            "No", function() end
        )
    end
    
    -- Fix button positions after parent is fully created
    panel.PerformLayout = function(self, w, h)
        renameBtn:SetSize(w / 2 - 20, 36)
        renameBtn:SetPos(10, 45)
        
        resetBtn:SetSize(w / 2 - 20, 36)
        resetBtn:SetPos(w / 2 + 10, 45)
    end
    
    -- Create collapsible profile picture selector
    local pictureSelector = vgui.Create("DCollapsibleCategory", container)
    pictureSelector:Dock(TOP)
    pictureSelector:SetLabel("Profile Picture")
    pictureSelector:SetExpanded(false)
    pictureSelector:DockMargin(0, 10, 0, 0)
    
    -- Style the collapsible category
    pictureSelector.Header:SetTall(30)
    pictureSelector.Header.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(45, 45, 50))
        
        -- Draw arrow
        local arrowSize = 8
        local arrowX = 15
        local arrowY = h/2
        
        surface.SetDrawColor(230, 230, 230, 200)
        if pictureSelector:GetExpanded() then
            surface.DrawLine(arrowX - arrowSize/2, arrowY + arrowSize/2, arrowX + arrowSize/2, arrowY - arrowSize/2)
            surface.DrawLine(arrowX + arrowSize/2, arrowY - arrowSize/2, arrowX + arrowSize*1.5, arrowY + arrowSize/2)
        else
            surface.DrawLine(arrowX - arrowSize/2, arrowY - arrowSize/2, arrowX + arrowSize/2, arrowY + arrowSize/2)
            surface.DrawLine(arrowX + arrowSize/2, arrowY + arrowSize/2, arrowX + arrowSize*1.5, arrowY - arrowSize/2)
        end
    end
    
    -- Create the icon selector inside the collapsible category
    local iconContainer = vgui.Create("DPanel", pictureSelector)
    iconContainer:SetPaintBackground(false)
    iconContainer:SetHeight(240)
    
    -- Add the profile picture selector to the container
    self:CreateProfilePictureSelector(iconContainer, profileName)
    
    -- Set the contents of the collapsible category
    pictureSelector:SetContents(iconContainer)
    
    return container
end

function KEYBIND.Settings:CreateStyledButton(parent, text, baseColor)
    local btn = vgui.Create("DButton", parent)
    btn:SetText("")
    btn:SetHeight(36)
    
    baseColor = baseColor or Color(60, 60, 65)
    
    btn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(
            math.min(baseColor.r + 20, 255),
            math.min(baseColor.g + 20, 255),
            math.min(baseColor.b + 20, 255)
        ) or baseColor
        
        -- Button background with rounded corners
        draw.RoundedBox(6, 0, 0, w, h, color)
        
        -- Add subtle gradient
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(GRADIENT)
        surface.DrawTexturedRect(0, 0, w, h)
        
        -- Text with shadow for depth
        draw.SimpleText(text, "KeybindSettingsButton", w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(text, "KeybindSettingsButton", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    return btn
end

function KEYBIND.Settings:OpenSimpleRenameDialog(profileName, currentName)
    local dialog = vgui.Create("DFrame")
    dialog:SetSize(300, 130)
    dialog:Center()
    dialog:SetTitle("Rename Profile")
    dialog:MakePopup()
    
    local textEntry = vgui.Create("DTextEntry", dialog)
    textEntry:SetPos(10, 30)
    textEntry:SetSize(280, 30)
    textEntry:SetValue(currentName)
    textEntry:SelectAllText()
    
    local saveBtn = vgui.Create("DButton", dialog)
    saveBtn:SetPos(10, 70)
    saveBtn:SetSize(280, 30)
    saveBtn:SetText("Save")
    
    saveBtn.DoClick = function()
        local newName = textEntry:GetValue()
        if newName ~= "" then
            KEYBIND.Storage:RenameProfile(profileName, newName)
            dialog:Remove()
            
            timer.Simple(0.1, function()
                if IsValid(self.Frame) then
                    self:Create()
                end
            end)
        end
    end
end

function KEYBIND.Settings:DeleteAllProfiles()
    -- Initialize with default profiles based on rank
    local userGroup = LocalPlayer():GetUserGroup()
    local accessLevel = 0
    
    if userGroup == "loyalty" then
        accessLevel = 2
    elseif userGroup == "premium" then
        accessLevel = 1
    end
    
    local maxProfiles = 3
    if accessLevel == 2 then
        maxProfiles = 7
    elseif accessLevel == 1 then
        maxProfiles = 5
    end
    
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
