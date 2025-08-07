KEYBIND = KEYBIND or {}
KEYBIND.Menu = KEYBIND.Menu or {}
KEYBIND.Menu.lastHoverSoundTime = 0

surface.CreateFont("KeybindKeyFont", {
    font = "Roboto",
    size = 18,
    weight = 600,
    antialias = true
})

surface.CreateFont("KeybindMenuTitle", {
    font = "Roboto",
    size = 24,
    weight = 700,
    antialias = true
})

surface.CreateFont("KeybindDropdownTitle", {
    font = "Roboto",
    size = 16,
    weight = 700,
    antialias = true
})

surface.CreateFont("KeybindDropdownText", {
    font = "Roboto",
    size = 16,
    weight = 600,
    antialias = true
})

surface.CreateFont("KeybindDropdownSubtext", {
    font = "Roboto",
    size = 14,
    weight = 400,
    antialias = true
})

surface.CreateFont("BindDialogFont", {
    font = "Roboto",
    size = 16,
    weight = 500,
    antialias = true,
    shadow = false
})

KEYBIND.Renderer = KEYBIND.Renderer or {}
KEYBIND.Renderer.KeyButtons = {}
KEYBIND.Renderer.SectionPanels = {}
KEYBIND.Renderer.CurrentLayout = "StandardKeyboard"
KEYBIND.Renderer.Scale = 1.0

KEYBIND.Menu.ProfileIcons = {
    pfp1 = Material("materials/bindmenu/pfp1.png", "smooth"),
    pfp2 = Material("materials/bindmenu/pfp2.png", "smooth"),
    pfp3 = Material("materials/bindmenu/pfp3.png", "smooth"),
    alyx = Material("materials/bindmenu/alyx.png", "smooth"),
    mayor = Material("materials/bindmenu/mayor.png", "smooth"),
    gman = Material("materials/bindmenu/gman.png", "smooth"),
    gundealer = Material("materials/bindmenu/gundealer.png", "smooth"),
    kleiner = Material("materials/bindmenu/kleiner.png", "smooth")
}

local originalRoundedBox = draw.RoundedBox
draw.RoundedBox = function(borderRadius, x, y, w, h, color, ...)
    if color == nil then
        color = Color(255, 0, 255) -- Magenta to make it obvious
        print("[BindMenu] Warning: Nil color in draw.RoundedBox at line " .. debug.getinfo(2).currentline)
    end
    return originalRoundedBox(borderRadius, x, y, w, h, color, ...)
end

for name, mat in pairs(KEYBIND.Menu.ProfileIcons) do
    if not mat or mat:IsError() then
        print("[BindMenu] Failed to load icon for profile: " .. name)
        KEYBIND.Menu.ProfileIcons[name] = nil
    end
end

KEYBIND.Menu.DefaultIcon = Material("icon16/user.png", "smooth")

local function SafeDrawGradient(material, x, y, w, h, color)
    if not material or material:IsError() then return end
    
    surface.SetDrawColor(color or Color(255, 255, 255, 10))
    surface.SetMaterial(material)
    surface.DrawTexturedRect(x, y, w, h)
end

function KEYBIND.Menu:CreateProfileSelector(parent)
    local selector = vgui.Create("DPanel", parent)
    selector:Dock(FILL)
    selector:SetPaintBackground(false)
    
    local theme = KEYBIND.Settings:GetTheme()
    local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
    
    local titleLabel = vgui.Create("DLabel", selector)
    titleLabel:SetPos(10, 5)
    titleLabel:SetFont("KeybindDropdownTitle")
    titleLabel:SetText("Current Profile")
    titleLabel:SetTextColor(Color(150, 150, 150))
    titleLabel:SizeToContents()
    
    local currentProfile = KEYBIND.Storage.CurrentProfile
    local profileData = KEYBIND.Storage.Profiles[currentProfile]
    
    if not profileData then
        local errorLabel = vgui.Create("DLabel", selector)
        errorLabel:SetPos(10, 30)
        errorLabel:SetText("No profile selected. Please create a profile.")
        errorLabel:SetTextColor(Color(255, 100, 100))
        errorLabel:SizeToContents()
        
        local createBtn = vgui.Create("DButton", selector)
        createBtn:SetPos(10, 50)
        createBtn:SetSize(150, 30)
        createBtn:SetText("Create Profile")
        createBtn:SetTextColor(Color(255, 255, 255))
        
        createBtn.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            local color = hovered and Color(accentColor.r + 20, accentColor.g + 20, accentColor.b + 20) or accentColor
            draw.RoundedBox(6, 0, 0, w, h, color)
        end
        
        createBtn.DoClick = function()
            KEYBIND.Menu:ShowCreateProfileDialog()
        end
        
        return selector
    end
    
    local optionsButtonWidth = 40
    local optionsButtonMargin = 10
    local dropdownMargin = 10
    local dropdownWidth = parent:GetWide() - optionsButtonWidth - optionsButtonMargin - (dropdownMargin * 2)
    
    local dropdownHeight = 50
    local dropdownBtn = vgui.Create("DButton", selector)
    dropdownBtn:SetSize(dropdownWidth, dropdownHeight)
    dropdownBtn:SetPos(dropdownMargin, titleLabel:GetTall() + 5)
    dropdownBtn:SetText("")
    
    selector.dropdownOpen = false
    
    local displayName = profileData.displayName or currentProfile
    local bindCount = table.Count(profileData.binds or {})
    local iconName = profileData.icon or "Profile1"
    
    dropdownBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        
        draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 45))
        
        if hovered then
            draw.RoundedBox(8, 0, 0, w, h, Color(60, 130, 200, 30))
        end
        
        local textX = 15
        
        local icon = KEYBIND.Menu.ProfileIcons[iconName] or KEYBIND.Menu.DefaultIcon
        if icon then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(icon)
            surface.DrawTexturedRect(textX, 8, 32, 32)
            textX = textX + 40
        end
        
        local availableTextWidth = w - textX - 80
        
        surface.SetFont("KeybindDropdownText")
        local textWidth = surface.GetTextSize(displayName)
        
        if textWidth > availableTextWidth then
            local ratio = availableTextWidth / textWidth
            local charCount = math.floor(#displayName * ratio) - 3
            displayName = string.sub(displayName, 1, charCount) .. "..."
        end
        
        draw.SimpleText(displayName, "KeybindDropdownText", textX, 15,
            Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        local bindText = bindCount .. " binds"
        draw.SimpleText(bindText, "KeybindDropdownSubtext", textX, 35,
            Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        local arrowSize = 8
        local arrowX = w - 20
        local arrowY = h / 2
        
        surface.SetDrawColor(230, 230, 230, 200)
        surface.DrawLine(arrowX - arrowSize, arrowY - arrowSize/2, arrowX, arrowY + arrowSize/2)
        surface.DrawLine(arrowX, arrowY + arrowSize/2, arrowX + arrowSize, arrowY - arrowSize/2)
    end
    
    local function CreateDropdownPanel()
        if IsValid(selector.dropdownPanel) then
            selector.dropdownPanel:Remove()
        end
        
        local x, y = dropdownBtn:LocalToScreen(0, dropdownHeight)
        
        local dropdownPanel = vgui.Create("DPanel")
        dropdownPanel:SetSize(dropdownBtn:GetWide(), 300)
        dropdownPanel:SetPos(x, y)
        dropdownPanel:MakePopup()
        dropdownPanel:SetKeyboardInputEnabled(false)
        dropdownPanel:SetZPos(32767)
        
        selector.dropdownPanel = dropdownPanel
        
        local scroll = vgui.Create("DScrollPanel", dropdownPanel)
        scroll:Dock(FILL)
        
        local scrollbar = scroll:GetVBar()
        scrollbar:SetWide(6)
        scrollbar.Paint = function(self, w, h) end
        scrollbar.btnUp.Paint = function(self, w, h) end
        scrollbar.btnDown.Paint = function(self, w, h) end
        scrollbar.btnGrip.Paint = function(self, w, h)
            draw.RoundedBox(3, 0, 0, w, h, Color(255, 255, 255, 40))
        end
        
        local profiles = {}
        for profileName, profileData in pairs(KEYBIND.Storage.Profiles) do
            table.insert(profiles, {
                name = profileName,
                displayName = profileData.displayName or profileName,
                icon = profileData.icon or "Profile1",
                binds = profileData.binds or {}
            })
        end
        
        table.sort(profiles, function(a, b)
            return a.displayName < b.displayName
        end)
        
        local itemHeight = 50
        local totalHeight = 0
        
        for _, profile in ipairs(profiles) do
            local item = vgui.Create("DButton", scroll)
            item:SetSize(scroll:GetWide(), itemHeight)
            item:SetPos(0, totalHeight)
            item:SetText("")
            
            local isActive = profile.name == KEYBIND.Storage.CurrentProfile
            local bindCount = table.Count(profile.binds or {})
            
            item.Paint = function(self, w, h)
                local hovered = self:IsHovered()
                
                if hovered then
                    draw.RoundedBox(0, 0, 0, w, h, Color(60, 130, 200, 50))
                end
                
                if isActive then
                    draw.RoundedBox(0, 0, 0, 4, h, accentColor)
                end
                
                local icon = KEYBIND.Menu.ProfileIcons[profile.icon] or KEYBIND.Menu.DefaultIcon
                if icon then
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(icon)
                    surface.DrawTexturedRect(15, 8, 32, 32)
                end
                
                local textX = 55
                local availableTextWidth = w - textX - 80
                
                local displayName = profile.displayName
                surface.SetFont("KeybindDropdownText")
                local textWidth = surface.GetTextSize(displayName)
                
                if textWidth > availableTextWidth then
                    local ratio = availableTextWidth / textWidth
                    local charCount = math.floor(#displayName * ratio) - 3
                    displayName = string.sub(displayName, 1, charCount) .. "..."
                end
                
                draw.SimpleText(displayName, "KeybindDropdownText", textX, 15,
                    Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                local bindText = bindCount .. " binds"
                draw.SimpleText(bindText, "KeybindDropdownSubtext", textX, 35,
                    Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                if totalHeight + itemHeight < scroll:GetTall() then
                    surface.SetDrawColor(60, 60, 65)
                    surface.DrawLine(0, h-1, w, h-1)
                end
            end
            
            item.DoClick = function()
                if profile.name ~= KEYBIND.Storage.CurrentProfile then
                    KEYBIND.Storage.CurrentProfile = profile.name
                    KEYBIND.Storage:SaveBinds()
                    
                    KEYBIND.Menu:RefreshKeyboardLayout()
                    
                    if KEYBIND.Settings.Config.showFeedback then
                        chat.AddText(Color(0, 255, 0), "[BindMenu] Switched to profile: " .. profile.displayName)
                    end
                    
                    surface.PlaySound("buttons/button14.wav")
                end
                
                selector.dropdownOpen = false
                dropdownPanel:Remove()
            end
            
            totalHeight = totalHeight + itemHeight
        end
        
        local createBtn = vgui.Create("DButton", scroll)
        createBtn:SetSize(scroll:GetWide(), itemHeight)
        createBtn:SetPos(0, totalHeight)
        createBtn:SetText("")
        
        createBtn.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            
            local bgColor = hovered and Color(60, 130, 200, 50) or Color(40, 40, 45)
            draw.RoundedBox(0, 0, 0, w, h, bgColor)
            
            draw.SimpleText("+", "KeybindMenuTitle", 30, h/2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            draw.SimpleText("Create New Profile", "KeybindDropdownText", 55, h/2, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        createBtn.DoClick = function()
            selector.dropdownOpen = false
            dropdownPanel:Remove()
            
            KEYBIND.Menu:ShowCreateProfileDialog()
        end
        
        totalHeight = totalHeight + itemHeight
        
        local maxHeight = 300
        local contentHeight = math.min(totalHeight, maxHeight)
        dropdownPanel:SetTall(contentHeight)
        
        dropdownPanel.Think = function(self)
            if not self:IsHovered() and input.IsMouseDown(MOUSE_LEFT) then
                selector.dropdownOpen = false
                self:Remove()
            end
        end
    end
    
    dropdownBtn.DoClick = function()
        selector.dropdownOpen = not selector.dropdownOpen
        
        if selector.dropdownOpen then
            CreateDropdownPanel()
            surface.PlaySound("buttons/button14.wav")
        else
            if IsValid(selector.dropdownPanel) then
                selector.dropdownPanel:Remove()
            end
        end
    end
    
    local optionsBtn = vgui.Create("DButton", selector)
    optionsBtn:SetSize(optionsButtonWidth, 40)
    optionsBtn:SetPos(parent:GetWide() - optionsButtonWidth - optionsButtonMargin, titleLabel:GetTall() + 10)
    optionsBtn:SetText("")
    optionsBtn:SetTooltip("Profile Options")
    
    optionsBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(60, 130, 200, 200) or Color(50, 50, 55)
        
        draw.RoundedBox(8, 0, 0, w, h, color)
        
        local dotSize = 4
        local spacing = 8
        local startX = w/2 - spacing
        local y = h/2
        
        for i = 0, 2 do
            draw.RoundedBox(dotSize, startX + i * spacing, y - dotSize/2, dotSize, dotSize, Color(230, 230, 230))
        end
    end
    
    optionsBtn.DoClick = function()
        if selector.dropdownOpen and IsValid(selector.dropdownPanel) then
            selector.dropdownOpen = false
            selector.dropdownPanel:Remove()
        end
        
        local menu = DermaMenu()
        
        menu:AddOption("Rename Profile", function()
            KEYBIND.Menu:ShowRenameProfileDialog(currentProfile, displayName)
        end)
        
        menu:AddOption("Change Icon", function()
            if KEYBIND.Settings and KEYBIND.Settings.OpenIconSelector then
                KEYBIND.Settings:OpenIconSelector(currentProfile, displayName)
            end
        end)
        
        menu:AddOption("Reset Binds", function()
            Derma_Query(
                "Are you sure you want to reset all binds for " .. displayName .. "?",
                "Confirm Reset",
                "Yes", function()
                    if KEYBIND.Storage.Profiles[currentProfile] then
                        KEYBIND.Storage.Profiles[currentProfile].binds = {}
                        KEYBIND.Storage:SaveBinds()
                        
                        KEYBIND.Menu:RefreshKeyboardLayout()
                        
                        if KEYBIND.Settings.Config.showFeedback then
                            chat.AddText(Color(255, 80, 80), "[BindMenu] Reset all binds for profile: " .. displayName)
                        end
                    end
                end,
                "No", function() end
            )
        end)
        
        local sep = menu:AddOption("---")
        sep:SetTextColor(Color(150, 150, 150))
        sep.Paint = function(self, w, h)
            surface.SetDrawColor(60, 60, 65)
            surface.DrawLine(10, h/2, w-10, h/2)
        end
        sep:SetTall(8)
        sep.OnMousePressed = function() end
        
        menu:AddOption("Delete Profile", function()
            Derma_Query(
                "Are you sure you want to delete the profile " .. displayName .. "?\nThis cannot be undone!",
                "Confirm Delete",
                "Yes", function()
                    KEYBIND.Menu:DeleteProfile(currentProfile)
                end,
                "No", function() end
            )
        end)
        
        local sep2 = menu:AddOption("---")
        sep2:SetTextColor(Color(150, 150, 150))
        sep2.Paint = function(self, w, h)
            surface.SetDrawColor(60, 60, 65)
            surface.DrawLine(10, h/2, w-10, h/2)
        end
        sep2:SetTall(8)
        sep2.OnMousePressed = function() end
        
        menu:AddOption("Settings", function()
            KEYBIND.Settings:Create()
        end)
        
        menu:Open()
    end
    
    parent.OnRemove = function()
        if IsValid(selector.dropdownPanel) then
            selector.dropdownPanel:Remove()
        end
    end
    
    return selector
end

function KEYBIND.Menu:CreateKeyButton(parent, key, xPos, yPos, keyWidth, keyHeight, properties)
    if KEYBIND.Settings.Config.debugMode then
        print("[BindMenu] Creating key button: " .. key .. " at position " .. xPos .. "," .. yPos)
    end
    
    local keyBtn = vgui.Create("DButton", parent)
    keyBtn:SetPos(xPos, yPos)
    keyBtn:SetSize(keyWidth, keyHeight)
    keyBtn:SetText("")  
    
    keyBtn.originalPos = { x = xPos, y = yPos }
    keyBtn.originalSize = { w = keyWidth, h = keyHeight }
    keyBtn.isPressed = false
    keyBtn.hue = 0
    keyBtn.animating = false
    
    local roundness = (KEYBIND.Layout and KEYBIND.Layout.Settings and KEYBIND.Layout.Settings.roundness) or 6
    local fullKey = (properties and properties.prefix or "") .. key

    local fontSize = math.min(keyHeight, keyWidth) * 0.4
    local fontName = "KeybindKeyFont_" .. math.floor(fontSize)
    
    if not _G[fontName] then
        surface.CreateFont(fontName, {
            font = "Roboto",
            size = fontSize,
            weight = 600,
            antialias = true
        })
        _G[fontName] = true
    end

    keyBtn.Paint = function(self, w, h)
        local profile = KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile]
        if not profile then return end
        
        if not profile.binds then profile.binds = {} end
        
        local bound = profile.binds[fullKey]
        local theme = KEYBIND.Settings:GetTheme()
        local textColor = theme.text
        
        local categoryHighlight = nil
        if KEYBIND.Settings.Config.highlightCategory and KEYBIND.KeyCategories then
            local category = KEYBIND.KeyCategories[KEYBIND.Settings.Config.highlightCategory]
            if category and KEYBIND.IsKeyInCategory(key, KEYBIND.Settings.Config.highlightCategory) then
                categoryHighlight = category.color
            end
        end

        if bound then
            local boundColor = Color(57, 255, 20)
            
            draw.RoundedBox(roundness, 0, 0, w, h, boundColor)
            
            surface.SetDrawColor(255, 255, 255, 30)
            surface.SetMaterial(Material("gui/gradient_up"))
            surface.DrawTexturedRect(0, 0, w, h)
            
            surface.SetDrawColor(0, 0, 0, 30)
            surface.DrawOutlinedRect(2, 2, w-4, h-4, 1)
            
            if self.isPressed then 
                draw.RoundedBox(roundness, 2, 2, w-4, h-4, Color(0, 0, 0, 100)) 
            end
            
            if self.isFocused then 
                surface.SetDrawColor(255, 255, 255, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2) 
            end
            
            textColor = Color(0, 0, 0)
        else
            local baseColor = self:IsHovered() and theme.keyHover or theme.keyDefault
            
            if categoryHighlight then
                baseColor = Color(
                    baseColor.r * 0.7 + categoryHighlight.r * 0.3,
                    baseColor.g * 0.7 + categoryHighlight.g * 0.3,
                    baseColor.b * 0.7 + categoryHighlight.b * 0.3
                )
            end
            
            draw.RoundedBox(roundness, 0, 0, w, h, baseColor)
            
            if self:IsHovered() then
                surface.SetDrawColor(255, 255, 255, 15)
                surface.SetMaterial(Material("gui/gradient_up"))
                surface.DrawTexturedRect(0, 0, w, h)
                
                local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
                surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 100)
                surface.DrawOutlinedRect(1, 1, w-2, h-2, 1)
            end
            
            if self.isPressed then
                draw.RoundedBox(roundness, 0, 0, w, h, theme.cardHeader)
                surface.SetDrawColor(0, 0, 0, 50)
                surface.DrawOutlinedRect(1, 1, w-2, h-2, 1)
            end
            
            if self.isFocused then
                local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
                surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
            
            if categoryHighlight then
                surface.SetDrawColor(categoryHighlight.r, categoryHighlight.g, categoryHighlight.b, 100)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
        end

        local keyText = key
        if properties and properties.prefix == "KP_" then
            if key == "ENTER" then keyText = "ENTER"
            elseif key == "NMLK" then keyText = "NUM"
            else keyText = key end
        elseif #key > 5 then
            if key == "BACKSPACE" then keyText = "BKSP"
            elseif key == "CAPSLOCK" then keyText = "CAPS"
            elseif key == "CTRL" then keyText = "CTRL"
            elseif key == "SHIFT" then keyText = "SHFT"
            elseif key == "ENTER" then keyText = "ENTR"
            elseif key == "DELETE" then keyText = "DEL"
            elseif key == "INSERT" then keyText = "INS"
            elseif key == "PAGEUP" then keyText = "PGUP"
            elseif key == "PAGEDOWN" then keyText = "PGDN"
            end
        end

        if properties and properties.isVertical then
            cam.Start2D()
                local oldMatrix = Matrix()
                oldMatrix:Set(cam.GetModelMatrix())
                local matrixTranslate = Matrix()
                matrixTranslate:Translate(Vector(w/2, h/2, 0))
                local matrixRotate = Matrix()
                matrixRotate:Rotate(Angle(0, 0, 90))
                local matrixTranslateBack = Matrix()
                matrixTranslateBack:Translate(Vector(-w/2, -h/2, 0))
                local resultMatrix = matrixTranslate * matrixRotate * matrixTranslateBack
                cam.PushModelMatrix(resultMatrix * oldMatrix)
                draw.SimpleText(keyText, fontName, 0, 0, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(keyText, fontName, -1, -1, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                cam.PopModelMatrix()
            cam.End2D()
        else
            draw.SimpleText(keyText, fontName, w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(keyText, fontName, w/2, h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            if bound then
                local dotSize = 4
                draw.RoundedBox(dotSize/2, w-dotSize-3, 3, dotSize, dotSize, Color(255, 255, 255, 200))
            end
        end
    end

    keyBtn.DoClick = nil

    keyBtn.OnMousePressed = function(self, mouseCode)
        if mouseCode == MOUSE_LEFT then
            self.isPressed = true
            if not self.animating then
                self.animating = true
                self:MoveTo(self.originalPos.x + 1, self.originalPos.y + 1, 0.05, 0, -1, function() self.animating = false end)
                self:SizeTo(self.originalSize.w - 2, self.originalSize.h - 2, 0.05, 0, -1)
            end
        end
    end

    keyBtn.OnMouseReleased = function(self, mouseCode)
        if mouseCode == MOUSE_LEFT then
            self.isPressed = false
            if not self.animating then
                self.animating = true
                self:MoveTo(self.originalPos.x, self.originalPos.y, 0.1, 0, -1, function() self.animating = false end)
                self:SizeTo(self.originalSize.w, self.originalSize.h, 0.1, 0, -1)
            end
            
            surface.PlaySound("buttons/button14.wav")
            
            if not KEYBIND.Storage.CurrentProfile then
                print("[BindMenu] Error: No current profile selected")
                return
            end
            
            RunConsoleCommand("bindmenu_opendialog", fullKey)
        end
    end

    keyBtn.OnCursorEntered = function(self) 
        local profile = KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile]
        if not profile then 
            if KEYBIND.Tooltips then
                KEYBIND.Tooltips:Show("Key: " .. key, "Click to set bind")
            else
                self:SetTooltip("Click to set bind")
            end
            return 
        end
        
        if type(profile.binds) ~= "table" then
            profile.binds = {}
            if KEYBIND.Storage and KEYBIND.Storage.SaveBinds then
                KEYBIND.Storage:SaveBinds()
            end
        end
        
        local bound = profile.binds[fullKey]
        
        if KEYBIND.Tooltips then
            if bound then
                local extraInfo = {}
                
                if KEYBIND.KeyCategories then
                    for catId, category in pairs(KEYBIND.KeyCategories) do
                        if KEYBIND.IsKeyInCategory(key, catId) then
                            table.insert(extraInfo, {
                                text = "Category: " .. category.name,
                                color = category.color
                            })
                            break
                        end
                    end
                end
                
                local keyCode = KEYBIND.Handler.KeyCodeMap[key] or input.GetKeyCode(key)
                if keyCode then
                    table.insert(extraInfo, {
                        text = "Key Code: " .. keyCode,
                        color = Color(150, 150, 150)
                    })
                end
                
                KEYBIND.Tooltips:Show(
                    "Key: " .. key, 
                    "Bound to: " .. bound .. "\nClick to modify",
                    extraInfo
                )
            else
                KEYBIND.Tooltips:Show("Key: " .. key, "Click to set bind")
            end
        else
            if bound then
                self:SetTooltip("Bound to: " .. bound .. "\nClick to modify")
            else
                self:SetTooltip("Click to set bind")
            end
        end
        
        if not self.animating and not self.isPressed then
            self.animating = true
            self:SizeTo(
                self.originalSize.w * 1.03, 
                self.originalSize.h * 1.03, 
                0.1, 
                0, 
                -1,
                function()
                    self.animating = false
                end
            )
        end
        
        if CurTime() > KEYBIND.Menu.lastHoverSoundTime + 0.075 then
            surface.PlaySound("buttons/button15.wav")
            KEYBIND.Menu.lastHoverSoundTime = CurTime()
        end
    end
    
    keyBtn.OnCursorExited = function(self)
        if KEYBIND.Tooltips then
            KEYBIND.Tooltips:Hide()
        end
        
        if not self.isPressed and not self.animating then
            self.animating = true
            self:SizeTo(
                self.originalSize.w,
                self.originalSize.h,
                0.1,
                0,
                -1,
                function()
                    self.animating = false
                end
            )
        end
    end

    return keyBtn
end

function KEYBIND.Menu:RefreshTheme()
    if not IsValid(self.Frame) then return end
    
    -- Make sure theme colors are initialized
    if KEYBIND.Settings and KEYBIND.Settings.UpdateThemeColors then
        KEYBIND.Settings:UpdateThemeColors()
    end
    
    local theme = KEYBIND.Settings:GetTheme()
    local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
    
    self.Frame.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0)
        
        draw.RoundedBox(10, 0, 0, w, h, theme.background)
        
        draw.RoundedBoxEx(10, 0, 0, w, 80, accentColor, true, true, false, false)
        
        draw.SimpleText("[BindMenu]", "KeybindMenuTitle", 25, 25, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("[BindMenu]", "KeybindMenuTitle", 24, 24, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        local kbX, kbY = 50, 100
        local kbW, kbH = w - 100, 400
        draw.RoundedBox(8, kbX, kbY, kbW, kbH, theme.keyboardBackground)
    end
    
    for _, child in pairs(self.Frame:GetChildren()) do
        if child:GetClassName() == "DButton" then
            local x, y = child:GetPos()
            if x > self.Frame:GetWide() - 60 and y < 30 then
                child.Paint = function(self, w, h)
                    local hovered = self:IsHovered()
                    local color = hovered and Color(255, 80, 80, 200) or Color(255, 255, 255, 30)
                    
                    draw.RoundedBox(8, 0, 0, w, h, color)
                    
                    local thickness = 2
                    local padding = 14
                    local color = hovered and Color(255, 255, 255) or Color(220, 220, 220)
                    
                    surface.SetDrawColor(color)
                    surface.DrawLine(padding, padding, w-padding, h-padding)
                    surface.DrawLine(w-padding, padding, padding, h-padding)
                end
            elseif x > self.Frame:GetWide() - 110 and x < self.Frame:GetWide() - 60 and y < 30 then
                child.Paint = function(self, w, h)
                    local hovered = self:IsHovered()
                    local color = hovered and accentColor or Color(255, 255, 255, 30)
                    
                    draw.RoundedBox(8, 0, 0, w, h, color)
                    
                    local gear = Material("materials/bindmenu/settings.png")
                    if gear and not gear:IsError() then
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.SetMaterial(gear)
                        surface.DrawTexturedRect(w/2-10, h/2-10, 20, 20)
                    else
                        draw.SimpleText("⚙", "KeybindMenuTitle", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
            else
                local buttonText = child:GetText()
                child.Paint = function(self, w, h)
                    local hovered = self:IsHovered()
                    local baseColor = hovered and theme.buttonHover or theme.buttonDefault
                    
                    if string.find(buttonText, "Profile") then
                        baseColor = hovered and 
                            Color(accentColor.r + 20, accentColor.g + 20, accentColor.b + 20) or 
                            accentColor
                    end
                    
                    draw.RoundedBox(6, 0, 0, w, h, baseColor)
                    
                    surface.SetDrawColor(255, 255, 255, 15)
                    surface.SetMaterial(Material("gui/gradient_up"))
                    surface.DrawTexturedRect(0, 0, w, h)
                    
                    draw.SimpleText(buttonText, "KeybindSettingsButton", w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(buttonText, "KeybindSettingsButton", w/2, h/2, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        elseif child:GetClassName() == "DPanel" then
            if child:GetY() == 10 and child:GetTall() == 60 then
                child.Paint = function(self, w, h)
                end
                
                for _, grandchild in pairs(child:GetChildren()) do
                    if grandchild:GetClassName() == "DButton" then
                        local buttonText = grandchild:GetText()
                        grandchild.Paint = function(self, w, h)
                            local hovered = self:IsHovered()
                            local isActive = string.find(buttonText, "ACTIVE")
                            
                            local baseColor = isActive and accentColor or theme.buttonDefault
                            if hovered then
                                baseColor = Color(baseColor.r + 20, baseColor.g + 20, baseColor.b + 20)
                            end
                            
                            draw.RoundedBox(6, 0, 0, w, h, baseColor)
                            
                            surface.SetDrawColor(255, 255, 255, 15)
                            surface.SetMaterial(Material("gui/gradient_up"))
                            surface.DrawTexturedRect(0, 0, w, h)
                            
                            draw.SimpleText(buttonText, "KeybindSettingsButton", w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                            draw.SimpleText(buttonText, "KeybindSettingsButton", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end
                    end
                end
            elseif child:GetY() == 100 and child:GetTall() == 400 then
                child:SetPaintBackground(false)
            end
        end
    end
    
    self:RefreshKeyboardLayout()
end

function KEYBIND.Menu:Create()
    if not KEYBIND or not KEYBIND.Colors then return end
    if not (KEYBIND.Storage and KEYBIND.Storage.CurrentProfile and KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile]) then
        print("[BindMenu] Please select a valid profile.")
        return
    end

    if IsValid(self.Frame) then
        self.Frame:Remove()
    end
    
    KEYBIND.Menu.switchingTab = false
    KEYBIND.Menu.refreshingKeyboard = false

    local screenW, screenH = ScrW(), ScrH()
    local frameW = math.min(1200, screenW * 0.9)
    local frameH = math.min(600, screenH * 0.8)
    
    local scaleFactor = math.min(screenW / 1920, screenH / 1080)
    local calculatedScale = math.Clamp(scaleFactor, 0.7, 1.2)
    
    if KEYBIND.Settings.Config.autoScale then
        KEYBIND.Renderer.Scale = calculatedScale
    end

    local theme = KEYBIND.Settings:GetTheme()
    local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
    
    self.Frame = vgui.Create("DFrame")
    self.Frame:SetSize(frameW, frameH)
    self.Frame:Center()
    self.Frame:SetTitle("")
    self.Frame:MakePopup()
    self.Frame:ShowCloseButton(false)
    self.Frame:SetDraggable(true)
    
    self.Frame.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0)
        
        draw.RoundedBox(10, 0, 0, w, h, theme.background)
        
        draw.RoundedBoxEx(10, 0, 0, w, 80, accentColor, true, true, false, false)
        
        draw.SimpleText("[BindMenu]", "KeybindMenuTitle", 25, 25, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("[BindMenu]", "KeybindMenuTitle", 24, 24, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local closeBtn = vgui.Create("DButton", self.Frame)
    closeBtn:SetSize(40, 40)
    closeBtn:SetPos(self.Frame:GetWide() - 50, 20)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(255, 80, 80, 200) or Color(255, 255, 255, 30)
        
        draw.RoundedBox(8, 0, 0, w, h, color)
        
        local thickness = 2
        local padding = 14
        local color = hovered and Color(255, 255, 255) or Color(220, 220, 220)
        
        surface.SetDrawColor(color)
        surface.DrawLine(padding, padding, w-padding, h-padding)
        surface.DrawLine(w-padding, padding, padding, h-padding)
    end
    closeBtn.DoClick = function()
        self.Frame:AlphaTo(0, 0.2, 0, function()
            self:CleanUp()
            self.Frame:Remove()
        end)
        
        surface.PlaySound("buttons/button14.wav")
    end

    local tabHeight = 40
    local tabPanel = vgui.Create("DPanel", self.Frame)
    tabPanel:SetPos(50, 80)
    tabPanel:SetSize(self.Frame:GetWide() - 100, tabHeight)
    tabPanel:SetPaintBackground(false)
    
    local tabs = {
        {name = "Profiles", id = "profiles"},
        {name = "Keybinds", id = "keybinds", default = true},
        {name = "Settings", id = "settings"}
    }
    
    self.tabButtons = {}
    local tabWidth = tabPanel:GetWide() / #tabs
    
    for i, tab in ipairs(tabs) do
        local btn = vgui.Create("DButton", tabPanel)
        btn:SetSize(tabWidth, tabHeight)
        btn:SetPos((i-1) * tabWidth, 0)
        btn:SetText("")
        
        self.tabButtons[tab.id] = btn
        
        btn.Paint = function(self, w, h)
            local isActive = KEYBIND.Menu.activeTab == tab.id
            local hovered = self:IsHovered()
            
            if isActive then
                draw.RoundedBoxEx(8, 0, 0, w, h, accentColor, true, true, false, false)
                surface.SetDrawColor(255, 255, 255)
                surface.DrawRect(10, h-3, w-20, 3)
            elseif hovered then
                local hoverColor = Color(accentColor.r*0.7, accentColor.g*0.7, accentColor.b*0.7)
                draw.RoundedBoxEx(8, 0, 0, w, h, hoverColor, true, true, false, false)
            end
            
            local textColor = isActive and Color(255, 255, 255) or Color(200, 200, 200)
            draw.SimpleText(tab.name, "KeybindMenuTitle", w/2, h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        btn.DoClick = function()
            KEYBIND.Menu:SwitchTab(tab.id)
            surface.PlaySound("buttons/button14.wav")
        end
        
        if tab.default then
            KEYBIND.Menu.activeTab = tab.id
        end
    end
    
    self.tabContents = {}
    
    self.tabContents.profiles = vgui.Create("DPanel", self.Frame)
    self.tabContents.profiles:SetPos(50, 120)
    self.tabContents.profiles:SetSize(self.Frame:GetWide() - 100, self.Frame:GetTall() - 130)
    self.tabContents.profiles:SetPaintBackground(false)
    self.tabContents.profiles:SetVisible(KEYBIND.Menu.activeTab == "profiles")
    self:CreateProfilesTab(self.tabContents.profiles)
    
    self.tabContents.keybinds = vgui.Create("DPanel", self.Frame)
    self.tabContents.keybinds:SetPos(50, 120)
    self.tabContents.keybinds:SetSize(self.Frame:GetWide() - 100, self.Frame:GetTall() - 130)
    self.tabContents.keybinds:SetPaintBackground(false)
    self.tabContents.keybinds:SetVisible(KEYBIND.Menu.activeTab == "keybinds")
    self:CreateKeybindsTab(self.tabContents.keybinds)
    
    self.tabContents.settings = vgui.Create("DPanel", self.Frame)
    self.tabContents.settings:SetPos(50, 120)
    self.tabContents.settings:SetSize(self.Frame:GetWide() - 100, self.Frame:GetTall() - 130)
    self.tabContents.settings:SetPaintBackground(false)
    self.tabContents.settings:SetVisible(KEYBIND.Menu.activeTab == "settings")
    self:CreateSettingsTab(self.tabContents.settings)
    
    self:SwitchTab(KEYBIND.Menu.activeTab or "keybinds")
    
    self.Frame:SetAlpha(0)
    self.Frame:AlphaTo(255, 0.3, 0)
end

function KEYBIND.Menu:ShowCreateProfileDialog()
    local theme = KEYBIND.Settings:GetTheme()
    local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
    
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
        draw.SimpleText("Create New Profile", "KeybindSettingsHeader", 15, 20, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
    nameLabel:SetText("Profile Name:")
    nameLabel:SetFont("KeybindSettingsText")
    nameLabel:SetTextColor(theme.text)
    nameLabel:SizeToContents()
    
    local nameEntry = vgui.Create("DTextEntry", dialog)
    nameEntry:SetPos(20, 85)
    nameEntry:SetSize(dialog:GetWide() - 40, 30)
    nameEntry:SetFont("KeybindSettingsText")
    nameEntry:SetPlaceholderText("Enter profile name...")
    
    local createBtn = vgui.Create("DButton", dialog)
    createBtn:SetPos(20, dialog:GetTall() - 60)
    createBtn:SetSize(dialog:GetWide() - 40, 40)
    createBtn:SetText("Create Profile")
    createBtn:SetFont("KeybindSettingsButton")
    createBtn:SetTextColor(Color(255, 255, 255))
    
    createBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(accentColor.r + 20, accentColor.g + 20, accentColor.b + 20) or accentColor
        draw.RoundedBox(8, 0, 0, w, h, color)
    end
    
    createBtn.DoClick = function()
        local profileName = nameEntry:GetValue()
        
        if profileName == "" then
            Derma_Message("Please enter a profile name.", "Error", "OK")
            return
        end
        
        local internalName = "Custom_" .. os.time() .. "_" .. math.random(1000, 9999)
        
        KEYBIND.Storage.Profiles[internalName] = {
            name = internalName,
            displayName = profileName,
            icon = "Profile1",
            binds = {}
        }
        
        KEYBIND.Storage.CurrentProfile = internalName
        KEYBIND.Storage:SaveBinds()
        
        if KEYBIND.Settings.Config.showFeedback then
            chat.AddText(Color(0, 255, 0), "[BindMenu] Created new profile: " .. profileName)
        end
        
        self:RefreshProfilesTab()
        
        dialog:Remove()
        
        surface.PlaySound("buttons/button14.wav")
    end
    
    nameEntry:RequestFocus()
end

function KEYBIND.Menu:CreateProfilesTab(parent)
    parent:Clear()
    parent:SetPaintBackground(false)
    
    local theme = KEYBIND.Settings:GetTheme()
    local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
    
    local titleLabel = vgui.Create("DLabel", parent)
    titleLabel:SetPos(10, 10)
    titleLabel:SetFont("KeybindMenuTitle")
    titleLabel:SetText("Profile Management")
    titleLabel:SetTextColor(theme.text)
    titleLabel:SizeToContents()
    
    local descLabel = vgui.Create("DLabel", parent)
    descLabel:SetPos(10, 40)
    descLabel:SetSize(parent:GetWide() - 20, 30)
    descLabel:SetFont("KeybindSettingsText")
    descLabel:SetText("Select a profile to edit or create a new one. Premium and Loyalty ranks unlock additional profile slots.")
    descLabel:SetTextColor(theme.textDim)
    descLabel:SetWrap(true)
    
    local gridContainer = vgui.Create("DPanel", parent)
    gridContainer:SetPos(0, 80)
    gridContainer:SetSize(parent:GetWide(), parent:GetTall() - 90)
    gridContainer:SetPaintBackground(false)
    
    local userGroup = LocalPlayer():GetUserGroup()
    local maxAllowedProfiles = 2
    if userGroup == "premium" then
        maxAllowedProfiles = 3
    elseif userGroup == "loyalty" then
        maxAllowedProfiles = 6
    end

    local existingProfiles = {}
    for profileName, profileData in pairs(KEYBIND.Storage.Profiles or {}) do
        table.insert(existingProfiles, {
            name = profileName,
            displayName = profileData.displayName or profileName,
            icon = profileData.icon or "Profile1",
            binds = profileData.binds or {}
        })
    end
    table.sort(existingProfiles, function(a, b) return a.name < b.name end)
    local createdProfileCount = #existingProfiles

    local itemWidth = 180
    local itemHeight = 120
    local spacing = 20
    local itemsPerRow = 3
    local totalRowWidth = (itemWidth * itemsPerRow) + (spacing * (itemsPerRow - 1))
    local startX = math.floor((parent:GetWide() - totalRowWidth) / 2)
    if startX < 10 then startX = 10 end

    for i = 1, 6 do
        local col = (i - 1) % itemsPerRow
        local row = math.floor((i - 1) / itemsPerRow)
        local x = startX + col * (itemWidth + spacing)
        local y = row * (itemHeight + spacing)

        local data, isNew, isLocked, requiredRank
        
        if i <= createdProfileCount then
            data = existingProfiles[i]
            isNew = false
            isLocked = false
        elseif i <= maxAllowedProfiles then
            data = {}
            isNew = true
            isLocked = false
        else
            data = {}
            isNew = false
            isLocked = true
            if i <= 3 then
                requiredRank = "Premium"
            else
                requiredRank = "Loyalty"
            end
        end

        self:CreateProfileItem(gridContainer, x, y, itemWidth, itemHeight, data, isNew, isLocked, requiredRank)
    end
    
    self.profileGrid = gridContainer
end

function KEYBIND.Menu:CreateProfileItem(parent, x, y, w, h, data, isNew, isLocked, requiredRank)
    local theme = KEYBIND.Settings:GetTheme()
    local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
    local userGroup = LocalPlayer():GetUserGroup()

    local item = vgui.Create("DButton", parent)
    item:SetPos(x, y)
    item:SetSize(w, h)
    item:SetText("")

    item.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local isActive = not isNew and not isLocked and data.name == KEYBIND.Storage.CurrentProfile
        
        local bgColor = isActive and accentColor or theme.cardBackground
        if isLocked then
            bgColor = Color(bgColor.r * 0.7, bgColor.g * 0.7, bgColor.b * 0.7, 200)
        elseif isNew then
            bgColor = Color(bgColor.r * 0.8, bgColor.g * 0.8, bgColor.b * 0.8, 200)
        else
            bgColor = Color(bgColor.r, bgColor.g, bgColor.b, 230)
        end
        
        if hovered and not isLocked then
            bgColor = Color(bgColor.r + 20, bgColor.g + 20, bgColor.b + 20, bgColor.a)
        end
        
        draw.RoundedBox(10, 0, 0, w, h, bgColor)
        
        if not isNew and not isLocked and data.icon then
            local iconMat = KEYBIND.Menu.ProfileIcons[data.icon] or KEYBIND.Menu.DefaultIcon
            if iconMat and not iconMat:IsError() then
                surface.SetDrawColor(255, 255, 255, 50)
                surface.SetMaterial(iconMat)
                surface.DrawTexturedRect(w/2 - 32, h/2 - 32, 64, 64)
            end
        end
        
        if isNew then
            draw.SimpleText("+", "KeybindMenuTitle", w/2, h/2 - 15, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Create New Profile", "KeybindSettingsText", w/2, h/2 + 15, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        elseif isLocked then
            draw.SimpleText("×", "KeybindMenuTitle", w/2, h/2 - 15, theme.textDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Requires " .. requiredRank, "KeybindSettingsText", w/2, h/2 + 15, theme.textDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(data.displayName, "KeybindSettingsText", w/2, h/2 - 15, isActive and Color(255, 255, 255) or theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            local bindCount = table.Count(data.binds or {})
            draw.SimpleText(bindCount .. " binds", "KeybindSettingsText", w/2, h/2 + 15, isActive and Color(220, 220, 220) or theme.textDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            if isActive then
                draw.RoundedBox(5, w - 15, 10, 10, 10, Color(0, 255, 0))
            end
        end
    end

    item.DoClick = function()
        if isNew then
            self:ShowCreateProfileDialog()
        elseif isLocked then
            Derma_Message("This profile slot is locked.\nUpgrade to " .. requiredRank .. " to unlock it.", "Profile Locked", "OK")
        else
            KEYBIND.Storage.CurrentProfile = data.name
            KEYBIND.Storage:SaveBinds()
            self:RefreshProfilesTab()
            if KEYBIND.Settings.Config.showFeedback then
                chat.AddText(Color(0, 255, 0), "[BindMenu] Switched to profile: " .. data.displayName)
            end
            surface.PlaySound("buttons/button14.wav")
        end
    end

    if not isNew and not isLocked then
        item.DoRightClick = function()
            local menu = DermaMenu()
            
            menu:AddOption("Rename", function()
                self:ShowRenameProfileDialog(data.name, data.displayName)
            end)
            
            menu:AddOption("Change Icon", function()
                if KEYBIND.Settings and KEYBIND.Settings.OpenIconSelector then
                    KEYBIND.Settings:OpenIconSelector(data.name, data.displayName)
                else
                    print("[BindMenu] Error: OpenIconSelector function not found!")
                end
            end)
            
            menu:AddOption("Reset Binds", function()
                Derma_Query(
                    "Are you sure you want to reset all binds for " .. data.displayName .. "?",
                    "Confirm Reset",
                    "Yes", function()
                        if KEYBIND.Storage.Profiles[data.name] then
                            KEYBIND.Storage.Profiles[data.name].binds = {}
                            KEYBIND.Storage:SaveBinds()
                            self:RefreshProfilesTab()
                            if KEYBIND.Settings.Config.showFeedback then
                                chat.AddText(Color(255, 80, 80), "[BindMenu] Reset all binds for profile: " .. data.displayName)
                            end
                        end
                    end,
                    "No", function() end
                )
            end)
            
            local sep = menu:AddOption("---")
            sep:SetTextColor(Color(150, 150, 150))
            sep.Paint = function(self, w, h) surface.SetDrawColor(60, 60, 65) surface.DrawLine(10, h/2, w-10, h/2) end
            sep:SetTall(8)
            sep.OnMousePressed = function() end
            
            menu:AddOption("Delete Profile", function()
                Derma_Query(
                    "Are you sure you want to delete the profile " .. data.displayName .. "?\nThis cannot be undone!",
                    "Confirm Delete",
                    "Yes", function()
                        self:DeleteProfile(data.name)
                    end,
                    "No", function() end
                )
            end)
            
            menu:Open()
        end
    end
    
    return item
end

function KEYBIND.Menu:ShowRenameProfileDialog(profileName, currentName)
    local theme = KEYBIND.Settings:GetTheme()
    local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
    
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

function KEYBIND.Menu:DeleteProfile(profileName)
    local profileCount = 0
    for _ in pairs(KEYBIND.Storage.Profiles) do
        profileCount = profileCount + 1
    end
    
    if profileCount <= 1 then
        Derma_Message("You cannot delete your only profile.", "Error", "OK")
        return
    end
    
    local profileData = KEYBIND.Storage.Profiles[profileName]
    if not profileData then return end
    
    local displayName = profileData.displayName or profileName
    
    KEYBIND.Storage.Profiles[profileName] = nil
    
    if KEYBIND.Storage.CurrentProfile == profileName then
        for name, _ in pairs(KEYBIND.Storage.Profiles) do
            KEYBIND.Storage.CurrentProfile = name
            break
        end
    end
    
    KEYBIND.Storage:SaveBinds()
    
    if KEYBIND.Settings.Config.showFeedback then
        chat.AddText(Color(255, 80, 80), "[BindMenu] Deleted profile: " .. displayName)
    end
    
    self:RefreshProfilesTab()
    
    surface.PlaySound("buttons/button14.wav")
end

function KEYBIND.Menu:CreateKeybindsTab(parent)
    parent:Clear()
    parent:SetPaintBackground(false)
    
    local profileIndicator = vgui.Create("DPanel", parent)
    profileIndicator:SetPos(0, 0)
    profileIndicator:SetSize(parent:GetWide(), 50)
    profileIndicator:SetPaintBackground(false)
    
    local theme = KEYBIND.Settings:GetTheme()
    local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
    
    local currentProfile = KEYBIND.Storage.CurrentProfile
    local profileData = KEYBIND.Storage.Profiles[currentProfile]
    local displayName = profileData and profileData.displayName or "Default Profile"
    local iconName = profileData and profileData.icon or "alyx"
    local bindCount = 0
    
    if profileData and profileData.binds then
        bindCount = table.Count(profileData.binds)
    end
    
    local iconMat = KEYBIND.Menu.ProfileIcons[iconName] or KEYBIND.Menu.DefaultIcon
    
    profileIndicator.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(theme.cardBackground.r, theme.cardBackground.g, theme.cardBackground.b, 100))
        
        if iconMat and not iconMat:IsError() then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(iconMat)
            surface.DrawTexturedRect(15, h/2 - 20, 40, 40)
        end
        
        draw.SimpleText(displayName, "KeybindMenuTitle", 70, h/2, theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        draw.SimpleText(bindCount .. " binds", "KeybindSettingsText", w - 15, h/2, theme.textDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    
    local keyboardContainer = vgui.Create("DPanel", parent)
    keyboardContainer:SetPos(0, 55)
    keyboardContainer:SetSize(parent:GetWide(), parent:GetTall() - 55)
    keyboardContainer:SetPaintBackground(false)
    
    KEYBIND.Renderer.Scale = KEYBIND.Settings.Config.keyboardScale or 1.0
    KEYBIND.Renderer.CurrentLayout = KEYBIND.Settings.Config.keyboardLayout or "StandardKeyboard"
    
    if not KEYBIND.Layout or not KEYBIND.Layout.StandardKeyboard then
        print("[BindMenu] ERROR: Keyboard layout not properly initialized!")
        include("bindmenu/cl_keybind_layout.lua")
    end
    
    KEYBIND.Renderer:RenderKeyboard(keyboardContainer, KEYBIND.Renderer.CurrentLayout)
    
    self:EnableKeyboardNavigation()
    
    self.keyboardContainer = keyboardContainer
end

function KEYBIND.Menu:CreateSettingsTab(parent)
    parent:Clear()
    
    local theme = KEYBIND.Settings:GetTheme()
    local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
    
    local scroll = vgui.Create("DScrollPanel", parent)
    scroll:Dock(FILL)
    scroll:DockMargin(0, 0, 0, 0)
    
    local scrollbar = scroll:GetVBar()
    scrollbar:SetWide(6)
    scrollbar.Paint = function(self, w, h) end
    scrollbar.btnUp.Paint = function(self, w, h) end
    scrollbar.btnDown.Paint = function(self, w, h) end
    scrollbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(255, 255, 255, 40))
    end
    
    local function CreateSettingsCard(title, height)
        local card = vgui.Create("DPanel", scroll)
        card:Dock(TOP)
        card:SetHeight(height)
        card:DockMargin(20, 10, 20, 10)
        
        card.Paint = function(self, w, h)
            draw.RoundedBox(8, 2, 2, w-4, h-4, Color(0, 0, 0, 30))
            draw.RoundedBox(8, 0, 0, w, h, theme.cardBackground)
            
            local headerColor = Color(
                accentColor.r * 0.8,
                accentColor.g * 0.8,
                accentColor.b * 0.8,
                230
            )
            draw.RoundedBoxEx(8, 0, 0, w, 36, headerColor, true, true, false, false)
            
            draw.SimpleText(title, "KeybindSettingsHeader", 15, 18, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(title, "KeybindSettingsHeader", 14, 17, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        return card
    end
    
    local generalCard = CreateSettingsCard("General Settings", 180)
    
    local feedbackCheck = vgui.Create("DCheckBoxLabel", generalCard)
    feedbackCheck:SetPos(20, 55)
    feedbackCheck:SetText("Show Feedback Messages")
    feedbackCheck:SetTextColor(theme.text)
    feedbackCheck:SetFont("KeybindSettingsText")
    feedbackCheck:SizeToContents()
    feedbackCheck:SetValue(KEYBIND.Settings.Config.showFeedback)
    
    feedbackCheck.OnChange = function(self, val)
        KEYBIND.Settings.Config.showFeedback = val
        KEYBIND.Settings:SaveSettings()
        
        if val then
            chat.AddText(Color(0, 255, 0), "[BindMenu] Feedback messages enabled")
        else
            chat.AddText(Color(255, 0, 0), "[BindMenu] Feedback messages disabled")
        end
    end
    
    local autoScaleCheck = vgui.Create("DCheckBoxLabel", generalCard)
    autoScaleCheck:SetPos(20, 85)
    autoScaleCheck:SetText("Auto-Scale to Screen Size")
    autoScaleCheck:SetTextColor(theme.text)
    autoScaleCheck:SetFont("KeybindSettingsText")
    autoScaleCheck:SizeToContents()
    autoScaleCheck:SetValue(KEYBIND.Settings.Config.autoScale or false)
    
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
    
    local themeCheck = vgui.Create("DCheckBoxLabel", generalCard)
    themeCheck:SetPos(20, 115)
    themeCheck:SetText("Dark Theme")
    themeCheck:SetTextColor(theme.text)
    themeCheck:SetFont("KeybindSettingsText")
    themeCheck:SizeToContents()
    themeCheck:SetValue(KEYBIND.Settings.Config.darkTheme)
    
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
        local debugCheck = vgui.Create("DCheckBoxLabel", generalCard)
        debugCheck:SetPos(20, 145)
        debugCheck:SetText("Show Layout Grid - 'developer 1'")
        debugCheck:SetTextColor(theme.text)
        debugCheck:SetFont("KeybindSettingsText")
        debugCheck:SizeToContents()
        debugCheck:SetValue(KEYBIND.Settings.Config.debugMode or false)
        
        debugCheck.OnChange = function(self, val)
            KEYBIND.Settings.Config.debugMode = val
            KEYBIND.Settings:SaveSettings()
            
            if IsValid(KEYBIND.Menu.Frame) then
                KEYBIND.Menu:RefreshKeyboardLayout()
            end
        end
        
        StyleCheckbox(debugCheck)
    end
    
    local importDefaultsCard = CreateSettingsCard("Import Default Binds", 120)

    -- Adjust the import button position to be below the description
    local importBtn = vgui.Create("DButton", importDefaultsCard)
    importBtn:SetPos(20, 90)
    importBtn:SetSize(200, 30)
    importBtn:SetText("Import Default Binds")
    importBtn:SetTextColor(Color(255, 255, 255))
    
    importBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(accentColor.r + 20, accentColor.g + 20, accentColor.b + 20) or accentColor
        draw.RoundedBox(6, 0, 0, w, h, color)
        
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
    end
    
    importBtn.DoClick = function()
        Derma_Query(
            "Are you sure you want to import your default Garry's Mod binds?\nThis will add to your current profile binds.",
            "Confirm Import",
            "Yes", function()
                local success, imported, conflicts, skipped, excluded = KEYBIND.Settings:ImportGModBinds(KEYBIND.Storage.CurrentProfile)
                
                if IsValid(KEYBIND.Menu.Frame) then
                    KEYBIND.Menu:RefreshKeyboardLayout()
                end
                
                surface.PlaySound("buttons/button14.wav")
            end,
            "No", function() end
        )
    end
    
    local appearanceCard = CreateSettingsCard("Appearance Settings", 200)
    
    local accentLabel = vgui.Create("DLabel", appearanceCard)
    accentLabel:SetPos(20, 50)
    accentLabel:SetText("Accent Color:")
    accentLabel:SetFont("KeybindSettingsText")
    accentLabel:SetTextColor(theme.text)
    accentLabel:SizeToContents()
    
    local colorPreview = vgui.Create("DPanel", appearanceCard)
    colorPreview:SetPos(150, 50)
    colorPreview:SetSize(40, 25)
    colorPreview.Paint = function(self, w, h)
        local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
        draw.RoundedBox(4, 0, 0, w, h, accentColor)
        surface.SetDrawColor(theme.text)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    local colorBtn = vgui.Create("DButton", appearanceCard)
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
            
            if IsValid(KEYBIND.Menu.Frame) then
                KEYBIND.Menu:RefreshTheme()
            end
            
            timer.Simple(0.1, function()
                if IsValid(KEYBIND.Settings.Frame) then
                    local oldFrame = KEYBIND.Settings.Frame
                    KEYBIND.Settings:Create()
                    oldFrame:Remove()
                end
            end)
            
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
    
    local presetLabel = vgui.Create("DLabel", appearanceCard)
    presetLabel:SetPos(20, 90)
    presetLabel:SetText("Preset Colors:")
    presetLabel:SetFont("KeybindSettingsText")
    presetLabel:SetTextColor(theme.text)
    presetLabel:SizeToContents()
    
    for i, preset in ipairs(presetColors) do
        local presetBtn = vgui.Create("DButton", appearanceCard)
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
            
            if IsValid(KEYBIND.Menu.Frame) then
                KEYBIND.Menu:RefreshTheme()
            end
            
            timer.Simple(0.1, function()
                if IsValid(KEYBIND.Settings.Frame) then
                    local oldFrame = KEYBIND.Settings.Frame
                    KEYBIND.Settings:Create()
                    oldFrame:Remove()
                end
            end)
        end
        
        presetBtn:SetTooltip(preset.name)
    end
    
    local categoryLabel = vgui.Create("DLabel", appearanceCard)
    categoryLabel:SetPos(20, 130)
    categoryLabel:SetText("Highlight Key Category:")
    categoryLabel:SetFont("KeybindSettingsText")
    categoryLabel:SetTextColor(theme.text)
    categoryLabel:SizeToContents()

    local categoryCombo = vgui.Create("DComboBox", appearanceCard)
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
    
    local aboutCard = CreateSettingsCard("About Bind Menu", 120)
    
    local versionLabel = vgui.Create("DLabel", aboutCard)
    versionLabel:SetPos(20, 55)
    versionLabel:SetText("Version: 1.0")
    versionLabel:SetFont("KeybindSettingsText")
    versionLabel:SetTextColor(theme.text)
    versionLabel:SizeToContents()
    
    local creditsLabel = vgui.Create("DLabel", aboutCard)
    creditsLabel:SetPos(20, 80)
    creditsLabel:SetText("Created by: dr. snortthisperc")
    creditsLabel:SetFont("KeybindSettingsText")
    creditsLabel:SetTextColor(theme.text)
    creditsLabel:SizeToContents()
    
    self.settingsScroll = scroll
end

function KEYBIND.Menu:SwitchTab(tabId)
    if KEYBIND.Menu.switchingTab then
        return
    end
    
    KEYBIND.Menu.switchingTab = true
    KEYBIND.Menu.activeTab = tabId
    
    if self.tabContents then
        for id, panel in pairs(self.tabContents) do
            if IsValid(panel) then
                panel:SetVisible(id == tabId)
            end
        end
    end
    
    if self.tabButtons then
        for id, button in pairs(self.tabButtons) do
            if IsValid(button) then
                button:InvalidateLayout()
            end
        end
    end
    
    if tabId == "keybinds" then
        if not KEYBIND.Menu.refreshingKeyboard then
            self:CreateKeybindsTab(self.tabContents.keybinds)
        end
    elseif tabId == "profiles" then
        self:CreateProfilesTab(self.tabContents.profiles)
    elseif tabId == "settings" then
        self:CreateSettingsTab(self.tabContents.settings)
    end
    
    KEYBIND.Menu.switchingTab = false
end

function KEYBIND.Menu:FullUIRefresh()
    -- Ensure the main menu is actually open before trying to refresh it.
    if not IsValid(self.Frame) then return end

    print("[BindMenu] Performing full UI refresh for theme change...")

    -- 1. Refresh the main frame's background and top-level buttons.
    self:RefreshTheme()

    -- 2. Re-render the entire keyboard to update every key's color.
    self:RefreshKeyboardLayout()

    -- 3. If the settings tab is the active one, recreate its contents.
    -- This handles both "settings" and "options" if you renamed the tab ID.
    local settingsTabId = self.activeTab
    if (settingsTabId == "settings" or settingsTabId == "options") and self.tabContents and self.tabContents[settingsTabId] then
        if self.CreateSettingsTab then
            self:CreateSettingsTab(self.tabContents[settingsTabId])
        elseif self.CreateOptionsTab then
            self:CreateOptionsTab(self.tabContents[settingsTabId])
        end
    end

    -- 4. Also, if the standalone settings window is open, recreate it.
    -- This ensures both windows are updated if they happen to be open.
    if KEYBIND.Settings and IsValid(KEYBIND.Settings.Frame) then
        local oldFrame = KEYBIND.Settings.Frame
        KEYBIND.Settings:Create()
        oldFrame:Remove()
    end
end

function KEYBIND.Menu:RefreshProfilesTab()
    if not IsValid(self.tabContents.profiles) then return end
    
    self:CreateProfilesTab(self.tabContents.profiles)
end

function KEYBIND.Menu:RefreshSettingsTab()
    if not IsValid(self.tabContents.settings) then return end
    
    self:CreateSettingsTab(self.tabContents.settings)
end

function KEYBIND.Renderer:CalculateSectionPositions(layout, containerSize, effectiveScale)
    if KEYBIND.Settings.Config.debugMode then
        print("[BindMenu] Calculating section positions with scale: " .. effectiveScale)
    end

    local positions = {}
    local settings = KEYBIND.Layout.Settings or { baseKeySize = 43, spacing = 7, padding = 20, sectionSpacing = 30 }
    
    local keySize = settings.baseKeySize * effectiveScale
    local spacing = settings.spacing * effectiveScale
    local padding = settings.padding * effectiveScale
    local sectionSpacing = settings.sectionSpacing * effectiveScale

    local sectionSizes = {}
    for id, section in pairs(layout.sections) do
        local width, height = self:CalculateSectionSize(section, keySize, spacing)
        sectionSizes[id] = { width = width, height = height }
    end
    
    local totalWidth = 0
    local maxHeight = 0
    local sectionOrder = {"main", "nav", "numpad"}
    
    for i, id in ipairs(sectionOrder) do
        if layout.sections[id] and sectionSizes[id] then
            totalWidth = totalWidth + sectionSizes[id].width
            maxHeight = math.max(maxHeight, sectionSizes[id].height)
            if i < #sectionOrder then
                totalWidth = totalWidth + sectionSpacing
            end
        end
    end
    
    local startX = (containerSize.w - totalWidth) / 2
    local currentX = startX

    for _, id in ipairs(sectionOrder) do
        if layout.sections[id] and sectionSizes[id] then
            local size = sectionSizes[id]
            local posY = (containerSize.h - size.height) / 2
            
            positions[id] = { 
                x = currentX, 
                y = posY, 
                width = size.width, 
                height = size.height 
            }
            
            currentX = currentX + size.width + sectionSpacing
        end
    end

    if positions["nav"] and positions["numpad"] then
        positions["numpad"].y = positions["nav"].y
    end

    return positions
end

function KEYBIND.Renderer:CalculateSectionSize(section, keySize, spacing)
    local maxWidth = 0
    local totalHeight = 0
    local rowHeights = {}

    for rowIndex, row in ipairs(section.rows) do
        local rowWidth = 0
        local maxHeightInRow = 0

        for _, keyData in ipairs(row) do
            local keyWidth = keySize * (keyData.width or 1)
            local keyHeight = keySize * (keyData.height or 1)
            rowWidth = rowWidth + keyWidth + spacing
            maxHeightInRow = math.max(maxHeightInRow, keyHeight)
        end

        maxWidth = math.max(maxWidth, rowWidth - spacing)
        rowHeights[rowIndex] = maxHeightInRow
        totalHeight = totalHeight + maxHeightInRow + spacing
    end

    return maxWidth, totalHeight - spacing
end

function KEYBIND.Renderer:RenderKeyboard(container, layoutName)
    if KEYBIND.Settings.Config.debugMode then
        print("[BindMenu] RenderKeyboard called with layout: " .. tostring(layoutName))
    end
    
    self:ClearKeyboard()
    
    local layout = KEYBIND.Layout[layoutName or self.CurrentLayout]
    if not layout then
        print("[BindMenu] ERROR: Layout '" .. tostring(layoutName) .. "' not found!")
        return
    end
    
    local settings = KEYBIND.Layout.Settings or { baseKeySize = 43, spacing = 7, padding = 20, sectionSpacing = 30 }
    local containerSize = { w = container:GetWide(), h = container:GetTall() }
    
    local initialScale = self.Scale
    local totalWidth = 0
    local sectionOrder = {"main", "nav", "numpad"}
    
    for i, id in ipairs(sectionOrder) do
        if layout.sections[id] then
            local sectionW, _ = self:CalculateSectionSize(layout.sections[id], settings.baseKeySize * initialScale, settings.spacing * initialScale)
            totalWidth = totalWidth + sectionW
            if i < #sectionOrder then
                totalWidth = totalWidth + (settings.sectionSpacing * initialScale)
            end
        end
    end
    
    local fitScale = 1
    local availableWidth = containerSize.w - (settings.padding * initialScale * 2)
    if totalWidth > availableWidth then
        fitScale = availableWidth / totalWidth
        fitScale = math.max(0.5, fitScale) 
    end
    
    local effectiveScale = initialScale * fitScale
    
    local sectionPositions = self:CalculateSectionPositions(layout, containerSize, effectiveScale)
    
    for id, section in pairs(layout.sections) do
        local pos = sectionPositions[id]
        if not pos then 
            print("[BindMenu] ERROR: No position data for section: " .. id)
            continue 
        end
        
        local sectionPanel = vgui.Create("DPanel", container)
        sectionPanel:SetPos(pos.x, pos.y)
        sectionPanel:SetSize(pos.width, pos.height)
        sectionPanel:SetPaintBackground(false)
        self.SectionPanels[id] = sectionPanel
        
        self:RenderKeysForSection(sectionPanel, section, effectiveScale)
    end
end

function KEYBIND.Renderer:RenderKeysForSection(panel, section, effectiveScale)
    if KEYBIND.Settings.Config.debugMode then
        print("[BindMenu] Rendering keys for section: " .. (section.id or "unknown") .. " with scale: " .. effectiveScale)
    end

    local settings = KEYBIND.Layout.Settings or { baseKeySize = 43, spacing = 7 }
    local keySize = settings.baseKeySize * effectiveScale
    local spacing = settings.spacing * effectiveScale

    local gridMatrix = {}
    local keyRenderList = {}
    local maxCols = 0

    for _, rowData in ipairs(section.rows) do
        local currentCols = 0
        for _, keyData in ipairs(rowData) do
            currentCols = currentCols + (keyData.width or 1)
        end
        maxCols = math.max(maxCols, currentCols)
    end

    local numRows = #section.rows
    for r = 1, numRows + 5 do
        gridMatrix[r] = {}
        for c = 1, maxCols + 5 do
            gridMatrix[r][c] = false
        end
    end

    local currentRow = 1
    for _, rowData in ipairs(section.rows) do
        local currentCol = 1
        for _, keyData in ipairs(rowData) do
            while gridMatrix[currentRow] and gridMatrix[currentRow][currentCol] do
                currentCol = currentCol + 1
            end

            if keyData.key ~= "" then
                local keyW = keyData.width or 1
                local keyH = keyData.height or 1

                table.insert(keyRenderList, {
                    keyData = keyData,
                    gridX = currentCol,
                    gridY = currentRow
                })

                for r = 0, keyH - 1 do
                    for c = 0, keyW - 1 do
                        if gridMatrix[currentRow + r] then
                            gridMatrix[currentRow + r][currentCol + c] = true
                        end
                    end
                end
            end
            currentCol = currentCol + (keyData.width or 1)
        end
        currentRow = currentRow + 1
    end

    for _, renderData in ipairs(keyRenderList) do
        local keyData = renderData.keyData
        local gridX = renderData.gridX
        local gridY = renderData.gridY

        local keyW = keyData.width or 1
        local keyH = keyData.height or 1

        local xPos = (gridX - 1) * (keySize + spacing)
        local yPos = (gridY - 1) * (keySize + spacing)

        local keyWidth = (keyW * keySize) + ((keyW - 1) * spacing)
        local keyHeight = (keyH * keySize) + ((keyH - 1) * spacing)

        local keyBtn = KEYBIND.Menu:CreateKeyButton(panel, keyData.key, xPos, yPos, keyWidth, keyHeight, keyData)
        local fullKey = (keyData.prefix or "") .. keyData.key
        self.KeyButtons[fullKey] = keyBtn
    end
end

function KEYBIND.Renderer:ClearKeyboard()
    for _, btn in pairs(self.KeyButtons) do
        if IsValid(btn) then
            btn:Remove()
        end
    end
    self.KeyButtons = {}
    
    for _, panel in pairs(self.SectionPanels) do
        if IsValid(panel) then
            panel:Remove()
        end
    end
    self.SectionPanels = {}
end

function KEYBIND.Renderer:SetScale(scale)
    self.Scale = math.Clamp(scale, 0.5, 1.5)
    
    KEYBIND.Settings.Config.keyboardScale = self.Scale
    KEYBIND.Settings:SaveSettings()
end

function KEYBIND.Renderer:FixNumpadBottomRow()
    local zeroKey = self.KeyButtons["KP_0"]
    local dotKey = self.KeyButtons["KP_."]
    
    if IsValid(zeroKey) and IsValid(dotKey) then
        local zeroX, zeroY = zeroKey:GetPos()
        local zeroW = zeroKey:GetWide()
        local dotW = dotKey:GetWide()
        
        local settings = KEYBIND.Layout.Settings or { spacing = 7 }
        local spacing = settings.spacing * self.Scale
        
        dotKey:SetPos(zeroX + zeroW + spacing, zeroY)
        
        print("[BindMenu] Fixed numpad bottom row: Repositioned '.' key")
    else
        print("[BindMenu] Could not fix numpad bottom row: Keys not found")
    end
end

function KEYBIND.Renderer:SetLayout(layoutName)
    if KEYBIND.Layout and KEYBIND.Layout[layoutName] then
        self.CurrentLayout = layoutName
        
        KEYBIND.Settings.Config.keyboardLayout = layoutName
        KEYBIND.Settings:SaveSettings()
    else
        print("[BindMenu] ERROR: Cannot set layout '" .. tostring(layoutName) .. "' - layout not found!")
    end
end

function KEYBIND.Menu:EnableKeyboardNavigation()
    self.focusedKeyX = 1
    self.focusedKeyY = 1
    self.focusedSection = "main"
    
    hook.Remove("Think", "KEYBIND_MenuNavigation")
    
    hook.Add("Think", "KEYBIND_MenuNavigation", function()
        if not IsValid(self.Frame) or not self.Frame:IsVisible() then return end
        
        if vgui.GetKeyboardFocus() and vgui.GetKeyboardFocus():GetClassName() == "TextEntry" then
            return
        end
        
        if input.IsKeyDown(KEY_TAB) and not self.lastTabPress then
            self.lastTabPress = true
            local sections = {"main", "nav", "numpad"}
            local nextIndex = 1
            
            for i, section in ipairs(sections) do
                if section == self.focusedSection then
                    nextIndex = (i % #sections) + 1
                    break
                end
            end
            
            self.focusedSection = sections[nextIndex]
            self.focusedKeyX = 1
            self.focusedKeyY = 1
            self:UpdateKeyFocus()
        elseif not input.IsKeyDown(KEY_TAB) then
            self.lastTabPress = false
        end
        
        local moved = false
        
        if input.IsKeyDown(KEY_LEFT) and not self.lastLeftPress then
            self.lastLeftPress = true
            self.focusedKeyX = math.max(1, self.focusedKeyX - 1)
            moved = true
        elseif not input.IsKeyDown(KEY_LEFT) then
            self.lastLeftPress = false
        end
        
        if input.IsKeyDown(KEY_RIGHT) and not self.lastRightPress then
            self.lastRightPress = true
            self.focusedKeyX = math.min(self:GetMaxKeysInRow(self.focusedSection, self.focusedKeyY), self.focusedKeyX + 1)
            moved = true
        elseif not input.IsKeyDown(KEY_RIGHT) then
            self.lastRightPress = false
        end
        
        if input.IsKeyDown(KEY_UP) and not self.lastUpPress then
            self.lastUpPress = true
            self.focusedKeyY = math.max(1, self.focusedKeyY - 1)
            moved = true
        elseif not input.IsKeyDown(KEY_UP) then
            self.lastUpPress = false
        end
        
        if input.IsKeyDown(KEY_DOWN) and not self.lastDownPress then
            self.lastDownPress = true
            self.focusedKeyY = math.min(self:GetRowCount(self.focusedSection), self.focusedKeyY + 1)
            moved = true
        elseif not input.IsKeyDown(KEY_DOWN) then
            self.lastDownPress = false
        end
        
        if moved then
            self:UpdateKeyFocus()
        end
        
        if input.IsKeyDown(KEY_ENTER) and not self.lastEnterPress then
            self.lastEnterPress = true
            if self.focusedKeyButton and IsValid(self.focusedKeyButton) then
                self.focusedKeyButton:DoClick()
            end
        elseif not input.IsKeyDown(KEY_ENTER) then
            self.lastEnterPress = false
        end
    end)
end

function KEYBIND.Menu:GetMaxKeysInRow(sectionId, rowIndex)
    local layout = KEYBIND.Layout[KEYBIND.Renderer.CurrentLayout]
    if not layout or not layout.sections[sectionId] then return 1 end
    
    local section = layout.sections[sectionId]
    if not section.rows or not section.rows[rowIndex] then return 1 end
    
    return #section.rows[rowIndex]
end

function KEYBIND.Menu:GetRowCount(sectionId)
    local layout = KEYBIND.Layout[KEYBIND.Renderer.CurrentLayout]
    if not layout or not layout.sections[sectionId] then return 1 end
    
    local section = layout.sections[sectionId]
    return #section.rows
end

function KEYBIND.Menu:UpdateKeyFocus()
    if self.focusedKeyButton and IsValid(self.focusedKeyButton) then
        self.focusedKeyButton.isFocused = false
    end
    
    local layout = KEYBIND.Layout[KEYBIND.Renderer.CurrentLayout]
    if not layout or not layout.sections[self.focusedSection] then return end
    
    local section = layout.sections[self.focusedSection]
    if not section.rows or not section.rows[self.focusedKeyY] then return end
    
    local row = section.rows[self.focusedKeyY]
    if not row[self.focusedKeyX] then return end
    
    local keyData = row[self.focusedKeyX]
    if keyData.key == "" then return end
    
    local fullKey = (keyData.prefix or "") .. keyData.key
    local keyButton = KEYBIND.Renderer.KeyButtons[fullKey]
    
    if keyButton and IsValid(keyButton) then
        self.focusedKeyButton = keyButton
        keyButton.isFocused = true
    end
end

function KEYBIND.Menu:RefreshKeyboardLayout()
    if KEYBIND.Menu.refreshingKeyboard then
        return
    end
    
    KEYBIND.Menu.refreshingKeyboard = true
    
    if IsValid(self.Frame) then
        if KEYBIND.Renderer then
            KEYBIND.Renderer:ClearKeyboard()
        end
        
        local keyboardContainer = nil
        
        if self.tabContents and self.tabContents.keybinds then
            keyboardContainer = self.keyboardContainer
        else
            for _, child in pairs(self.Frame:GetChildren()) do
                if child:GetClassName() == "DPanel" and child:GetPos() == 50 and child:GetY() == 100 then
                    keyboardContainer = child
                    break
                end
            end
        end
        
        if keyboardContainer then
            keyboardContainer:Clear()
            
            if KEYBIND.Renderer and KEYBIND.Renderer.RenderKeyboard then
                KEYBIND.Renderer:RenderKeyboard(keyboardContainer, KEYBIND.Renderer.CurrentLayout or "StandardKeyboard")
            end
        else
            self.Frame:Remove()
            
            timer.Simple(0, function()
                self:Create()
            end)
        end
    end
    
    KEYBIND.Menu.refreshingKeyboard = false
end

function KEYBIND.Menu:CleanUp()
    hook.Remove("Think", "KEYBIND_MenuNavigation")
    
    KEYBIND.Renderer:ClearKeyboard()
    
    if IsValid(self.dropdownPanel) then
        self.dropdownPanel:Remove()
        self.dropdownPanel = nil
    end
    
    self.focusedKeyButton = nil
    self.focusedKeyX = 1
    self.focusedKeyY = 1
    self.focusedSection = "main"
    
    timer.Remove("KEYBIND_MenuRefresh")
    timer.Remove("KEYBIND_KeyboardAnimation")
    
    self.CachedMaterials = {}
    
    collectgarbage("collect")
end

function KEYBIND.Menu:CheckBindConflicts(key, command)
    local profile = KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile]
    if not profile or not profile.binds then return false end
    
    for boundKey, boundCommand in pairs(profile.binds) do
        if boundKey ~= key and boundCommand == command then
            return boundKey
        end
    end
    
    return false
end

function KEYBIND.Menu:OpenBindDialogWithTimer(key)
    print("[BindMenu] Opening bind dialog with timer for key: " .. key)
    
    timer.Simple(0.1, function()
        KEYBIND.Menu:OpenBindDialog(key)
    end)
end

function KEYBIND.Menu:OpenBindDialog(key)
    print("[BindMenu] OpenBindDialog called for key: " .. key)
    
    local theme = KEYBIND.Settings:GetTheme()
    local accentColor = KEYBIND.Settings.Config.accentColor or Color(60, 130, 200)
    
    local dialog = vgui.Create("DFrame")
    dialog:SetSize(400, 280)
    dialog:Center()
    dialog:SetTitle("")
    dialog:MakePopup()
    dialog:ShowCloseButton(false) 
    dialog:SetDraggable(true)
    
    if not _G["BindDialogFont"] then
        surface.CreateFont("BindDialogFont", {
            font = "Roboto",
            size = 16,
            weight = 500,
            antialias = true,
            shadow = false
        })
        _G["BindDialogFont"] = true
    end
    
    dialog:SetAlpha(0)
    dialog:AlphaTo(255, 0.2, 0)
    
    dialog.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0)
        draw.RoundedBox(10, 0, 0, w, h, theme.dialogBackground)
        
        draw.RoundedBoxEx(10, 0, 0, w, 40, accentColor, true, true, false, false)
        
        draw.SimpleText("Set Bind for Key: " .. key, "BindDialogFont", 15, 20, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Set Bind for Key: " .. key, "BindDialogFont", 14, 19, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
        local xcolor = hovered and Color(255, 255, 255) or Color(220, 220, 220)
        surface.SetDrawColor(xcolor)
        surface.DrawLine(padding, padding, w-padding, h-padding)
        surface.DrawLine(w-padding, padding, padding, h-padding)
    end
    closeBtn.DoClick = function() 
        dialog:AlphaTo(0, 0.2, 0, function() dialog:Remove() end)
        surface.PlaySound("buttons/button15.wav")
    end
    
    local textEntry = vgui.Create("DTextEntry", dialog)
    textEntry:SetPos(15, 55)
    textEntry:SetSize(dialog:GetWide() - 30, 36)
    textEntry:SetFont("BindDialogFont")
    textEntry:SetPlaceholderText("Enter command (e.g., say /advert raid!)")
    
    local profile = KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile]
    if profile and profile.binds and profile.binds[key] then
        textEntry:SetValue(profile.binds[key])
        textEntry:SelectAllText()
    end
    
    textEntry.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, theme.keyDefault)
        if self:HasFocus() then
            surface.SetDrawColor(accentColor)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
        end
        self:DrawTextEntryText(theme.text, accentColor, theme.text)
        if self:GetText() == "" then
            draw.SimpleText(self:GetPlaceholderText(), "BindDialogFont", 5, h/2, Color(150, 150, 150, 180), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
    
    textEntry.OnEnter = function()
        btnSet:DoClick()
    end
    
    local suggestionsTitle = vgui.Create("DLabel", dialog)
    suggestionsTitle:SetPos(15, 100)
    suggestionsTitle:SetFont("BindDialogFont")
    suggestionsTitle:SetText("Command Suggestions:")
    suggestionsTitle:SetColor(theme.text)
    suggestionsTitle:SizeToContents()

    local suggestionScroll = vgui.Create("DScrollPanel", dialog)
    suggestionScroll:SetPos(15, 125)
    suggestionScroll:SetSize(dialog:GetWide() - 30, 80)

    local suggestionList = vgui.Create("DIconLayout", suggestionScroll)
    suggestionList:Dock(FILL)
    suggestionList:SetSpaceX(5)
    suggestionList:SetSpaceY(5)

    local suggestions = {
        "say Hello everyone!",
        "say /advert Shop open!",
        "me is selling items",
        "advert Looking for buyers",
        "!goto admin",
        "!bring friend"
    }

    for _, suggestion in ipairs(suggestions) do
        local suggBtn = suggestionList:Add("DButton")
        suggBtn:SetSize(suggestionList:GetWide() - 10, 25)
        suggBtn:SetText("")
        
        suggBtn.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            local color = hovered and Color(accentColor.r, accentColor.g, accentColor.b, 150) or theme.keyDefault
            draw.RoundedBox(4, 0, 0, w, h, color)
            draw.SimpleText(suggestion, "DermaDefault", 10, h/2, theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        suggBtn.DoClick = function()
            textEntry:SetValue(suggestion)
            textEntry:RequestFocus()
            surface.PlaySound("buttons/button15.wav")
        end
        
        suggBtn:SetTooltip(suggestion)
    end

    local buttonContainer = vgui.Create("DPanel", dialog)
    buttonContainer:SetPos(15, dialog:GetTall() - 50) 
    buttonContainer:SetSize(dialog:GetWide() - 30, 36)
    buttonContainer:SetPaintBackground(false)
    
    local btnSet = vgui.Create("DButton", buttonContainer)
    btnSet:SetSize((buttonContainer:GetWide() - 10) * 0.7, 36)
    btnSet:Dock(LEFT)
    btnSet:SetText("")
    
    btnSet.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(accentColor.r + 20, accentColor.g + 20, accentColor.b + 20) or accentColor
        draw.RoundedBox(6, 0, 0, w, h, color)
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        draw.SimpleText("Set Bind", "BindDialogFont", w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Set Bind", "BindDialogFont", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    local btnRemove = vgui.Create("DButton", buttonContainer)
    btnRemove:SetSize((buttonContainer:GetWide() - 10) * 0.3, 36)
    btnRemove:Dock(RIGHT)
    btnRemove:SetText("")
    
    btnRemove.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(220, 70, 70) or Color(200, 60, 60)
        draw.RoundedBox(6, 0, 0, w, h, color)
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        draw.SimpleText("Remove", "BindDialogFont", w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Remove", "BindDialogFont", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    btnSet.DoClick = function()
        local command = textEntry:GetValue()
        if self:ValidateCommand(command, key) then
            local conflictKey = self:CheckBindConflicts(key, command)
            if conflictKey then
                Derma_Query(
                    "This command is already bound to key '" .. conflictKey .. "'.\nDo you want to replace it?",
                    "Bind Conflict",
                    "Replace", function()
                        KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile].binds[conflictKey] = nil
                        
                        KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile].binds[key] = command
                        KEYBIND.Storage:SaveBinds()
                        
                        if KEYBIND.Settings.Config.showFeedback then
                            chat.AddText(Color(0, 255, 0), "[BindMenu] Bind set for key " .. key)
                        end
                        
                        surface.PlaySound("buttons/button14.wav")
                        
                        dialog:AlphaTo(0, 0.2, 0, function()
                            dialog:Remove()
                            self:RefreshKeyboardLayout()
                        end)
                    end,
                    "Keep Both", function()
                        KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile].binds[key] = command
                        KEYBIND.Storage:SaveBinds()
                        
                        if KEYBIND.Settings.Config.showFeedback then
                            chat.AddText(Color(0, 255, 0), "[BindMenu] Bind set for key " .. key)
                        end
                        
                        surface.PlaySound("buttons/button14.wav")
                        
                        dialog:AlphaTo(0, 0.2, 0, function()
                            dialog:Remove()
                            self:RefreshKeyboardLayout()
                        end)
                    end,
                    "Cancel", function() end
                )
            else
                KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile].binds[key] = command
                KEYBIND.Storage:SaveBinds()
                
                if KEYBIND.Settings.Config.showFeedback then
                    chat.AddText(Color(0, 255, 0), "[BindMenu] Bind set for key " .. key)
                end
                
                surface.PlaySound("buttons/button14.wav")
                
                dialog:AlphaTo(0, 0.2, 0, function()
                    dialog:Remove()
                    self:RefreshKeyboardLayout()
                end)
            end
        else
            chat.AddText(Color(255, 0, 0), "[BindMenu] Use a valid command")
            
            local originalX = textEntry:GetX()
            local shakeAmount = 5
            local shakeDuration = 0.05
            local shakeCount = 3
            
            for i = 1, shakeCount do
                timer.Simple((i-1) * shakeDuration * 2, function()
                    if IsValid(textEntry) then
                        textEntry:MoveTo(originalX + shakeAmount, textEntry:GetY(), shakeDuration, 0, -1)
                    end
                end)
                
                timer.Simple((i-1) * shakeDuration * 2 + shakeDuration, function()
                    if IsValid(textEntry) then
                        textEntry:MoveTo(originalX - shakeAmount, textEntry:GetY(), shakeDuration, 0, -1)
                    end
                end)
            end
            
            timer.Simple(shakeCount * shakeDuration * 2, function()
                if IsValid(textEntry) then
                    textEntry:MoveTo(originalX, textEntry:GetY(), shakeDuration, 0, -1)
                end
            end)
            
            surface.PlaySound("buttons/button10.wav")
        end
    end

    btnRemove.DoClick = function()
        if profile and profile.binds and profile.binds[key] then
            KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile].binds[key] = nil
            KEYBIND.Storage:SaveBinds()
            
            if KEYBIND.Settings.Config.showFeedback then
                chat.AddText(Color(255, 80, 80), "[BindMenu] Removed bind for key " .. key)
            end
            
            surface.PlaySound("buttons/button14.wav")
            
            dialog:AlphaTo(0, 0.2, 0, function()
                dialog:Remove()
                self:RefreshKeyboardLayout()
            end)
        else
            chat.AddText(Color(255, 150, 0), "[BindMenu] No bind to remove for key " .. key)
            
            dialog:AlphaTo(0, 0.2, 0, function()
                dialog:Remove()
            end)
        end
    end
    
    textEntry:RequestFocus()
    
    dialog:MoveToFront()
    dialog:RequestFocus()
    
    dialog.OnKeyCodePressed = function(self, keyCode)
        if keyCode == KEY_ESCAPE then
            closeBtn:DoClick()
        end
    end
end

function KEYBIND.Menu:ValidateCommand(command, key)
    print("[BindMenu] Validating command: " .. command .. " for key: " .. key)
    
    if key == "KP_KP_ENTER" then
        key = "ENTER" 
    end

    if KEYBIND.Handler and KEYBIND.Handler.ValidateCommand then
        local result = KEYBIND.Handler:ValidateCommand(command)
        print("[BindMenu] Using Handler.ValidateCommand, result: " .. tostring(result))
        return result
    end
    
    local whitelistedCommands = KEYBIND.Config.WhitelistedCommands or {
        "say", "me", "advert", "!unbox", "!", "!goto", "!return", "!bring", "!tp"
    }
    
    for _, allowed in ipairs(whitelistedCommands) do
        if string.StartWith(command, allowed) then
            print("[BindMenu] Command validated using whitelist: " .. allowed)
            return true
        end
    end
    
    print("[BindMenu] Command validation failed")
    return false
end

function KEYBIND.Menu:RebuildMenu()
    -- Safety check
    if not self or not self.Create or not self.SwitchTab then
        print("[BindMenu] Error: Cannot rebuild menu - missing required methods")
        return
    end
    
    -- Remember which tab was active
    local activeTab = self.activeTab
    
    -- Remember the position of the menu
    local x, y
    if IsValid(self.Frame) then
        x, y = self.Frame:GetPos()
        self.Frame:Remove() -- Close the current menu
    end
    
    -- Wait a tiny bit to ensure everything is cleaned up
    timer.Simple(0.05, function()
        -- Safety check again (in case something changed during the timer)
        if not self or not self.Create then
            print("[BindMenu] Error: Cannot rebuild menu after timer - missing required methods")
            return
        end
        
        -- Reopen the menu
        self:Create()
        
        -- Restore position if we had one
        if x and y and IsValid(self.Frame) then
            self.Frame:SetPos(x, y)
        end
        
        -- Switch back to the active tab
        if activeTab and self.SwitchTab and IsValid(self.Frame) then
            self:SwitchTab(activeTab)
        end
    end)
end

function KEYBIND.RebuildUI()
    local wasMainMenuOpen = IsValid(KEYBIND.Menu.Frame)
    local wasSettingsOpen = IsValid(KEYBIND.Settings.Frame)
    local activeTabId = wasMainMenuOpen and KEYBIND.Menu.activeTab or nil

    -- Close any open BindMenu windows first
    if wasMainMenuOpen then
        KEYBIND.Menu.Frame:Remove()
    end
    if wasSettingsOpen then
        KEYBIND.Settings.Frame:Remove()
    end

    -- Use a timer to wait for the next frame. This is crucial to prevent VGUI errors.
    timer.Simple(0, function()
        -- If the main menu was open, recreate it
        if wasMainMenuOpen then
            KEYBIND.Menu:Create()
            -- If we were on a specific tab, switch back to it
            if activeTabId and IsValid(KEYBIND.Menu.Frame) then
                KEYBIND.Menu:SwitchTab(activeTabId)
            end
        end

        -- If the standalone settings window was open, recreate it
        if wasSettingsOpen then
            KEYBIND.Settings:Create()
        end
    end)
end

concommand.Add("bindmenu", function()
    KEYBIND.Menu:Create()
end)

net.Receive("KEYBIND_SelectProfile", function()  
    local selectedProfile = net.ReadString()

    if KEYBIND.Storage.Profiles[selectedProfile] then
        KEYBIND.Storage.CurrentProfile = selectedProfile
        KEYBIND.Storage:SaveBinds()
        KEYBIND.Menu:RefreshKeyboardLayout() 
    end
end)

hook.Add("InitPostEntity", "KEYBIND_InitLayout", function()
    timer.Simple(0.5, function()
        if not KEYBIND.Layout or not KEYBIND.Layout.StandardKeyboard then
            print("[BindMenu] ERROR: Keyboard layout not properly initialized!")
            
            include("bindmenu/cl_keybind_layout.lua")
            
            if not KEYBIND.Layout or not KEYBIND.Layout.StandardKeyboard then
                print("[BindMenu] ERROR: Failed to load keyboard layout after include attempt!")
                
                KEYBIND.Layout = KEYBIND.Layout or {}
                KEYBIND.Layout.Settings = KEYBIND.Layout.Settings or {
                    baseKeySize = 43,
                    spacing = 11,
                    padding = 35,
                    sectionSpacing = 45,
                    animationSpeed = 0.2,
                    roundness = 6
                }
                
                KEYBIND.Layout.StandardKeyboard = {
                    sections = {
                        main = {
                            id = "main",
                            name = "Main Keyboard",
                            position = { x = 35, y = 40 },
                            rows = {
                                {
                                    { key = "ESC", width = 1.2 },
                                    { key = "F1" },
                                    { key = "F2" }
                                },
                                {
                                    { key = "1", width = 1.1 },
                                    { key = "2", width = 1.1 },
                                    { key = "3", width = 1.1 }
                                }
                            }
                        }
                    }
                }
            end
        else
            print("[BindMenu] Keyboard layout initialized successfully")
        end
    end)
end)

hook.Add("InitPostEntity", "KEYBIND_Settings_Initialize", function()
    if KEYBIND and KEYBIND.Settings then
        KEYBIND.Settings:Initialize()
    end
end)

hook.Add("InitPostEntity", "KEYBIND_InitTheme", function()
    timer.Simple(0.5, function()
        if KEYBIND and KEYBIND.Settings and KEYBIND.Settings.InitializeTheme then
            KEYBIND.Settings:InitializeTheme()
            
            if KEYBIND and KEYBIND.Menu and KEYBIND.Menu.RefreshTheme and IsValid(KEYBIND.Menu.Frame) then
                KEYBIND.Menu:RefreshTheme()
            end
        end
    end)
end)

concommand.Add("bindmenu_testdialog", function()
    KEYBIND.Menu:OpenBindDialog("TEST")
end)

concommand.Add("bindmenu_checklayout", function()
    if KEYBIND.Layout then
        print("[BindMenu] KEYBIND.Layout exists")
        
        if KEYBIND.Layout.StandardKeyboard then
            print("[BindMenu] StandardKeyboard layout exists")
            
            if KEYBIND.Layout.StandardKeyboard.sections then
                print("[BindMenu] Sections table exists with " .. table.Count(KEYBIND.Layout.StandardKeyboard.sections) .. " sections")
                
                for id, section in pairs(KEYBIND.Layout.StandardKeyboard.sections) do
                    print("[BindMenu] Section: " .. id .. " with " .. #section.rows .. " rows")
                end
            else
                print("[BindMenu] Sections table is missing")
            end
        else
            print("[BindMenu] StandardKeyboard layout is missing")
        end
        
        if KEYBIND.Layout.Settings then
            print("[BindMenu] Layout settings exist")
            print("[BindMenu] roundness = " .. tostring(KEYBIND.Layout.Settings.roundness))
        else
            print("[BindMenu] Layout settings are missing")
        end
    else
        print("[BindMenu] KEYBIND.Layout is nil")
    end
end)

concommand.Add("bindmenu_opendialog", function(ply, cmd, args)
    local key = args[1] or "TEST"
    print("[BindMenu] Console command opening bind dialog for key: " .. key)
    KEYBIND.Menu:OpenBindDialog(key)
end)
