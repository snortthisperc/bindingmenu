KEYBIND.Settings = KEYBIND.Settings or {}

KEYBIND.Settings.Config = {
    showFeedback = false,
    debugMode = false,
    highlightCatgegory = nil,
    autoScale = true,  
    keyboardScale = 1.0,
    keyboardLayout = "StandardKeyboard"
}

function KEYBIND.Settings:CreateFonts()
    surface.CreateFont("KeybindSettingsTitle", {
        font = "Roboto",
        size = 24,
        weight = 600,
        antialias = true
    })
    
    surface.CreateFont("KeybindSettingsHeader", {
        font = "Roboto",
        size = 18,
        weight = 600,
        antialias = true
    })
    
    surface.CreateFont("KeybindSettingsText", {
        font = "Roboto",
        size = 16,
        weight = 500,
        antialias = true
    })

    surface.CreateFont("KeybindSettingsSubtext", {
        font = "Roboto",
        size = 13,
        weight = 400,
        antialias = true
    })
    
    surface.CreateFont("KeybindSettingsButton", {
        font = "Roboto",
        size = 16,
        weight = 600,
        antialias = true
    })
    
    surface.CreateFont("BindDialogFont", {
        font = "Roboto",
        size = 16,
        weight = 500,
        antialias = true,
        shadow = false
    })
    
    print("[BindMenu] Fonts created")
end

function KEYBIND.Settings:GetTheme()
    -- If we have a cached theme and nothing has changed, return it
    if self.cachedTheme then
        return self.cachedTheme
    end
    
    -- Make sure we have a Config table
    self.Config = self.Config or {}
    
    local isDarkTheme = self.Config.darkTheme
    local accentColor = self.Config.accentColor or Color(60, 130, 200)
    
    -- Make sure KEYBIND.Colors exists
    KEYBIND.Colors = KEYBIND.Colors or {}
    
    -- If colors haven't been initialized yet, do it now
    if not KEYBIND.Colors.background then
        self:UpdateThemeColors()
    end
    
    local theme = {}
    
    -- Safely get colors with fallbacks
    theme.background = KEYBIND.Colors.background or Color(25, 25, 30)
    theme.cardBackground = KEYBIND.Colors.sectionBackground or Color(30, 30, 35)
    theme.cardHeader = KEYBIND.Colors.sectionHeader or Color(35, 35, 40)
    theme.text = KEYBIND.Colors.text or Color(230, 230, 230)
    theme.buttonDefault = KEYBIND.Colors.keyDefault or Color(35, 35, 40)
    theme.buttonHover = KEYBIND.Colors.keyHover or Color(45, 45, 50)
    theme.accent = accentColor
    theme.shadow = KEYBIND.Colors.shadow or Color(0, 0, 0, 100)
    theme.keyboardBackground = KEYBIND.Colors.keyboardBackground or Color(20, 20, 25)
    
    -- Cache the theme
    self.cachedTheme = theme
    
    return theme
end

function KEYBIND.Settings:Initialize()
    -- Load saved settings
    self:LoadSettings()
    
    -- Initialize theme colors
    self:UpdateThemeColors()
    
    print("[BindMenu] Settings initialized")
end

function KEYBIND.Settings:InitializeTheme()
    self:CreateFonts()
    
    if not self.Config.accentColor or type(self.Config.accentColor) ~= "table" or not self.Config.accentColor.r then
        self.Config.accentColor = Color(60, 130, 200)
    end
    
    if self.Config.darkTheme == nil then
        self.Config.darkTheme = true
    end
    
    self:LoadSettings()
    
    if IsValid(KEYBIND.Menu.Frame) then
        KEYBIND.Menu:RefreshTheme()
    end
    
    print("[BindMenu] Theme system initialized")
end

function KEYBIND.Settings:GetThemedColor(colorName, accentBlend)
    local theme = self:GetTheme()
    local color = theme[colorName]
    
    if not color then
        return Color(255, 0, 255)
    end
    
    if accentBlend and accentBlend > 0 and self.Config.accentColor then
        local accent = self.Config.accentColor
        return Color(
            color.r * (1 - accentBlend) + accent.r * accentBlend,
            color.g * (1 - accentBlend) + accent.g * accentBlend,
            color.b * (1 - accentBlend) + accent.b * accentBlend,
            color.a
        )
    end
    
    return color
end

function KEYBIND.Settings:ApplyThemeToDialog(dialog, title)
    local theme = self:GetTheme()
    local accentColor = self.Config.accentColor or Color(60, 130, 200)
    
    dialog.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0)
        draw.RoundedBox(10, 0, 0, w, h, theme.dialogBackground)
        
        draw.RoundedBoxEx(10, 0, 0, w, 40, accentColor, true, true, false, false)
        
        if title then
            draw.SimpleText(title, "BindDialogFont", 15, 20, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(title, "BindDialogFont", 14, 19, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
    
    for _, child in pairs(dialog:GetChildren()) do
        if child:GetClassName() == "DButton" then
            local x, y = child:GetPos()
            if x > dialog:GetWide() - 50 and y < 20 then
                child.Paint = function(self, w, h)
                    local hovered = self:IsHovered()
                    local color = hovered and Color(255, 80, 80, 200) or Color(255, 255, 255, 30)
                    draw.RoundedBox(8, 0, 0, w, h, color)
                    local padding = 10
                    local xcolor = hovered and Color(255, 255, 255) or Color(220, 220, 220)
                    surface.SetDrawColor(xcolor)
                    surface.DrawLine(padding, padding, w-padding, h-padding)
                    surface.DrawLine(w-padding, padding, padding, h-padding)
                end
            end
        end
    end
end

function KEYBIND.Settings:ApplyThemeToButton(button, accentColor)
    local theme = self:GetTheme()
    accentColor = accentColor or false
    
    button.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local baseColor = hovered and theme.buttonHover or theme.buttonDefault
        
        if accentColor then
            baseColor = hovered and 
                Color(KEYBIND.Settings.Config.accentColor.r + 10, KEYBIND.Settings.Config.accentColor.g + 10, KEYBIND.Settings.Config.accentColor.b + 10) or 
                KEYBIND.Settings.Config.accentColor
        end
        
        draw.RoundedBox(6, 0, 0, w, h, baseColor)
        
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        
        local text = self:GetText()
        draw.SimpleText(text, "KeybindSettingsButton", w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(text, "KeybindSettingsButton", w/2, h/2, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function KEYBIND.Settings:ApplyThemeToPanel(panel, headerText)
    local theme = self:GetTheme()
    local accentColor = self.Config.accentColor or Color(60, 130, 200)
    
    panel.Paint = function(self, w, h)
        draw.RoundedBox(8, 2, 2, w-4, h-4, theme.shadow)
        draw.RoundedBox(8, 0, 0, w, h, theme.cardBackground)
        
        if headerText then
            local headerColor = Color(
                theme.cardHeader.r * 0.8 + accentColor.r * 0.2,
                theme.cardHeader.g * 0.8 + accentColor.g * 0.2,
                theme.cardHeader.b * 0.8 + accentColor.b * 0.2
            )
            
            draw.RoundedBoxEx(8, 0, 0, w, 36, headerColor, true, true, false, false)
            
            draw.SimpleText(headerText, "KeybindSettingsHeader", 15, 18, theme.shadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(headerText, "KeybindSettingsHeader", 14, 17, theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
    
    if headerText then
        panel.title = headerText
    end
end

function KEYBIND.Settings:SaveSettings()
    local data = {
        showFeedback = self.Config.showFeedback,
        debugMode = self.Config.debugMode or false,
        keyboardScale = KEYBIND.Renderer.Scale or 1.0,
        keyboardLayout = KEYBIND.Renderer.CurrentLayout or "StandardKeyboard",
        darkTheme = self.Config.darkTheme,
        accentColor = {
            r = self.Config.accentColor.r,
            g = self.Config.accentColor.g,
            b = self.Config.accentColor.b,
            a = self.Config.accentColor.a or 255
        },
        highlightCategory = self.Config.highlightCategory
    }
    
    file.CreateDir("bindmenu")
    file.Write("bindmenu/settings.txt", util.TableToJSON(data, true))
    print("[BindMenu] Saved settings to disk")
end

function KEYBIND.Settings:LoadSettings()
    local data = file.Read("bindmenu/settings.txt", "DATA")
    if data then
        local success, settings = pcall(util.JSONToTable, data)
        if success and settings then
            for k, v in pairs(settings) do
                if k ~= "accentColor" then
                    self.Config[k] = v
                end
            end
            
            if settings.accentColor then
                self.Config.accentColor = Color(
                    settings.accentColor.r or 60,
                    settings.accentColor.g or 130,
                    settings.accentColor.b or 200,
                    settings.accentColor.a or 255
                )
            else
                self.Config.accentColor = Color(60, 130, 200)
            end
        end
    end
    
    if not self.Config.accentColor or type(self.Config.accentColor) ~= "table" or not self.Config.accentColor.r then
        self.Config.accentColor = Color(60, 130, 200)
    end
end

hook.Add("Initialize", "KEYBIND_Settings_Init", function()
    KEYBIND.Settings:LoadSettings()
end)

hook.Add("ShutDown", "KEYBIND_Settings_Save", function()
    if KEYBIND and KEYBIND.Settings then
        KEYBIND.Settings:SaveSettings()
    end
end)

function KEYBIND.Settings:Create()
    if IsValid(self.Frame) then
        self.Frame:Remove()
    end

    local theme = self:GetTheme()
    local accentColor = self.Config.accentColor or Color(60, 130, 200)

    self.Frame = vgui.Create("DFrame")
    self.Frame:SetSize(550, 600)
    self.Frame:Center()
    self.Frame:SetTitle("")
    self.Frame:MakePopup()
    self.Frame:ShowCloseButton(false)
    self.Frame:SetDraggable(true)
    
    self.Frame.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0)
        
        draw.RoundedBox(10, 0, 0, w, h, theme.background)
        
        draw.RoundedBoxEx(10, 0, 0, w, 50, accentColor, true, true, false, false)
        
        draw.SimpleText("Bind Menu Settings", "KeybindSettingsTitle", 25, 25, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Bind Menu Settings", "KeybindSettingsTitle", 24, 24, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    local closeBtn = vgui.Create("DButton", self.Frame)
    closeBtn:SetSize(36, 36)
    closeBtn:SetPos(self.Frame:GetWide() - 46, 7)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(255, 80, 80, 200) or Color(255, 255, 255, 30)
        
        draw.RoundedBox(8, 0, 0, w, h, color)
        
        local padding = 12
        local color = hovered and Color(255, 255, 255) or Color(220, 220, 220)
        
        surface.SetDrawColor(color)
        surface.DrawLine(padding, padding, w-padding, h-padding)
        surface.DrawLine(w-padding, padding, padding, h-padding)
    end
    closeBtn.DoClick = function() self.Frame:Remove() end
    
    local scroll = vgui.Create("DScrollPanel", self.Frame)
    scroll:Dock(FILL)
    scroll:DockMargin(20, 60, 20, 60)
    
    local scrollbar = scroll:GetVBar()
    scrollbar:SetWide(6)
    scrollbar.Paint = function(self, w, h) end
    scrollbar.btnUp.Paint = function(self, w, h) end
    scrollbar.btnDown.Paint = function(self, w, h) end
    scrollbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(255, 255, 255, 40))
    end
    
    self:AddGeneralSettings(scroll)
    
    self:AddAppearanceSettings(scroll)
    
    self:AddImportDefaultBindsSection(scroll)

    self:AddProfileSettings(scroll)
    
    if GetConVar("developer"):GetInt() > 0 then
        self:AddPerformanceMonitor(scroll)
    end
    
    local resetAllBtn = vgui.Create("DButton", self.Frame)
    resetAllBtn:SetSize(200, 40)
    resetAllBtn:SetPos(self.Frame:GetWide()/2 - 100, self.Frame:GetTall() - 50)
    resetAllBtn:SetText("Reset All Profiles")
    resetAllBtn:SetTextColor(Color(255, 255, 255))
    
    resetAllBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local baseColor = hovered and Color(200, 60, 60) or Color(170, 50, 50)
        
        draw.RoundedBox(8, 0, 0, w, h, baseColor)
        
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
    end
    
    resetAllBtn.DoClick = function()
        Derma_Query(
            "Are you sure you want to reset ALL profiles?\nThis cannot be undone!",
            "Confirm Reset",
            "Yes", function() self:DeleteAllProfiles() end,
            "No", function() end
        )
    end
    
    if GetConVar("developer"):GetInt() > 0 then
        self.Frame:SetTall(700)
        self.Frame:Center()
        
        resetAllBtn:SetPos(self.Frame:GetWide()/2 - 100, self.Frame:GetTall() - 50)
    end
end

if not KEYBIND.Settings.Config.accentColor or type(KEYBIND.Settings.Config.accentColor) ~= "table" or not KEYBIND.Settings.Config.accentColor.r then
    KEYBIND.Settings.Config.accentColor = Color(60, 130, 200)
end

function KEYBIND.Settings:UpdateThemeColors()
    -- Get current theme settings
    local isDarkTheme = self.Config.darkTheme
    local accentColor = self.Config.accentColor or Color(60, 130, 200)
    
    -- Update the global colors table based on theme
    if isDarkTheme then
        -- Dark theme colors
        KEYBIND.Colors = KEYBIND.Colors or {}
        KEYBIND.Colors.background = Color(25, 25, 30)
        KEYBIND.Colors.keyDefault = Color(35, 35, 40)
        KEYBIND.Colors.keyHover = Color(45, 45, 50)
        KEYBIND.Colors.text = Color(230, 230, 230)
        KEYBIND.Colors.profileSelected = Color(60, 60, 65)
        KEYBIND.Colors.profileUnselected = Color(45, 45, 50)
        KEYBIND.Colors.sectionBackground = Color(30, 30, 35)
        KEYBIND.Colors.border = Color(60, 60, 65)
        KEYBIND.Colors.shadow = Color(0, 0, 0, 100)
        KEYBIND.Colors.keyBackground = Color(40, 40, 45)
        KEYBIND.Colors.keyBackgroundHover = Color(50, 50, 55)
        KEYBIND.Colors.sectionHeader = Color(35, 35, 40)
        KEYBIND.Colors.keyboardBackground = Color(20, 20, 25)
    else
        -- Light theme colors
        KEYBIND.Colors = KEYBIND.Colors or {}
        KEYBIND.Colors.background = Color(240, 240, 245)
        KEYBIND.Colors.keyDefault = Color(225, 225, 230)
        KEYBIND.Colors.keyHover = Color(215, 215, 220)
        KEYBIND.Colors.text = Color(30, 30, 30)
        KEYBIND.Colors.profileSelected = Color(200, 200, 205)
        KEYBIND.Colors.profileUnselected = Color(220, 220, 225)
        KEYBIND.Colors.sectionBackground = Color(230, 230, 235)
        KEYBIND.Colors.border = Color(190, 190, 195)
        KEYBIND.Colors.shadow = Color(0, 0, 0, 30)
        KEYBIND.Colors.keyBackground = Color(220, 220, 225)
        KEYBIND.Colors.keyBackgroundHover = Color(210, 210, 215)
        KEYBIND.Colors.sectionHeader = Color(225, 225, 230)
        KEYBIND.Colors.keyboardBackground = Color(235, 235, 240)
    end
    
    -- Always update accent color
    KEYBIND.Colors.accent = accentColor
    KEYBIND.Colors.keyBound = accentColor
    
    -- Clear any cached theme
    self.cachedTheme = nil
    
    print("[BindMenu] Theme colors updated: " .. (isDarkTheme and "Dark" or "Light") .. " with accent " .. tostring(accentColor))
end

function KEYBIND.Settings:AddGeneralSettings(parent)
    local panel = vgui.Create("DPanel", parent)
    panel:Dock(TOP)
    panel:SetHeight(180)
    panel:DockMargin(0, 0, 0, 20)
    
    self:ApplyThemeToPanel(panel, "General Settings")
    
    local theme = self:GetTheme()
    
    local feedbackCheck = vgui.Create("DCheckBoxLabel", panel)
    feedbackCheck:SetPos(20, 55)
    feedbackCheck:SetText("Show Feedback Messages")
    feedbackCheck:SetTextColor(theme.text)
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
    
    local autoScaleCheck = vgui.Create("DCheckBoxLabel", panel)
    autoScaleCheck:SetPos(20, 85)
    autoScaleCheck:SetText("Auto-Scale to Screen Size")
    autoScaleCheck:SetTextColor(theme.text)
    autoScaleCheck:SetFont("KeybindSettingsText")
    autoScaleCheck:SizeToContents()
    autoScaleCheck:SetValue(self.Config.autoScale or false)
    
    autoScaleCheck.OnChange = function(self, val)
        KEYBIND.Settings.Config.autoScale = val
        KEYBIND.Settings:SaveSettings()
        
        if val then
            local screenW, screenH = ScrW(), ScrH()
            local scaleFactor = math.min(screenW / 1920, screenH / 1080)
            local calculatedScale = math.Clamp(scaleFactor, 0.7, 1.2)
            
            KEYBIND.Renderer.Scale = calculatedScale
            KEYBIND.Settings.Config.keyboardScale = calculatedScale
            KEYBIND.Settings:SaveSettings()
            
            if IsValid(KEYBIND.Menu.Frame) then
                KEYBIND.Menu:RefreshKeyboardLayout()
            end
            
            chat.AddText(Color(0, 255, 0), "[BindMenu] Auto-scaling enabled, scale set to " .. string.format("%.2f", calculatedScale))
        end
    end
    
    local themeCheck = vgui.Create("DCheckBoxLabel", panel)
    themeCheck:SetPos(20, 115)
    themeCheck:SetText("Dark Theme")
    themeCheck:SetTextColor(theme.text)
    themeCheck:SetFont("KeybindSettingsText")
    themeCheck:SizeToContents()
    themeCheck:SetValue(self.Config.darkTheme)
    
    themeCheck.OnChange = function(self, val)
        KEYBIND.Settings.Config.darkTheme = val
        KEYBIND.Settings:SaveSettings()
        
        -- Simply rebuild the menu
        if IsValid(KEYBIND.Menu.Frame) then
            KEYBIND.Menu:RebuildMenu()
        end
        
        -- Recreate the settings window if it's open
        if IsValid(KEYBIND.Settings.Frame) then
            local oldFrame = KEYBIND.Settings.Frame
            KEYBIND.Settings:Create()
            oldFrame:Remove()
        end
        
        chat.AddText(Color(0, 255, 0), "[BindMenu] " .. (val and "Dark" or "Light") .. " theme applied")
    end
    
    local function StyleCheckbox(checkbox)
        checkbox.Button.Paint = function(self, w, h)
            local checked = self:GetChecked()
            local hovered = self:IsHovered()
            
            local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
            local bgColor = checked and accentColor or theme.cardHeader
            if hovered then
                bgColor = Color(bgColor.r + 20, bgColor.g + 20, bgColor.b + 20)
            end
            
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
            
            if checked then
                surface.SetDrawColor(255, 255, 255)
                surface.DrawLine(3, h/2, w/2-1, h-3)
                surface.DrawLine(w/2-1, h-3, w-3, 3)
            end
        end
    end
    
    StyleCheckbox(feedbackCheck)
    StyleCheckbox(autoScaleCheck)
    StyleCheckbox(themeCheck)
    
    if GetConVar("developer"):GetInt() > 0 then
        local debugCheck = vgui.Create("DCheckBoxLabel", panel)
        debugCheck:SetPos(20, 145)
        debugCheck:SetText("Debug Mode (Show Layout Grid)")
        debugCheck:SetTextColor(theme.text)
        debugCheck:SetFont("KeybindSettingsText")
        debugCheck:SizeToContents()
        debugCheck:SetValue(self.Config.debugMode or false)
        
        debugCheck.OnChange = function(self, val)
            KEYBIND.Settings.Config.debugMode = val
            KEYBIND.Settings:SaveSettings()
            
            if IsValid(KEYBIND.Menu.Frame) then
                KEYBIND.Menu:RefreshKeyboardLayout()
            end
        end
        
        StyleCheckbox(debugCheck)
    end
    
    return panel
end

function KEYBIND.Settings:ImportGModBinds(profileName)
    local profile = KEYBIND.Storage.Profiles[profileName]
    if not profile then return false end
    
    if not profile.binds then
        profile.binds = {}
    end
    
    local excludePatterns = {
        "^%+forward", "^%+back", "^%+moveleft", "^%+moveright", "^%+jump", "^%+duck", 
        "^%+speed", "^%+walk", "^%+attack", "^%+attack2", "^%+reload", "^%+use", 
        "^%+zoom", "^%+showscores", "^toggleconsole", "^impulse 100", "^noclip", 
        "^kill", "^%+voicerecord", "^gm_show", "^slot%d+$", "^%+alt1", "^%+alt2",
        "^%+grenade1", "^%+grenade2", "^%+strafe", "^%+klook", "^%+mlook",
        "^%+jlook", "^%+left", "^%+right", "^%+lookup", "^%+lookdown",
        "^invprev", "^invnext", "^lastinv", "^phys_swap", "^ent_fire", "^jpeg",
        "^save", "^load", "^quit", "^screenshot", "^sizeup", "^sizedown"
    }
    
    local function shouldExclude(cmd)
        for _, pattern in ipairs(excludePatterns) do
            if string.find(cmd, pattern) then
                return true
            end
        end
        return false
    end
    
    local importCount = 0
    local conflictCount = 0
    local skipCount = 0
    local excludedCount = 0
    
    for i = 1, KEY_COUNT do
        local keyName = input.GetKeyName(i)
        if keyName and keyName ~= "UNBOUND" then
            local command = input.LookupKeyBinding(i)
            
            if command and command ~= "" then
                if shouldExclude(command) then
                    excludedCount = excludedCount + 1
                    continue
                end
                
                local ourKeyName = keyName:upper()
                
                if string.StartWith(ourKeyName, "PAD_") then
                    ourKeyName = string.sub(ourKeyName, 5)
                    ourKeyName = "KP_" .. ourKeyName
                end
                
                if ourKeyName == "LEFT" then ourKeyName = "←"
                elseif ourKeyName == "RIGHT" then ourKeyName = "→"
                elseif ourKeyName == "UP" then ourKeyName = "↑"
                elseif ourKeyName == "DOWN" then ourKeyName = "↓"
                end
                
                local validKey = false
                for section, sectionData in pairs(KEYBIND.Layout.StandardKeyboard.sections) do
                    for _, row in ipairs(sectionData.rows) do
                        for _, keyData in ipairs(row) do
                            local fullKey = (keyData.prefix or "") .. keyData.key
                            if fullKey == ourKeyName then
                                validKey = true
                                break
                            end
                        end
                        if validKey then break end
                    end
                    if validKey then break end
                end
                
                if validKey then
                    if profile.binds[ourKeyName] then
                        conflictCount = conflictCount + 1
                    else
                        profile.binds[ourKeyName] = command
                        importCount = importCount + 1
                    end
                else
                    skipCount = skipCount + 1
                end
            end
        end
    end
    
    KEYBIND.Storage:SaveBinds()
    
    if KEYBIND.Settings.Config.showFeedback then
        chat.AddText(Color(0, 255, 0), "[BindMenu] Imported " .. importCount .. " binds from Garry's Mod")
        if conflictCount > 0 then
            chat.AddText(Color(255, 150, 0), "[BindMenu] Skipped " .. conflictCount .. " binds due to conflicts")
        end
        if skipCount > 0 then
            chat.AddText(Color(255, 150, 0), "[BindMenu] Skipped " .. skipCount .. " binds due to incompatible keys")
        end
        if excludedCount > 0 then
            chat.AddText(Color(255, 150, 0), "[BindMenu] Excluded " .. excludedCount .. " essential game controls")
        end
    end
    
    return true, importCount, conflictCount, skipCount, excludedCount
end

function KEYBIND.Settings:AddImportDefaultBindsSection(parent)
    local theme = self:GetTheme()
    local accentColor = self.Config.accentColor or Color(60, 130, 200)

    -- Create the main card panel. We will set its height dynamically.
    local card = vgui.Create("DPanel", parent)
    card:Dock(TOP)
    card:DockMargin(0, 0, 0, 20)
    self:ApplyThemeToPanel(card, "Import Default Binds")

    -- Create the description label.
    local descLabel = vgui.Create("DLabel", card)
    descLabel:SetText("Import your current Garry's Mod binds into the active profile. This will exclude essential movement and game control commands.")
    descLabel:SetFont("KeybindSettingsText")
    descLabel:SetTextColor(theme.text)
    descLabel:SetWrap(true)
    descLabel:SetPos(20, 50) -- Initial Y position below the header.

    -- Create the import button.
    local importBtn = vgui.Create("DButton", card)
    importBtn:SetSize(200, 30)
    importBtn:SetText("Import Default Binds")
    self:ApplyThemeToButton(importBtn, true) -- Use the accent color for the button

    importBtn.DoClick = function()
        Derma_Query(
            "Are you sure you want to import your default Garry's Mod binds?\nThis will add to your current profile binds.",
            "Confirm Import",
            "Yes", function()
                self:ImportGModBinds(KEYBIND.Storage.CurrentProfile)
                if IsValid(KEYBIND.Menu.Frame) then
                    KEYBIND.Menu:RefreshKeyboardLayout()
                end
                surface.PlaySound("buttons/button14.wav")
            end,
            "No", function() end
        )
    end

    -- THIS IS THE FIX: Use PerformLayout to correctly size and position the elements.
    -- This function is called by the VGUI system after the panel's final size is known.
    card.PerformLayout = function(self, w, h)
        -- 1. Set the width of the label, leaving 20px margin on each side.
        descLabel:SetWide(w - 40)
        -- 2. Now that the width is set, tell the label to resize its height to fit the wrapped text.
        descLabel:SizeToContents()

        -- 3. Position the button 15 pixels below the bottom of the now correctly-sized label.
        importBtn:SetPos(20, descLabel:GetY() + descLabel:GetTall() + 15)

        -- 4. Finally, set the card's total height to fit all its contents plus 20px of bottom padding.
        self:SetTall(importBtn:GetY() + importBtn:GetTall() + 20)
    end

    return card
end

function KEYBIND.Settings:AddAppearanceSettings(parent)
    local panel = vgui.Create("DPanel", parent)
    panel:Dock(TOP)
    panel:SetHeight(200)
    panel:DockMargin(0, 0, 0, 20)
    
    self:ApplyThemeToPanel(panel, "Appearance Settings")
    
    local theme = self:GetTheme()
    local accentColor = self.Config.accentColor or Color(60, 130, 200)
    
    local accentLabel = vgui.Create("DLabel", panel)
    accentLabel:SetPos(20, 50)
    accentLabel:SetText("Accent Color:")
    accentLabel:SetFont("KeybindSettingsText")
    accentLabel:SetTextColor(theme.text)
    accentLabel:SizeToContents()
    
    local colorPreview = vgui.Create("DPanel", panel)
    colorPreview:SetPos(150, 50)
    colorPreview:SetSize(40, 25)
    colorPreview.Paint = function(self, w, h)
        local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
        draw.RoundedBox(4, 0, 0, w, h, accentColor)
        surface.SetDrawColor(theme.text)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    local colorBtn = vgui.Create("DButton", panel)
    colorBtn:SetPos(200, 50)
    colorBtn:SetSize(120, 25)
    colorBtn:SetText("Change Color")
    colorBtn:SetTextColor(theme.text)
    
    colorBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local baseColor = hovered and theme.buttonHover or theme.buttonDefault
        
        draw.RoundedBox(6, 0, 0, w, h, baseColor)
        
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
    end
    
    colorBtn.DoClick = function()
        local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
        
        local colorPicker = vgui.Create("DColorMixer")
        colorPicker:SetSize(200, 200)
        colorPicker:SetColor(accentColor)
        
        local frame = vgui.Create("DFrame")
        frame:SetSize(220, 250)
        frame:SetTitle("")
        frame:Center()
        frame:MakePopup()
        frame:ShowCloseButton(false)
        
        frame.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, theme.background)
            draw.RoundedBoxEx(8, 0, 0, w, 24, accentColor, true, true, false, false)
            draw.SimpleText("Select Accent Color", "DermaDefault", 10, 12, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        local closeBtn = vgui.Create("DButton", frame)
        closeBtn:SetSize(20, 20)
        closeBtn:SetPos(frame:GetWide() - 25, 2)
        closeBtn:SetText("")
        closeBtn.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            local color = hovered and Color(255, 80, 80, 200) or Color(255, 255, 255, 30)
            draw.RoundedBox(4, 0, 0, w, h, color)
            local padding = 6
            surface.SetDrawColor(255, 255, 255)
            surface.DrawLine(padding, padding, w-padding, h-padding)
            surface.DrawLine(w-padding, padding, padding, h-padding)
        end
        closeBtn.DoClick = function() frame:Remove() end
        
        colorPicker:SetParent(frame)
        colorPicker:Dock(FILL)
        colorPicker:DockMargin(10, 30, 10, 40)
        
        local applyBtn = vgui.Create("DButton", frame)
        applyBtn:SetSize(100, 30)
        applyBtn:SetPos(frame:GetWide()/2 - 50, frame:GetTall() - 35)
        applyBtn:SetText("Apply")
        applyBtn:SetTextColor(Color(255, 255, 255))
        
        applyBtn.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            local color = hovered and Color(accentColor.r + 20, accentColor.g + 20, accentColor.b + 20) or accentColor
            draw.RoundedBox(6, 0, 0, w, h, color)
            
            surface.SetDrawColor(255, 255, 255, 15)
            surface.SetMaterial(Material("gui/gradient_up"))
            surface.DrawTexturedRect(0, 0, w, h)
        end
        
        applyBtn.DoClick = function()
            KEYBIND.Settings.Config.accentColor = colorPicker:GetColor()
            KEYBIND.Settings:SaveSettings()
            
            -- Simply rebuild the menu
            if IsValid(KEYBIND.Menu.Frame) then
                KEYBIND.Menu:RebuildMenu()
            end
            
            -- Recreate the settings window if it's open
            if IsValid(KEYBIND.Settings.Frame) then
                local oldFrame = KEYBIND.Settings.Frame
                KEYBIND.Settings:Create()
                oldFrame:Remove()
            end
            
            frame:Remove()
        end
    end
            
    local presetColors = {
        {name = "Blue", color = Color(60, 130, 200)},
        {name = "Green", color = Color(60, 180, 75)},
        {name = "Red", color = Color(200, 60, 60)},
        {name = "Purple", color = Color(130, 60, 200)},
        {name = "Orange", color = Color(230, 126, 34)}
    }
    
    local presetLabel = vgui.Create("DLabel", panel)
    presetLabel:SetPos(20, 90)
    presetLabel:SetText("Preset Colors:")
    presetLabel:SetFont("KeybindSettingsText")
    presetLabel:SetTextColor(theme.text)
    presetLabel:SizeToContents()
    
    for i, preset in ipairs(presetColors) do
        local presetBtn = vgui.Create("DButton", panel)
        presetBtn:SetSize(25, 25)
        presetBtn:SetPos(150 + (i-1) * 35, 90)
        presetBtn:SetText("")
        
        presetBtn.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, preset.color)
            
            if self:IsHovered() then
                surface.SetDrawColor(255, 255, 255, 100)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
            
            local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
            if ColorEquals(accentColor, preset.color) then
                surface.SetDrawColor(255, 255, 255)
                surface.DrawOutlinedRect(2, 2, w-4, h-4, 2)
            end
        end
        
        presetBtn.DoClick = function()
            KEYBIND.Settings.Config.accentColor = preset.color
            KEYBIND.Settings:SaveSettings()
            
            -- Simply rebuild the menu
            if IsValid(KEYBIND.Menu.Frame) then
                KEYBIND.Menu:RebuildMenu()
            end
            
            -- Recreate the settings window if it's open
            if IsValid(KEYBIND.Settings.Frame) then
                local oldFrame = KEYBIND.Settings.Frame
                KEYBIND.Settings:Create()
                oldFrame:Remove()
            end
        end
        
        presetBtn:SetTooltip(preset.name)
    end
    
    local categoryLabel = vgui.Create("DLabel", panel)
    categoryLabel:SetPos(20, 130)
    categoryLabel:SetText("Highlight Key Category:")
    categoryLabel:SetFont("KeybindSettingsText")
    categoryLabel:SetTextColor(theme.text)
    categoryLabel:SizeToContents()

    local categoryCombo = vgui.Create("DComboBox", panel)
    categoryCombo:SetPos(150, 130)
    categoryCombo:SetSize(200, 25)
    categoryCombo:SetValue("None")
    categoryCombo:SetTextColor(theme.text)

    categoryCombo:AddChoice("None", nil)

    for id, category in pairs(KEYBIND.KeyCategories or {}) do
        categoryCombo:AddChoice(category.name, id)
        
        if KEYBIND.Settings.Config.highlightCategory == id then
            categoryCombo:SetValue(category.name)
        end
    end

    categoryCombo.OnSelect = function(_, _, name, value)
        KEYBIND.Settings.Config.highlightCategory = value
        KEYBIND.Settings:SaveSettings()
        
        if IsValid(KEYBIND.Menu.Frame) then
            KEYBIND.Menu:RefreshKeyboardLayout()
        end
    end
    
    return panel
end

function ColorEquals(c1, c2)
    if not c1 or not c2 then return false end
    return c1.r == c2.r and c1.g == c2.g and c1.b == c2.b and (c1.a or 255) == (c2.a or 255)
end

function KEYBIND.Settings:AddProfileSettings(parent)
    local panel = vgui.Create("DPanel", parent)
    panel:Dock(TOP)
    panel:SetHeight(100)
    panel:DockMargin(0, 0, 0, 20)
    
    self:ApplyThemeToPanel(panel, "Profile Settings")
    
    local theme = self:GetTheme()
    local accentColor = self.Config.accentColor or Color(60, 130, 200)
    
    local profileLabel = vgui.Create("DLabel", panel)
    profileLabel:SetPos(20, 50)
    profileLabel:SetText("Current Profile:")
    profileLabel:SetFont("KeybindSettingsText")
    profileLabel:SetTextColor(theme.text)
    profileLabel:SizeToContents()
    
    local profileSelector = vgui.Create("DComboBox", panel)
    profileSelector:SetPos(150, 50)
    profileSelector:SetSize(200, 30)
    profileSelector:SetValue("Profile " .. (KEYBIND.Storage.CurrentProfile or 1))
    profileSelector:SetTextColor(theme.text)
    
    for i = 1, 3 do
        profileSelector:AddChoice("Profile " .. i, i)
    end
    
    profileSelector.OnSelect = function(_, _, name, value)
        KEYBIND.Storage:SwitchProfile(value)
        
        if IsValid(KEYBIND.Menu.Frame) then
            KEYBIND.Menu:RefreshKeyboardLayout()
        end
        
        if KEYBIND.Settings.Config.showFeedback then
            chat.AddText(Color(0, 255, 0), "[BindMenu] Switched to " .. name)
        end
    end
    
    local resetBtn = vgui.Create("DButton", panel)
    resetBtn:SetPos(360, 50)
    resetBtn:SetSize(120, 30)
    resetBtn:SetText("Reset Profile")
    resetBtn:SetTextColor(Color(255, 255, 255))
    
    resetBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(220, 70, 70) or Color(200, 60, 60)
        draw.RoundedBox(6, 0, 0, w, h, color)
        
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
    end
    
    resetBtn.DoClick = function()
        Derma_Query(
            "Are you sure you want to reset the current profile?\nThis cannot be undone!",
            "Confirm Reset",
            "Yes", function() 
                KEYBIND.Storage:ResetCurrentProfile()
                
                if IsValid(KEYBIND.Menu.Frame) then
                    KEYBIND.Menu:RefreshKeyboardLayout()
                end
                
                if KEYBIND.Settings.Config.showFeedback then
                    chat.AddText(Color(255, 80, 80), "[BindMenu] Reset profile " .. KEYBIND.Storage.CurrentProfile)
                end
            end,
            "No", function() end
        )
    end
    
    return panel
end

function KEYBIND.Settings:AddProfileCard(parent, profileName, accentColor)
    local storedProfile = KEYBIND.Storage.Profiles[profileName]
    if not storedProfile then return end
    
    local displayName = storedProfile.displayName or profileName
    local isCurrentProfile = KEYBIND.Storage.CurrentProfile == profileName
    
    local panel = vgui.Create("DPanel", parent)
    panel:Dock(TOP)
    panel:SetHeight(170)
    panel:DockMargin(0, 0, 0, 20)
    
    panel.Paint = function(self, w, h)
        draw.RoundedBox(8, 2, 2, w-4, h-4, Color(0, 0, 0, 50))
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 40))
        
        local headerColor = isCurrentProfile and accentColor or Color(45, 45, 50)
        draw.RoundedBoxEx(8, 0, 0, w, 36, headerColor, true, true, false, false)
        
        draw.SimpleText(displayName, "KeybindSettingsHeader", 15, 18, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(displayName, "KeybindSettingsHeader", 14, 17, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        if isCurrentProfile then
            draw.SimpleText("ACTIVE", "KeybindSettingsButton", w - 15, 18, Color(0, 0, 0, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            draw.SimpleText("ACTIVE", "KeybindSettingsButton", w - 16, 17, Color(230, 230, 230), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
        
        local iconName = storedProfile.icon or profileName
        local iconMat = KEYBIND.Menu.ProfileIcons[iconName]
        
        if iconMat then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(iconMat)
            surface.DrawTexturedRect(w - 50, 8, 20, 20)
        end
        
        local bindCount = 0
        if storedProfile.binds then
            bindCount = table.Count(storedProfile.binds)
        end
        draw.SimpleText(bindCount .. " active binds", "DermaDefault", 15, h - 15, Color(180, 180, 180), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    local buttonPanel = vgui.Create("DPanel", panel)
    buttonPanel:SetPos(10, 45)
    buttonPanel:SetSize(panel:GetWide() - 20, 115)
    buttonPanel:SetPaintBackground(false)
    
    local renameBtn = vgui.Create("DButton", buttonPanel)
    renameBtn:SetSize(buttonPanel:GetWide() / 3 - 7, 36)
    renameBtn:SetPos(0, 10)
    renameBtn:SetText("")
    
    renameBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(70, 150, 220) or Color(60, 130, 200)
        
        draw.RoundedBox(6, 0, 0, w, h, color)
        
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        
        draw.SimpleText("Rename Profile", "KeybindSettingsButton", w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Rename Profile", "KeybindSettingsButton", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    renameBtn.DoClick = function()
        self:OpenRenameDialog(profileName, displayName)
    end
    
    local resetBtn = vgui.Create("DButton", buttonPanel)
    resetBtn:SetSize(buttonPanel:GetWide() / 3 - 7, 36)
    resetBtn:SetPos(buttonPanel:GetWide() / 3 + 3, 10)
    resetBtn:SetText("")
    
    resetBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(220, 70, 70) or Color(200, 60, 60)
        
        draw.RoundedBox(6, 0, 0, w, h, color)
        
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        
        draw.SimpleText("Reset Binds", "KeybindSettingsButton", w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Reset Binds", "KeybindSettingsButton", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    resetBtn.DoClick = function()
        Derma_Query(
            "Are you sure you want to reset all binds for " .. displayName .. "?",
            "Confirm Reset",
            "Yes", function() self:ResetProfile(profileName) end,
            "No", function() end
        )
    end
    
    local iconBtn = vgui.Create("DButton", buttonPanel)
    iconBtn:SetSize(buttonPanel:GetWide() / 3 - 7, 36)
    iconBtn:SetPos(2 * (buttonPanel:GetWide() / 3) + 6, 10)
    iconBtn:SetText("")
    
    iconBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(70, 150, 70) or Color(60, 130, 60)
        
        draw.RoundedBox(6, 0, 0, w, h, color)
        
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        
        draw.SimpleText("Choose Icon", "KeybindSettingsButton", w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Choose Icon", "KeybindSettingsButton", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    iconBtn.DoClick = function()
        self:OpenIconSelector(profileName, displayName)
    end
    
    local importGModBtn = vgui.Create("DButton", buttonPanel)
    importGModBtn:SetSize(buttonPanel:GetWide() - 14, 36)
    importGModBtn:SetPos(7, 56)
    importGModBtn:SetText("")
    
    importGModBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(100, 150, 70) or Color(80, 130, 50)
        
        draw.RoundedBox(6, 0, 0, w, h, color)
        
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        
        draw.SimpleText("Import Garry's Mod Binds", "KeybindSettingsButton", w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Import Garry's Mod Binds", "KeybindSettingsButton", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    importGModBtn.DoClick = function()
        Derma_Query(
            "This will import your standard Garry's Mod binds into this profile.\n" ..
            "Existing binds with the same keys will not be overwritten.\n\n" ..
            "Do you want to continue?",
            "Import Garry's Mod Binds",
            "Yes", function()
                local success, imported, conflicts, skipped = self:ImportGModBinds(profileName)
                
                if success then
                    local notification = vgui.Create("DFrame")
                    notification:SetSize(300, 180)
                    notification:Center()
                    notification:SetTitle("")
                    notification:MakePopup()
                    notification:ShowCloseButton(false)
                    
                    notification.Paint = function(self, w, h)
                        draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 45, 245))
                        draw.RoundedBoxEx(8, 0, 0, w, 30, Color(80, 130, 50), true, true, false, false)
                        draw.SimpleText("Import Results", "KeybindSettingsButton", 15, 15, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end
                    
                    local closeBtn = vgui.Create("DButton", notification)
                    closeBtn:SetSize(24, 24)
                    closeBtn:SetPos(notification:GetWide() - 30, 3)
                    closeBtn:SetText("")
                    closeBtn.Paint = function(self, w, h)
                        local hovered = self:IsHovered()
                        draw.RoundedBox(4, 0, 0, w, h, hovered and Color(255, 80, 80, 200) or Color(255, 255, 255, 30))
                        draw.SimpleText("✕", "DermaDefault", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                    closeBtn.DoClick = function() notification:Remove() end
                    
                    local resultsPanel = vgui.Create("DPanel", notification)
                    resultsPanel:SetPos(10, 40)
                    resultsPanel:SetSize(notification:GetWide() - 20, notification:GetTall() - 90)
                    resultsPanel.Paint = function(self, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 35))
                        
                        draw.SimpleText("Successfully imported: " .. imported .. " binds", "DermaDefault", 10, 20, Color(100, 255, 100))
                        draw.SimpleText("Skipped due to conflicts: " .. conflicts .. " binds", "DermaDefault", 10, 40, Color(255, 200, 100))
                        draw.SimpleText("Skipped incompatible keys: " .. skipped .. " binds", "DermaDefault", 10, 60, Color(255, 200, 100))
                        draw.SimpleText("Total processed: " .. (imported + conflicts + skipped) .. " binds", "DermaDefault", 10, 80, Color(200, 200, 255))
                    end
                    
                    local okBtn = vgui.Create("DButton", notification)
                    okBtn:SetSize(100, 30)
                    okBtn:SetPos(notification:GetWide()/2 - 50, notification:GetTall() - 40)
                    okBtn:SetText("OK")
                    okBtn.DoClick = function() 
                        notification:Remove() 
                        self:Create()
                    end
                end
            end,
            "No", function() end
        )
    end
    
    panel.PerformLayout = function(self, w, h)
        buttonPanel:SetSize(w - 20, 115)
        
        renameBtn:SetSize(buttonPanel:GetWide() / 3 - 7, 36)
        renameBtn:SetPos(0, 10)
        
        resetBtn:SetSize(buttonPanel:GetWide() / 3 - 7, 36)
        resetBtn:SetPos(buttonPanel:GetWide() / 3 + 3, 10)
        
        iconBtn:SetSize(buttonPanel:GetWide() / 3 - 7, 36)
        iconBtn:SetPos(2 * (buttonPanel:GetWide() / 3) + 6, 10)
        
        importGModBtn:SetSize(buttonPanel:GetWide() - 14, 36)
        importGModBtn:SetPos(7, 56)
    end
    
    return panel
end

function KEYBIND.Settings:OpenRenameDialog(profileName, currentName)
    local theme = self:GetTheme()
    local accentColor = self.Config.accentColor or Color(60, 130, 200)
    
    local dialog = vgui.Create("DFrame")
    dialog:SetSize(400, 200)
    dialog:Center()
    dialog:SetTitle("")
    dialog:MakePopup()
    dialog:ShowCloseButton(false)
    dialog:SetDraggable(true)
    
    dialog.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0)
        draw.RoundedBox(10, 0, 0, w, h, theme.dialogBackground)
        draw.RoundedBoxEx(10, 0, 0, w, 40, accentColor, true, true, false, false)
        draw.SimpleText("Rename Profile", "KeybindSettingsHeader", 15, 20, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    local closeBtn = vgui.Create("DButton", dialog)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(dialog:GetWide() - 40, 5)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(255, 80, 80, 200) or Color(255, 255, 255, 30)
        draw.RoundedBox(8, 0, 0, w, h, color)
        local padding = 10
        surface.SetDrawColor(255, 255, 255)
        surface.DrawLine(padding, padding, w-padding, h-padding)
        surface.DrawLine(w-padding, padding, padding, h-padding)
    end
    closeBtn.DoClick = function() dialog:Remove() end
    
    local nameLabel = vgui.Create("DLabel", dialog)
    nameLabel:SetPos(20, 60)
    nameLabel:SetText("New Profile Name:")
    nameLabel:SetFont("KeybindSettingsText")
    nameLabel:SetTextColor(theme.text)
    nameLabel:SizeToContents()
    
    local nameEntry = vgui.Create("DTextEntry", dialog)
    nameEntry:SetPos(20, 85)
    nameEntry:SetSize(dialog:GetWide() - 40, 30)
    nameEntry:SetFont("KeybindSettingsText")
    nameEntry:SetValue(currentName)
    nameEntry:SelectAllText()
    
    local saveBtn = vgui.Create("DButton", dialog)
    saveBtn:SetPos(20, dialog:GetTall() - 60)
    saveBtn:SetSize(dialog:GetWide() - 40, 40)
    saveBtn:SetText("Save Changes")
    saveBtn:SetFont("KeybindSettingsButton")
    saveBtn:SetTextColor(Color(255, 255, 255))
    
    saveBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(accentColor.r + 20, accentColor.g + 20, accentColor.b + 20) or accentColor
        draw.RoundedBox(8, 0, 0, w, h, color)
    end
    
    saveBtn.DoClick = function()
        local newName = nameEntry:GetValue()
        
        if newName == "" then
            Derma_Message("Please enter a profile name.", "Error", "OK")
            return
        end
        
        if KEYBIND.Storage.Profiles[profileName] then
            KEYBIND.Storage.Profiles[profileName].displayName = newName
            KEYBIND.Storage:SaveBinds()
            
            if KEYBIND.Settings.Config.showFeedback then
                chat.AddText(Color(0, 255, 0), "[BindMenu] Renamed profile to: " .. newName)
            end
            
            self:RefreshProfilesTab()
        end
        
        dialog:Remove()
        
        surface.PlaySound("buttons/button14.wav")
    end
    
    nameEntry:RequestFocus()
end

function KEYBIND.Settings:DeleteAllProfiles()
    local theme = self:GetTheme()
    local accentColor = self.Config.accentColor or Color(60, 130, 200)
    
    local dialog = vgui.Create("DFrame")
    dialog:SetSize(400, 200)
    dialog:Center()
    dialog:SetTitle("")
    dialog:MakePopup()
    dialog:ShowCloseButton(false)
    dialog:SetDraggable(true)
    
    dialog.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0)
        draw.RoundedBox(10, 0, 0, w, h, theme.dialogBackground)
        draw.RoundedBoxEx(10, 0, 0, w, 40, Color(200, 60, 60), true, true, false, false)
        draw.SimpleText("Reset All Profiles", "KeybindSettingsHeader", 15, 20, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local closeBtn = vgui.Create("DButton", dialog)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(dialog:GetWide() - 40, 5)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(255, 80, 80, 200) or Color(255, 255, 255, 30)
        draw.RoundedBox(8, 0, 0, w, h, color)
        local padding = 10
        surface.SetDrawColor(255, 255, 255)
        surface.DrawLine(padding, padding, w-padding, h-padding)
        surface.DrawLine(w-padding, padding, padding, h-padding)
    end
    closeBtn.DoClick = function() dialog:Remove() end
    
    local warningLabel = vgui.Create("DLabel", dialog)
    warningLabel:SetPos(20, 60)
    warningLabel:SetSize(dialog:GetWide() - 40, 60)
    warningLabel:SetText("WARNING: This will delete ALL your profiles and create a new default profile. This action cannot be undone!")
    warningLabel:SetFont("KeybindSettingsText")
    warningLabel:SetTextColor(Color(255, 80, 80))
    warningLabel:SetWrap(true)
    
    local cancelBtn = vgui.Create("DButton", dialog)
    cancelBtn:SetPos(20, dialog:GetTall() - 60)
    cancelBtn:SetSize((dialog:GetWide() - 50) / 2, 40)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetFont("KeybindSettingsButton")
    cancelBtn:SetTextColor(Color(255, 255, 255))
    
    cancelBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(70, 70, 75) or Color(60, 60, 65)
        draw.RoundedBox(8, 0, 0, w, h, color)
    end
    
    cancelBtn.DoClick = function()
        dialog:Remove()
    end
    
    local confirmBtn = vgui.Create("DButton", dialog)
    confirmBtn:SetPos(30 + (dialog:GetWide() - 50) / 2, dialog:GetTall() - 60)
    confirmBtn:SetSize((dialog:GetWide() - 50) / 2, 40)
    confirmBtn:SetText("Reset All Profiles")
    confirmBtn:SetFont("KeybindSettingsButton")
    confirmBtn:SetTextColor(Color(255, 255, 255))
    
    confirmBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(220, 60, 60) or Color(200, 50, 50)
        draw.RoundedBox(8, 0, 0, w, h, color)
    end
    
    confirmBtn.DoClick = function()
        KEYBIND.Storage.Profiles = {}
        local defaultProfile = KEYBIND.Storage:InitializeDefaultProfiles()
        
        if KEYBIND.Settings.Config.showFeedback then
            chat.AddText(Color(255, 80, 80), "[BindMenu] All profiles have been reset")
        end
        
        if IsValid(KEYBIND.Menu.Frame) then
            KEYBIND.Menu:RefreshProfilesTab()
            KEYBIND.Menu:RefreshKeyboardLayout()
        end
        
        dialog:Remove()
        
        surface.PlaySound("buttons/button14.wav")
    end
end

function KEYBIND.Settings:OpenIconSelector(profileName, displayName)
    local theme = self:GetTheme()
    local accentColor = self.Config.accentColor or Color(60, 130, 200)

    local dialog = vgui.Create("DFrame")
    dialog:SetSize(400, 350)
    dialog:Center()
    dialog:SetTitle("")
    dialog:MakePopup()
    dialog:ShowCloseButton(false)
    dialog:SetDraggable(true)

    dialog.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0)
        draw.RoundedBox(10, 0, 0, w, h, theme.dialogBackground)
        draw.RoundedBoxEx(10, 0, 0, w, 40, accentColor, true, true, false, false)
        draw.SimpleText("Choose Icon for: " .. displayName, "KeybindSettingsHeader", 15, 20, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local closeBtn = vgui.Create("DButton", dialog)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(dialog:GetWide() - 40, 5)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(255, 80, 80, 200) or Color(255, 255, 255, 30)
        draw.RoundedBox(8, 0, 0, w, h, color)
        local padding = 10
        surface.SetDrawColor(255, 255, 255)
        surface.DrawLine(padding, padding, w-padding, h-padding)
        surface.DrawLine(w-padding, padding, padding, h-padding)
    end
    closeBtn.DoClick = function() dialog:Remove() end

    local scroll = vgui.Create("DScrollPanel", dialog)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 50, 10, 10)

    local scrollbar = scroll:GetVBar()
    scrollbar:SetWide(6)
    scrollbar.Paint = function() end
    scrollbar.btnUp.Paint = function() end
    scrollbar.btnDown.Paint = function() end
    scrollbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(255, 255, 255, 40))
    end

    local iconLayout = vgui.Create("DIconLayout", scroll)
    iconLayout:Dock(FILL)
    iconLayout:SetSpaceX(10)
    iconLayout:SetSpaceY(10)

    local storedProfile = KEYBIND.Storage.Profiles[profileName]
    local currentIcon = storedProfile.icon or profileName

    local availableIcons = {
        {name = "alyx", displayName = "Alyx", category = "*"},
        {name = "mayor", displayName = "Mr Mayor", category = "*"},
        {name = "gman", displayName = "GMAN", category = "*"},
        {name = "gundealer", displayName = "Gun Dealer", category = "*"},
        {name = "kleiner", displayName = "Kleiner", category = "*"},
        {name = "pfp1", displayName = "Mug Shot 1", category = "*"},
        {name = "pfp2", displayName = "Mug Shot 2", category = "*"},
        {name = "pfp3", displayName = "Mug Shot 3", category = "*"}
    }

    for _, iconData in ipairs(availableIcons) do
        local iconBtn = iconLayout:Add("DButton")
        iconBtn:SetSize(64, 64)
        iconBtn:SetText("")
        iconBtn:SetTooltip(iconData.displayName)

        local iconMat = KEYBIND.Menu.ProfileIcons[iconData.name]
        local isSelected = (currentIcon == iconData.name)

        iconBtn.Paint = function(self, w, h)
            local isHovered = self:IsHovered()
            
            local bgColor = theme.cardHeader
            if isSelected then
                bgColor = accentColor
            elseif isHovered then
                bgColor = theme.buttonHover
            end
            draw.RoundedBox(8, 0, 0, w, h, bgColor)

            if iconMat and not iconMat:IsError() then
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(iconMat)
                surface.DrawTexturedRect(w/2 - 24, h/2 - 24, 48, 48)
            else
                draw.SimpleText("?", "KeybindMenuTitle", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            if isSelected then
                surface.SetDrawColor(255, 255, 255, 200)
                surface.DrawOutlinedRect(2, 2, w-4, h-4, 2)
            elseif isHovered then
                surface.SetDrawColor(255, 255, 255, 100)
                surface.DrawOutlinedRect(1, 1, w-2, h-2, 1)
            end
        end

        iconBtn.DoClick = function()
            storedProfile.icon = iconData.name
            KEYBIND.Storage:SaveBinds()
            
            surface.PlaySound("buttons/button14.wav")
            
            if KEYBIND.Settings.Config.showFeedback then
                chat.AddText(Color(0, 255, 0), "[BindMenu] Profile icon updated for '", Color(255, 255, 255), displayName, Color(0, 255, 0), "'")
            end
            
            dialog:Remove()
            if IsValid(KEYBIND.Menu.Frame) then
                KEYBIND.Menu:RefreshProfilesTab()
            end
        end
    end
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
        
        timer.Simple(0.1, function()
            if IsValid(self.Frame) then
                self:Create()
            end
        end)
    end
end

function KEYBIND.Settings:AddPerformanceMonitor(parent)
    if GetConVar("developer"):GetInt() == 0 then return end
    
    local panel = vgui.Create("DPanel", parent)
    panel:Dock(TOP)
    panel:SetHeight(200)
    panel:DockMargin(0, 0, 0, 20)
    
    panel.Paint = function(self, w, h)
        draw.RoundedBox(8, 2, 2, w-4, h-4, Color(0, 0, 0, 50))
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 40))
        
        draw.RoundedBoxEx(8, 0, 0, w, 36, Color(45, 45, 50), true, true, false, false)
        
        draw.SimpleText("Performance Monitor", "KeybindSettingsHeader", 15, 18, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Performance Monitor", "KeybindSettingsHeader", 14, 17, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    local monitorCheck = vgui.Create("DCheckBoxLabel", panel)
    monitorCheck:SetPos(20, 50)
    monitorCheck:SetText("Enable Performance Monitoring")
    monitorCheck:SetTextColor(Color(210, 210, 210))
    monitorCheck:SetFont("KeybindSettingsText")
    monitorCheck:SizeToContents()
    monitorCheck:SetValue(self.Config.enableMonitoring or false)
    
    monitorCheck.OnChange = function(self, val)
        KEYBIND.Settings.Config.enableMonitoring = val
        KEYBIND.Settings:SaveSettings()
        
        if val then
            KEYBIND.PerformanceMonitor = KEYBIND.PerformanceMonitor or {}
            KEYBIND.PerformanceMonitor.StartTime = SysTime()
            KEYBIND.PerformanceMonitor.Samples = {}
            KEYBIND.PerformanceMonitor.LastSample = SysTime()
            KEYBIND.PerformanceMonitor.FrameTimes = {}
            
            hook.Add("Think", "KEYBIND_PerformanceMonitor", function()
                local currentTime = SysTime()
                local frameTime = currentTime - KEYBIND.PerformanceMonitor.LastSample
                
                table.insert(KEYBIND.PerformanceMonitor.FrameTimes, frameTime)
                if #KEYBIND.PerformanceMonitor.FrameTimes > 100 then
                    table.remove(KEYBIND.PerformanceMonitor.FrameTimes, 1)
                end
                
                if currentTime - KEYBIND.PerformanceMonitor.LastSample >= 1 then
                    local sum = 0
                    for _, time in ipairs(KEYBIND.PerformanceMonitor.FrameTimes) do
                        sum = sum + time
                    end
                    local avgFrameTime = sum / #KEYBIND.PerformanceMonitor.FrameTimes
                    
                    table.insert(KEYBIND.PerformanceMonitor.Samples, {
                        time = currentTime - KEYBIND.PerformanceMonitor.StartTime,
                        fps = 1 / avgFrameTime,
                        frameTime = avgFrameTime * 1000
                    })
                    
                    if #KEYBIND.PerformanceMonitor.Samples > 60 then
                        table.remove(KEYBIND.PerformanceMonitor.Samples, 1)
                    end
                    
                    KEYBIND.PerformanceMonitor.LastSample = currentTime
                end
            end)
        else
            hook.Remove("Think", "KEYBIND_PerformanceMonitor")
        end
    end
    
    monitorCheck.Button.Paint = function(self, w, h)
        local checked = self:GetChecked()
        local hovered = self:IsHovered()
        
        local bgColor = checked and Color(60, 130, 200) or Color(45, 45, 50)
        if hovered then
            bgColor = Color(bgColor.r + 20, bgColor.g + 20, bgColor.b + 20)
        end
        
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        
        if checked then
            surface.SetDrawColor(255, 255, 255)
            surface.DrawLine(3, h/2, w/2-1, h-3)
            surface.DrawLine(w/2-1, h-3, w-3, 3)
        end
    end
    
    local graph = vgui.Create("DPanel", panel)
    graph:SetPos(20, 80)
    graph:SetSize(panel:GetWide() - 40, 100)
    
    graph.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(25, 25, 30))
        
        surface.SetDrawColor(50, 50, 55, 100)
        for i = 1, 4 do
            local y = h * (i / 5)
            surface.DrawLine(0, y, w, y)
        end
        
        for i = 1, 9 do
            local x = w * (i / 10)
            surface.DrawLine(x, 0, x, h)
        end
        
        if KEYBIND.Settings.Config.enableMonitoring and KEYBIND.PerformanceMonitor and KEYBIND.PerformanceMonitor.Samples then
            local samples = KEYBIND.PerformanceMonitor.Samples
            if #samples > 1 then
                local minFPS = math.huge
                local maxFPS = 0
                for _, sample in ipairs(samples) do
                    minFPS = math.min(minFPS, sample.fps)
                    maxFPS = math.max(maxFPS, sample.fps)
                end
                
                minFPS = math.max(1, math.floor(minFPS * 0.9))
                maxFPS = math.ceil(maxFPS * 1.1)
                local range = maxFPS - minFPS
                
                surface.SetDrawColor(60, 200, 120, 200)
                for i = 2, #samples do
                    local prev = samples[i-1]
                    local curr = samples[i]
                    
                    local x1 = w * ((i-2) / (#samples - 1))
                    local y1 = h - (h * ((prev.fps - minFPS) / range))
                    local x2 = w * ((i-1) / (#samples - 1))
                    local y2 = h - (h * ((curr.fps - minFPS) / range))
                    
                    surface.DrawLine(x1, y1, x2, y2)
                end
                
                local currentFPS = samples[#samples].fps
                draw.SimpleText(string.format("%.1f FPS", currentFPS), "KeybindSettingsText", w - 10, 10, Color(60, 200, 120), TEXT_ALIGN_RIGHT)
                
                local frameTime = samples[#samples].frameTime
                draw.SimpleText(string.format("%.2f ms", frameTime), "KeybindSettingsText", w - 10, 30, Color(200, 200, 60), TEXT_ALIGN_RIGHT)
            end
        else
            draw.SimpleText("Enable monitoring to see performance data", "KeybindSettingsText", w/2, h/2, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    timer.Create("KEYBIND_UpdatePerformanceGraph", 0.5, 0, function()
        if IsValid(graph) then
            graph:InvalidateLayout(true)
        else
            timer.Remove("KEYBIND_UpdatePerformanceGraph")
        end
    end)
    
    return panel
end

concommand.Add("bindmenu_settings", function()
    KEYBIND.Settings:Create()
end)

hook.Add("Initialize", "KEYBIND_Settings_Init", function()
    KEYBIND.Settings:LoadSettings()
    
    if not KEYBIND.Settings.Config.accentColor or type(KEYBIND.Settings.Config.accentColor) ~= "table" or not KEYBIND.Settings.Config.accentColor.r then
        KEYBIND.Settings.Config.accentColor = Color(60, 130, 200)
    end
end)
