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

    self.Frame = vgui.Create("DFrame")
    self.Frame:SetSize(500, 600)
    self.Frame:Center()
    self.Frame:SetTitle("")
    self.Frame:MakePopup()
    self.Frame:ShowCloseButton(false)
    self.Frame:SetDraggable(false)

    -- Main frame paint
    self.Frame.Paint = function(self, w, h)
        -- Blur background
        Derma_DrawBackgroundBlur(self, 0)
        
        -- Main background with transparency
        draw.RoundedBox(8, 0, 0, w, h, KEYBIND.Colors.background)
        
        -- Gradient overlay (with error checking)
        if GRADIENT and not GRADIENT:IsError() then
            surface.SetDrawColor(255, 255, 255, 10)
            surface.SetMaterial(GRADIENT)
            surface.DrawTexturedRect(0, 0, w, h)
        end
        
        -- Header
        draw.RoundedBoxEx(8, 0, 0, w, 40, KEYBIND.Colors.sectionHeader, true, true, false, false)
        draw.SimpleText("Profile Settings", "DermaLarge", w/2, 20, KEYBIND.Colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Border
        surface.SetDrawColor(KEYBIND.Colors.border)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end

    -- Close button
    local closeBtn = vgui.Create("DButton", self.Frame)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(self.Frame:GetWide() - 35, 5)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local color = self:IsHovered() and Color(255, 80, 80) or Color(200, 60, 60)
        draw.SimpleText("✕", "DermaLarge", w/2, h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function() self.Frame:Remove() end

    -- Scroll panel for profile sections
    local scroll = vgui.Create("DScrollPanel", self.Frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 50, 10, 50)

    -- Custom scrollbar
    local scrollbar = scroll:GetVBar()
    scrollbar:SetWide(8)
    scrollbar.Paint = function(self, w, h) end
    scrollbar.btnUp.Paint = function(self, w, h) end
    scrollbar.btnDown.Paint = function(self, w, h) end
    scrollbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, KEYBIND.Colors.keyDefault)
    end

    -- Add Settings Section
local settingsSection = vgui.Create("DPanel", scroll)
settingsSection:Dock(TOP)
settingsSection:SetHeight(80)
settingsSection:DockMargin(0, 0, 0, 10)

settingsSection.Paint = function(self, w, h)
    -- Section background
    draw.RoundedBox(8, 0, 0, w, h, KEYBIND.Colors.sectionBackground)
    
    -- Gradient overlay
    if GRADIENT and not GRADIENT:IsError() then
        surface.SetDrawColor(255, 255, 255, 5)
        surface.SetMaterial(GRADIENT)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    
    -- Section title
    draw.SimpleText("General Settings", "KeybindSettingsFont", 15, 15, KEYBIND.Colors.text)
end

-- Create checkbox for Show Feedback
local feedbackCheck = vgui.Create("DCheckBoxLabel", settingsSection)
feedbackCheck:SetPos(15, 40)
feedbackCheck:SetText("Show Feedback Messages")
feedbackCheck:SetTextColor(KEYBIND.Colors.text)
feedbackCheck:SetFont("KeybindSettingsFont")
feedbackCheck:SizeToContents()
feedbackCheck:SetValue(KEYBIND.Settings.Config.showFeedback)

feedbackCheck.OnChange = function(self, val)
    KEYBIND.Settings.Config.showFeedback = val
    KEYBIND.Settings:SaveSettings()
    
    -- Optional: Show feedback about the setting change
    if val then
        chat.AddText(Color(0, 255, 0), "[BindMenu] Feedback messages enabled")
    else
        chat.AddText(Color(255, 0, 0), "[BindMenu] Feedback messages disabled")
    end
end

-- Optional: Custom paint for the checkbox
feedbackCheck.Button.Paint = function(self, w, h)
    local checkColor = self:GetChecked() and KEYBIND.Colors.accent or KEYBIND.Colors.keyDefault
    draw.RoundedBox(4, 0, 0, w, h, checkColor)
    
    if self:GetChecked() then
        surface.SetDrawColor(255, 255, 255)
        draw.SimpleText("✓", "KeybindSettingsFont", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

-- Create profile sections
for _, profileName in ipairs(KEYBIND.Config.DefaultProfiles) do
    local storedProfile = KEYBIND.Storage.Profiles[profileName]
    local displayName = storedProfile and (storedProfile.displayName or storedProfile.name) or profileName
    local section = vgui.Create("DPanel", scroll)
    section:Dock(TOP)
    section:SetHeight(100)
    section:DockMargin(0, 0, 0, 10)
    
    -- Get the stored name or use default
    local storedName = KEYBIND.Storage.Profiles[profileName] and KEYBIND.Storage.Profiles[profileName].name or profileName
    
    section.Paint = function(self, w, h)
        -- Section background
        draw.RoundedBox(8, 0, 0, w, h, KEYBIND.Colors.sectionBackground)
        
        -- Gradient overlay (with error checking)
        if GRADIENT and not GRADIENT:IsError() then
            surface.SetDrawColor(255, 255, 255, 5)
            surface.SetMaterial(GRADIENT)
            surface.DrawTexturedRect(0, 0, w, h)
        end
        
        -- Profile title
        draw.SimpleText(displayName, "KeybindSettingsFont", 15, 15, KEYBIND.Colors.text)
    end

    -- Button container
    local buttonPanel = vgui.Create("DPanel", section)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:SetHeight(50)
    buttonPanel:DockMargin(10, 0, 10, 10)
    buttonPanel:SetPaintBackground(false)

    -- Rename button
    local renameBtn = self:CreateStyledButton(buttonPanel, "Rename")
    renameBtn:Dock(LEFT)
    renameBtn:SetWide(230)
        renameBtn.DoClick = function()
            Derma_StringRequest(
                "Rename Profile",
                "Enter new name for " .. storedName,
                storedName,
                function(newName)
                    KEYBIND.Storage:RenameProfile(profileName, newName)
                end,
                function() end,
                "Confirm",
                "Cancel"
            )
        end

        -- Reset binds button
        local resetBtn = self:CreateStyledButton(buttonPanel, "Reset Binds")
        resetBtn:Dock(RIGHT)
        resetBtn:SetWide(230)
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
    end

    -- Delete all profiles button
    local deleteAll = self:CreateStyledButton(self.Frame, "Delete All Profiles")
    deleteAll:Dock(BOTTOM)
    deleteAll:SetHeight(40)
    deleteAll:DockMargin(10, 0, 10, 10)
    deleteAll.CustomColor = Color(200, 60, 60)
    deleteAll.DoClick = function()
        Derma_Query(
            "Are you sure you want to delete ALL profiles?\nThis cannot be undone!",
            "Confirm Delete All",
            "Yes",
            function()
                self:DeleteAllProfiles()
            end,
            "No",
            function() end
        )
    end
end

-- Helper function to create styled buttons
function KEYBIND.Settings:CreateStyledButton(parent, text)
    local btn = vgui.Create("DButton", parent)
    btn:SetText("")
    
    local hoverAlpha = 0
    
    btn.Think = function(self)
        hoverAlpha = Lerp(FrameTime() * 8, hoverAlpha, self:IsHovered() and 1 or 0)
    end
    
    btn.Paint = function(self, w, h)
        local baseColor = self.CustomColor or KEYBIND.Colors.keyDefault
        local hoverColor = self.CustomColor and Color(
            math.min(baseColor.r + 20, 255),
            math.min(baseColor.g + 20, 255),
            math.min(baseColor.b + 20, 255)
        ) or KEYBIND.Colors.keyHover
        
        -- Background
        draw.RoundedBox(6, 0, 0, w, h, baseColor)
        
        -- Hover effect
        if hoverAlpha > 0 then
            surface.SetDrawColor(hoverColor.r, hoverColor.g, hoverColor.b, 255 * hoverAlpha)
            draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 30 * hoverAlpha))
        end
        
        -- Gradient overlay (with error checking)
        if GRADIENT and not GRADIENT:IsError() then
            surface.SetDrawColor(255, 255, 255, 20)
            surface.SetMaterial(GRADIENT)
            surface.DrawTexturedRect(0, 0, w, h)
        end
        
        -- Text
        draw.SimpleText(text, "DermaDefaultBold", w/2, h/2, KEYBIND.Colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
    local maxProfiles = 3 -- Default User rank
    local userGroup = LocalPlayer():GetUserGroup()
    
    if userGroup == "premium" then
        maxProfiles = 5
    elseif userGroup == "loyalty" then
        maxProfiles = 7
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
        local hasAccess = false
        
        if profile.access == 0 then 
            hasAccess = true
        elseif profile.access == 1 then 
            hasAccess = userGroup == "premium" or userGroup == "loyalty"
        elseif profile.access == 2 then 
            hasAccess = userGroup == "loyalty"
        end

        if hasAccess and i <= maxProfiles then
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

-- Update ResetProfile to use the settings config
function KEYBIND.Settings:ResetProfile(profile)
    if KEYBIND.Storage.Profiles[profile] then
        KEYBIND.Storage.Profiles[profile].binds = {}
        KEYBIND.Storage:SaveBinds()
        
        if self.Config.showFeedback then
            chat.AddText(Color(0, 255, 0), "[BindMenu] Reset all binds for profile: " .. profile)
        end
        
        if IsValid(KEYBIND.Menu.Frame) then
            KEYBIND.Menu:RefreshKeyboardLayout()
        end
    end
end