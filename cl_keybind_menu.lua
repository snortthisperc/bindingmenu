--[[                                          __cl_keybind_menu.lua__ 
    *
    Majority of this file can go untouched, unless you'd like to alter the keypad or binding system yourself.

    Currently, due to the Garry's Mod safety precautions, you cannot use ConCommands from an Addon to set binds.
    So I created my own system to create binds using KeyPress logic. These binds will save to a data file inside of the clients garrysmod/data/bindmenu folder.
    They can persist beyond server restart/map change.
    *
                                                                                                                                                                ]]--
KEYBIND = KEYBIND or {}
KEYBIND.Menu = KEYBIND.Menu or {}

--[[                              __Keyboard layout definition__

    *
    {{"KEY", {width = 1, height = 1, isVertical = false, prefix = ""}}}, -- Possible properties
    {{"KEY2", 2}}, -- EzProperties
    {{"KEY3", {width = 1, height = 1, isVertical = false, prefix = "KP_"}}} -- Keypad properties
    *

                                                                                                ]]--
KEYBIND.Menu.CompleteKeyboardLayout = {
mainSection = {
    startX = 35,
    startY = 80,
    keySize = 43,
    spacing = 11,
    rows = {
        {{"ESC", 1.2}, {"", 5}, {"F1", 1}, {"F2", 1}, {"F3", 1}, {"F4", 1}, {"", 5}, 
         {"F5", 1}, {"F6", 1}, {"F7", 1}, {"F8", 1}, {"", 5}, 
         {"F9", 1}, {"F10", 1}, {"F11", 1}, {"F12", 1}},

        {{"`", .9}, {"1", 1.1}, {"2", 1.1}, {"3", 1.1}, {"4", 1.1}, {"5", 1.1}, {"6", 1.1}, 
         {"7", 1.1}, {"8", 1.1}, {"9", 1.1}, {"0", 1.1}, {"-", .9}, {"=", .9}, 
         {"BACKSPACE", 3}},

        {{"TAB", 1.3}, {"Q", 1.2}, {"W", 1.2}, {"E", 1.2}, {"R", 1.2}, {"T", 1.2}, 
         {"Y", 1.2}, {"U", 1.2}, {"I", 1.2}, {"O", 1.2}, {"P", 1.2}, {"[", 1.1}, 
         {"]", 1.15}, {"\\", 1.15}},

        {{"CAPS", 1.75}, {"A", 1.1}, {"S", 1.1}, {"D", 1.1}, {"F", 1.1}, {"G", 1.1}, 
         {"H", 1.1}, {"J", 1.1}, {"K", 1.1}, {"L", 1.1}, {";", 1.2}, {"'", 1.2}, 
         {"ENTER", 2.9}},

        {{"SHIFT", 2.25}, {"Z", 1.3}, {"X", 1.3}, {"C", 1.3}, {"V", 1.3}, {"B", 1.3}, 
         {"N", 1.3}, {"M", 1.3}, {",", 1.2}, {".", 1.2}, {"/", 1.2}, {"SHIFT", 2.25}},

        {{"CTRL", 1.5}, {"WIN", 1.25}, {"ALT", 1.25}, {"SPACE", 9}, {"ALT", 1.25}, 
         {"WIN", 1.25}, {"MENU", 1.25}, {"CTRL", 1.45}}
    }
},
    
    navSection = {
        startX = 0, 
        startY = 80,
        keySize = 43,
        spacing = 5,
        rows = {
            {{"PRTSC", {width = 1, height = 1, prefix = "", isVertical = false}}, 
             {"SCRLK", {width = 1, height = 1, prefix = "", isVertical = false}}, 
             {"PAUSE", {width = 1, height = 1, prefix = "", isVertical = false}}},
            {{"INS", {width = 1, height = 1, prefix = "KP_", isVertical = false}}, 
             {"HOME", {width = 1, height = 1, prefix = "KP_", isVertical = false}}, 
             {"PGUP", {width = 1, height = 1, prefix = "KP_", isVertical = false}}},
            {{"DEL", {width = 1, height = 1, prefix = "KP_", isVertical = false}}, 
             {"END", {width = 1, height = 1, prefix = "KP_", isVertical = false}}, 
             {"PGDN", {width = 1, height = 1, prefix = "KP_", isVertical = false}}},
            {{"", {width = 1, height = 1, prefix = "", isVertical = false}}},
            {{"", {width = 1, height = 1, prefix = "", isVertical = false}}, 
             {"↑", {width = 1, height = 1, prefix = "KP_", isVertical = false}}, 
             {"", {width = 1, height = 1, prefix = "", isVertical = false}}},
            {{"←", {width = 1, height = 1, prefix = "KP_", isVertical = false}}, 
             {"↓", {width = 1, height = 1, prefix = "KP_", isVertical = false}}, 
             {"→", {width = 1, height = 1, prefix = "KP_", isVertical = false}}}
        }
    },
    
    numpadSection = {
        startX = 0, 
        startY = 80,
        keySize = 43,
        spacing = 11,
        rows = {
            {{"NUMLK", {width = 1, height = 1, prefix = "KP_"}}, {"/", {width = 1, height = 1, prefix = "KP_"}}, {"*", {width = 1, height = 1, prefix = "KP_"}}, {"-", {width = 1, height = 1, prefix = "KP_"}}},
            {{"7", {width = 1, height = 1, prefix = "KP_"}}, {"8", {width = 1, height = 1, prefix = "KP_"}}, {"9", {width = 1, height = 1, prefix = "KP_"}}, {"+", {width = 1, height = 2, prefix = "KP_"}}}, 
            {{"4", {width = 1, height = 1, prefix = "KP_"}}, {"5", {width = 1, height = 1, prefix = "KP_"}}, {"6", {width = 1, height = 1, prefix = "KP_"}}},
            {{"1", {width = 1, height = 1, prefix = "KP_"}}, {"2", {width = 1, height = 1, prefix = "KP_"}}, {"3", {width = 1, height = 1, prefix = "KP_"}}, {"ENTER", {width = 1, height = 2, isVertical = true, prefix = "KP_"}}}, 
            {{"0", {width = 2.27, height = 1, prefix = "KP_"}}, {".", {width = 1, height = 1, prefix = "KP_"}}}
        }
    }
}

--[[            Profile icons
    To add your own profile icons, upload the .png file to materials/bindmenu folder and change the location below

    materials/bindmenu/my_custom_img.png
]]--

KEYBIND.Menu.ProfileIcons = {
    Profile1 = Material("materials/bindmenu/profile1.png", "smooth"),
    Profile2 = Material("materials/bindmenu/profile2.png", "smooth"),
    Profile3 = Material("materials/bindmenu/profile3.png", "smooth"),
    Premium1 = Material("materials/bindmenu/diamond-green.png", "smooth"),
    Premium2 = Material("materials/bindmenu/diamond-blue.png", "smooth"),
    Premium3 = Material("materials/bindmenu/diamond-orange.png", "smooth"),
    Premium4 = Material("materials/bindmenu/diamond-yellow.png", "smooth")
}

for name, mat in pairs(KEYBIND.Menu.ProfileIcons) do
    if not mat or mat:IsError() then
        print("[KEYBIND] Failed to load icon for profile: " .. name)
        KEYBIND.Menu.ProfileIcons[name] = nil
    end
end

--[[ Default profile icon ]]--
KEYBIND.Menu.DefaultIcon = Material("icon16/user.png", "smooth")

function KEYBIND.Menu:CreateProfileSelector(parent)
    surface.CreateFont("KeybindProfileFont", {
        font = "Roboto",
        size = 16,
        weight = 600,
        antialias = true
    })

    local selector = vgui.Create("DPanel", parent)
    selector:Dock(FILL)
    selector:SetPaintBackground(false)

    local maxProfiles = 3
    local userGroup = LocalPlayer():GetUserGroup()
    
    if userGroup == "premium" then
        maxProfiles = 5
    elseif userGroup == "loyalty" then
        maxProfiles = 7
    end

    local baseProfiles = {
        {name = "Profile1", displayName = "Profile 1", icon = "Profile1", access = 0}, -- 0 = Default User rank
        {name = "Profile2", displayName = "Profile 2", icon = "Profile2", access = 0},
        {name = "Profile3", displayName = "Profile 3", icon = "Profile3", access = 0},
        {name = "Premium1", displayName = "Premium 4", icon = "Premium1", access = 1}, -- 1 = Premium
        {name = "Premium2", displayName = "Premium 5", icon = "Premium2", access = 1},
        {name = "Premium3", displayName = "Loyalty 6", icon = "Premium3", access = 2}, -- 2 = Loyalty
        {name = "Premium4", displayName = "Loyalty 7", icon = "Premium4", access = 2}
    }

    local spacing = 8
    local sideMargin = 10
    local buttonCount = maxProfiles
    local availableWidth = parent:GetWide() - (2 * sideMargin) - ((buttonCount - 1) * spacing)
    local buttonWidth = math.floor(availableWidth / buttonCount)
    buttonWidth = math.max(buttonWidth, 120)

    local visibleButtons = 0

    for i, profileData in ipairs(baseProfiles) do
        -- Check access level
        local hasAccess = false
        if profileData.access == 0 then -- User rank
            hasAccess = true
        elseif profileData.access == 1 then -- Premium rank
            hasAccess = userGroup == "premium" or userGroup == "loyalty"
        elseif profileData.access == 2 then -- Loyalty rank
            hasAccess = userGroup == "loyalty"
        end

        if hasAccess and visibleButtons < maxProfiles then
            visibleButtons = visibleButtons + 1
            
            if not KEYBIND.Storage.Profiles[profileData.name] then
                KEYBIND.Storage.Profiles[profileData.name] = {
                    binds = {},
                    name = profileData.name,
                    displayName = profileData.displayName
                }
            end

            local btn = vgui.Create("DButton", selector)
            btn:SetSize(buttonWidth, parent:GetTall() - 8)
            btn:SetPos(sideMargin + (visibleButtons - 1) * (buttonWidth + spacing), 4)
            btn:SetText("")

            btn.profileData = profileData

            btn.Paint = function(self, w, h)
                local storedProfile = KEYBIND.Storage.Profiles[self.profileData.name]
                local displayName = storedProfile and (storedProfile.displayName or storedProfile.name) or self.profileData.displayName
                
                local isSelected = KEYBIND.Storage.CurrentProfile == self.profileData.name
                local baseColor = isSelected and KEYBIND.Colors.profileSelected or KEYBIND.Colors.profileUnselected
                
                local bgColor = self:IsHovered() and Color(
                    math.min(baseColor.r + 20, 255),
                    math.min(baseColor.g + 20, 255),
                    math.min(baseColor.b + 20, 255)
                ) or baseColor
                
                draw.RoundedBox(6, 0, 0, w, h, bgColor)
                
                local iconSize = h * 0.6
                local iconX = 8
                local iconY = (h - iconSize) / 2
                
                local icon = KEYBIND.Menu.ProfileIcons[self.profileData.icon] or KEYBIND.Menu.DefaultIcon
                if icon then
                    surface.SetDrawColor(255, 255, 255, isSelected and 255 or 200)
                    surface.SetMaterial(icon)
                    surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)
                end
                
                local textX = iconX + iconSize + 8
                local textY = h/2
                local textColor = isSelected and Color(255, 255, 255) or Color(220, 220, 220)
                
                draw.SimpleText(displayName, "KeybindProfileFont", textX + 1, textY + 1, 
                    Color(0, 0, 0, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                draw.SimpleText(displayName, "KeybindProfileFont", textX, textY, 
                    textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            btn.DoClick = function(self)
                KEYBIND.Storage.CurrentProfile = self.profileData.name
                KEYBIND.Storage:SaveBinds()
                
                net.Start("KEYBIND_SelectProfile")
                net.WriteString(self.profileData.name)
                net.SendToServer()
                
                surface.PlaySound("buttons/button14.wav")
                
                KEYBIND.Menu:RefreshKeyboardLayout()
            end

            btn.DoRightClick = function(self)
                local menu = DermaMenu()
                menu:AddOption("Rename Profile", function()
                    Derma_StringRequest(
                        "Rename Profile",
                        "Enter new name for " .. self.profileData.displayName,
                        self.profileData.displayName,
                        function(newName)
                            KEYBIND.Storage:RenameProfile(self.profileData.name, newName)
                        end,
                        function() end,
                        "Confirm",
                        "Cancel"
                    )
                end)
                menu:AddOption("Reset Binds", function()
                    KEYBIND.Menu:ResetProfileBinds(self.profileData)
                end)
                menu:Open()
            end

            btn:SetTooltip("Left-click to select\nRight-click for options")
        end
    end

    return selector
end


function KEYBIND.Menu:Create()
    if not KEYBIND or not KEYBIND.Colors then return end
    if not (KEYBIND.Storage and KEYBIND.Storage.CurrentProfile and KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile]) then
        print("Please select a valid profile.")
        return
    end

    if IsValid(self.Frame) then
        self.Frame:Remove()
    end

    self.Frame = vgui.Create("DFrame")
    self.Frame:SetSize(1485, 550)
    self.Frame:Center()
    self.Frame:SetTitle("")
    self.Frame:MakePopup()
    self.Frame:ShowCloseButton(false)
    self.Frame:SetDraggable(false)

    self.Frame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, KEYBIND.Colors.background)
        
        local kbX, kbY = 50, 80  
        local kbW, kbH = w - 100, 400 
        draw.RoundedBox(4, kbX, kbY, kbW, kbH, KEYBIND.Colors.sectionBackground)
    end

    local profileSelector = vgui.Create("DPanel", self.Frame)
    profileSelector:SetPos(50, 20)  
    profileSelector:SetSize(self.Frame:GetWide() - 100, 40)  
    profileSelector:SetPaintBackground(false)
    self:CreateProfileSelector(profileSelector)

    local startX = 50
    local startY = 80
    local sectionSpacing = 5
    local keyboardContainer = vgui.Create("DPanel", self.Frame)
    keyboardContainer:SetPos(50, 80)
    keyboardContainer:SetSize(self.Frame:GetWide() - 100, 400)
    keyboardContainer:SetPaintBackground(false)

    self:RenderCompleteKeyboard(keyboardContainer)

    local closeBtn = vgui.Create("DButton", self.Frame)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(self.Frame:GetWide() - 40, 10)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(255, 80, 80) or Color(200, 60, 60))
        draw.SimpleText("✕", "DermaLarge", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        self.Frame:Remove()
    end

    local settingsBtn = vgui.Create("DButton", self.Frame)
    settingsBtn:SetSize(30, 30)  
    settingsBtn:SetPos(self.Frame:GetWide() - 40, 45)  
    settingsBtn:SetText("")

    local gear = Material("bindmenu/settings.png")

    settingsBtn.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and KEYBIND.Colors.keyHover or KEYBIND.Colors.keyDefault)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(gear)
        surface.DrawTexturedRect(w/2-8, h/2-8, 16, 16)
    end

    settingsBtn.DoClick = function()
        surface.PlaySound("buttons/button14.wav")
        KEYBIND.Settings:Create()
    end

    settingsBtn:SetTooltip("Open Settings")
end

function KEYBIND.Menu:CreateKeyButton(parent, key, xPos, yPos, keyWidth, keyHeight, properties)
    local keyBtn = vgui.Create("DButton", parent)
    keyBtn:SetPos(xPos, yPos)
    keyBtn:SetSize(keyWidth, keyHeight)
    keyBtn:SetText("")  

    local hue = 0
    local roundness = 4

    keyBtn.Paint = function(self, w, h)
        local profile = KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile]
        if profile then
            local bound = profile.binds[(properties.prefix or "") .. key]
            local textColor = KEYBIND.Colors.text 

            if bound then
                hue = (hue + 1) % 360  
                local boundColor = HSVToColor(hue, 1, 1)
                draw.RoundedBox(roundness, 0, 0, w, h, boundColor)
                textColor = Color(255, 255, 255)  
            else
                draw.RoundedBox(roundness, 0, 0, w, h, self:IsHovered() and KEYBIND.Colors.keyHover or KEYBIND.Colors.keyDefault)
            end

            local keyText = (properties and properties.prefix == "KP_" and key == "KP_ENTER") and "ENTER" or key

            if properties and properties.isVertical then
                surface.SetFont("DermaDefault")
                local tw, th = surface.GetTextSize(keyText)
                local tx = w / 2 - th / 2
                local ty = h / 2 - tw / 2
                surface.SetTextColor(textColor)
                surface.SetTextPos(tx, ty)
                surface.DrawText(keyText)
            else
                draw.SimpleText(keyText, "DermaDefault", w/2, h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        else
            draw.RoundedBox(roundness, 0, 0, w, h, KEYBIND.Colors.keyDefault)
            draw.SimpleText("X", "DermaDefault", w/2, h/2, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end



    keyBtn.OnCursorEntered = function(self) 
        local profile = KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile]
        if not profile then return end
        local bound = profile.binds[(properties.prefix or "") .. key]
        self:SetTooltip(bound and "Bound to: " .. bound .. "\nClick to modify" or "Click to set bind")
        surface.PlaySound("buttons/button15.wav")
    end


    keyBtn.DoClick = function()
        if not KEYBIND.Storage.CurrentProfile then
            print("Please select a profile before setting binds.")
            return
        end
        surface.PlaySound("buttons/button14.wav")
        self:OpenBindDialog((properties.prefix or "") .. key)
    end

    return keyBtn
end

function KEYBIND.Menu:CalculateSectionWidth(section)
    local maxWidth = 0
    local keySize = section.keySize
    local spacing = section.spacing
    
    for _, row in ipairs(section.rows) do
        local rowWidth = 0
        
        for _, key in ipairs(row) do
            if key ~= "" then
                local keyWidth = keySize
                
                if section.specialKeys and section.specialKeys[key] and section.specialKeys[key].width then
                    keyWidth = keySize * section.specialKeys[key].width
                end
                
                rowWidth = rowWidth + keyWidth + spacing
            else
                rowWidth = rowWidth + keySize + spacing
            end
        end
        
        maxWidth = math.max(maxWidth, rowWidth)
    end
    
    return maxWidth - spacing
end

function KEYBIND.Menu:RenderCompleteKeyboard(container)
    local layout = self.CompleteKeyboardLayout
    local sectionSpacing = 45 
    
    local mainWidth = self:CalculateSectionWidth(layout.mainSection)
    
    layout.navSection.startX = layout.mainSection.startX + mainWidth + sectionSpacing
    
    local navWidth = self:CalculateSectionWidth(layout.navSection)
    
    layout.numpadSection.startX = layout.navSection.startX + navWidth + sectionSpacing

    self:RenderKeyboardSection(container, layout.mainSection)
    self:RenderKeyboardSection(container, layout.navSection)
    self:RenderKeyboardSection(container, layout.numpadSection)
end

function KEYBIND.Menu:RenderKeyboardSection(container, section)
    local xPos = section.startX
    local yPos = section.startY
    local keySize = section.keySize
    local spacing = section.spacing
    local heightMap = {} 
    
    for rowIndex, row in ipairs(section.rows) do
        local currentX = xPos
        
        for colIndex, keyData in ipairs(row) do
            local key = keyData[1]
            local properties
            
            if type(keyData[2]) == "table" then
                properties = keyData[2]
            elseif type(keyData[2]) == "number" then
                properties = {
                    width = keyData[2],
                    height = 1,
                    isVertical = false,
                    prefix = ""
                }
            else
                properties = {
                    width = 1,
                    height = 1,
                    isVertical = false,
                    prefix = ""
                }
                print("Warning: Unknown keyData[2] type for key '" .. key .. "'. Using default properties.")
            end
            
            if key ~= "" then
                local keyWidth = keySize * properties.width
                local keyHeight = keySize * properties.height
                
                if properties and properties.prefix == "KP_" and key == "KP_ENTER" then
                    keyText = "ENTER"
                end

                if properties.isVertical then
                    keyWidth, keyHeight = keyHeight, keyWidth
                end
                
                if not heightMap[colIndex] or heightMap[colIndex].remainingHeight <= 0 then
                    local keyBtn = self:CreateKeyButton(container, key, currentX, yPos, keyWidth, keyHeight, properties)
                    
                    if properties.height > 1 then
                        heightMap[colIndex] = {
                            remainingHeight = properties.height - 1,
                            width = properties.width,
                            isVertical = properties.isVertical
                        }
                    end
                    
                    currentX = currentX + keyWidth + spacing
                else
                    heightMap[colIndex].remainingHeight = heightMap[colIndex].remainingHeight - 1
                    
                    if heightMap[colIndex].isVertical then
                        currentX = currentX + (keySize * heightMap[colIndex].width) + spacing
                    else
                        currentX = currentX + (keySize * heightMap[colIndex].width) + spacing
                    end
                end
            else
                currentX = currentX + keySize + spacing
            end
        end
        
        if #heightMap > 0 then
            local maxRemainingHeight = 0
            for _, heightInfo in pairs(heightMap) do
                if heightInfo.remainingHeight > maxRemainingHeight then
                    maxRemainingHeight = heightInfo.remainingHeight
                end
            end
            yPos = yPos + (keySize * (maxRemainingHeight + 1)) + spacing
            heightMap = {} 
        else
            yPos = yPos + keySize + spacing
        end
    end
end


            function KEYBIND.Menu:GetAvailableProfiles()
                local profiles = {}
                local maxProfiles = 3
                local userGroup = LocalPlayer():GetUserGroup()
                
                if userGroup == "premium" then
                    maxProfiles = 5
                elseif userGroup == "loyalty" then
                    maxProfiles = 7
                end

                    local baseProfiles = {
                        {name = "Profile 1", icon = "Profile1"},
                        {name = "Profile 2", icon = "Profile2"},
                        {name = "Profile 3", icon = "Profile3"},
                        {name = "Premium 1", icon = "Premium1"},
                        {name = "Premium 2", icon = "Premium2"},
                        {name = "Premium 3", icon = "Premium3"},
                        {name = "Premium 4", icon = "Premium4"}
                    }

                for i = 1, maxProfiles do
                    if baseProfiles[i] then
                        if not KEYBIND.Storage.Profiles[baseProfiles[i].name] then
                            KEYBIND.Storage.Profiles[baseProfiles[i].name] = {
                                binds = {},
                                name = baseProfiles[i].name
                            }
                        end
                        table.insert(profiles, {
                            name = KEYBIND.Storage.Profiles[baseProfiles[i].name].name or baseProfiles[i].name,
                            icon = baseProfiles[i].icon
                        })
                    end
                end

    return profiles
end

function KEYBIND.Menu:OpenRenameDialog(profile)
    local dialog = vgui.Create("DFrame")
    dialog:SetSize(300, 120)
    dialog:Center()
    dialog:SetTitle("Rename Profile")
    dialog:MakePopup()

    local textEntry = vgui.Create("DTextEntry", dialog)
    textEntry:SetPos(10, 30)
    textEntry:SetSize(280, 30)
    textEntry:SetValue(profile.name)
    textEntry:SelectAllText()

    local saveBtn = vgui.Create("DButton", dialog)
    saveBtn:SetPos(10, 70)
    saveBtn:SetSize(280, 30)
    saveBtn:SetText("Save")
    saveBtn.DoClick = function()
        local newName = textEntry:GetValue()
        if newName ~= "" then
            KEYBIND.Storage:RenameProfile(profile.name, newName)
            dialog:Close()
        end
    end
end

function KEYBIND.Menu:ResetProfileBinds(profile)
    Derma_Query(
        "Are you sure you want to reset all binds for this profile?",
        "Confirm Reset",
        "Yes",
        function()
            KEYBIND.Storage.Profiles[profile.name].binds = {}
            KEYBIND.Storage:SaveBinds()
            self:RefreshKeyboardLayout()
        end,
        "No"
    )
end

function KEYBIND.Menu:CreateKeyboardLayout(parent)
    local keyboard = parent
    local keySize = 50
    local spacing = 5
    local startX = 20
    local startY = 20

    keyboard.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, KEYBIND.Colors.background)
    end

   local keyboardWidth = 0
    for _, keys in pairs(self.KeyboardLayout) do
        local rowWidth = 0
        for _, keyGroup in pairs(keys) do
            for _, key in pairs(keyGroup) do
                rowWidth = rowWidth + self:GetKeyWidth(key, keySize) + spacing
            end
        end
        keyboardWidth = math.max(keyboardWidth, rowWidth - spacing)
    end

    parent:SetWide(keyboardWidth) 

    for row, keys in ipairs(self.KeyboardLayout) do
        local yPos = startY + (row - 1) * (keySize + spacing)
        local xPos = startX

        for _, keyGroup in ipairs(keys) do
            for _, key in ipairs(keyGroup) do
                local keyWidth = self:GetKeyWidth(key, keySize)

                local keyBtn = self:CreateKeyButton(keyboard, key, xPos, yPos, keyWidth, keySize)

                xPos = xPos + keyWidth + spacing
            end
        end
    end

    local keyboardHeight = #self.KeyboardLayout * (keySize + spacing) - spacing
    parent:SetTall(keyboardHeight) 
end

function KEYBIND.Menu:CreateNavigationCluster(parent)
    local navKeys = {
        {
            {key = "INS", width = 1},
            {key = "HOME", width = 1},
            {key = "PGUP", width = 1}
        },
        {
            {key = "DEL", width = 1},
            {key = "END", width = 1},
            {key = "PGDN", width = 1}
        },
        {
            {key = "", width = 1},
            {key = "↑", width = 1},
            {key = "", width = 1}
        },
        {
            {key = "←", width = 1},
            {key = "↓", width = 1},
            {key = "→", width = 1}
        }
    }

    local keySize = 45 
    local spacing = 3  
    local startX = 5  
    local startY = 10

    local bottomRowY = parent:GetTall() - keySize - 10

    for rowIndex, row in ipairs(navKeys) do
        local yPos
        if rowIndex <= 2 then
            yPos = startY + (rowIndex - 1) * (keySize + spacing)
        else
            yPos = bottomRowY - (4 - rowIndex) * (keySize + spacing)
        end

        local xPos = startX
        for _, keyData in ipairs(row) do
            if keyData.key ~= "" then
                local keyWidth = keySize * keyData.width
                local keyBtn = self:CreateKeyButton(parent, keyData.key, xPos, yPos, keyWidth, keySize)
                xPos = xPos + keyWidth + spacing
            else
                xPos = xPos + keySize + spacing
            end
        end
    end
end

function KEYBIND.Menu:CreateNumpad(parent)
    local numpadKeys = {
        {
            {key = "NUM", width = 1},
            {key = "/", width = 1},
            {key = "*", width = 1},
            {key = "-", width = 1}
        },
        {
            {key = "7", width = 1},
            {key = "8", width = 1},
            {key = "9", width = 1},
            {key = "+", width = 1, height = 2}
        },
        {
            {key = "4", width = 1},
            {key = "5", width = 1},
            {key = "6", width = 1}
        },
        {
            {key = "1", width = 1},
            {key = "2", width = 1},
            {key = "3", width = 1},
            {key = "ENTER", width = 1, height = 2}
        },
        {
            {key = "0", width = 2},
            {key = ".", width = 1}
        }
    }

    local keySize = 45  
    local spacing = 3   
    local startX = 5    
    local startY = 10

    local heightMap = {}
    local xPos = startX
    
    for rowIndex, row in ipairs(numpadKeys) do
        local yPos = startY + (rowIndex - 1) * (keySize + spacing)
        
        xPos = startX
        
        for colIndex, keyData in ipairs(row) do
            if not heightMap[colIndex] or heightMap[colIndex].remainingHeight <= 0 then
                local keyWidth = keySize * (keyData.width or 1)
                local keyHeight = keySize * (keyData.height or 1)
                
                local keyBtn = self:CreateKeyButton(parent, keyData.key, xPos, yPos, keyWidth, keyHeight, "KP_")
                
                if keyData.height and keyData.height > 1 then
                    heightMap[colIndex] = {
                        remainingHeight = keyData.height - 1,
                        width = keyData.width or 1
                    }
                end
                
                xPos = xPos + keyWidth + spacing
            else
                heightMap[colIndex].remainingHeight = heightMap[colIndex].remainingHeight - 1
                xPos = xPos + (keySize * heightMap[colIndex].width) + spacing
            end
        end
    end
end

function KEYBIND.Menu:CreateSettingsButton()
    local settingsBtn = vgui.Create("DButton", self.Frame)
    settingsBtn:SetSize(30, 30)
    settingsBtn:SetPos(self.Frame:GetWide() - 75, 10)  
    settingsBtn:SetText("")  
    settingsBtn:SetFont("KeybindProfileFont") 
    
    local gear = Material("bindmenu/settings.png")
    
    settingsBtn.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and KEYBIND.Colors.keyHover or KEYBIND.Colors.keyDefault)
        
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(gear)
        surface.DrawTexturedRect(w/2-8, h/2-8, 16, 16)
    end
    
    settingsBtn.DoClick = function()
        surface.PlaySound("buttons/button14.wav")
        KEYBIND.Settings:Create()
    end
    
    settingsBtn:SetTooltip("Open Settings")
end

function KEYBIND.Menu:OpenBindDialog(key)
    local dialog = vgui.Create("DFrame")
    dialog:SetSize(400, 180)
    dialog:Center()
    dialog:SetTitle("")
    dialog:MakePopup()
    dialog:ShowCloseButton(false)
    dialog:SetDraggable(false)
    dialog:SetPaintShadow(true)  
    dialog:DockPadding(5, 5, 5, 5)  

        surface.CreateFont("BindDialogFont", {
        font = "Roboto",
        size = 16,
        weight = 500,
        antialias = true,
        shadow = false
    })
    
dialog.Paint = function(self, w, h)

    Derma_DrawBackgroundBlur(self, 0)
    
    draw.RoundedBox(8, 0, 0, w, h, KEYBIND.Colors.background)
    
    render.SetScissorRect(0, 0, w, h, true)
    local gradient = Material("gui/gradient_up")
    surface.SetDrawColor(255, 255, 255, 10)
    surface.SetMaterial(gradient)
    surface.DrawTexturedRect(0, 0, w, h)
    render.SetScissorRect(0, 0, w, h, false)
    
    draw.RoundedBoxEx(8, 0, 0, w, 30, KEYBIND.Colors.sectionHeader, true, true, false, false)
    
    draw.RoundedBox(8, 0, 0, w, h, KEYBIND.Colors.border)
    draw.RoundedBox(8, 1, 1, w-2, h-2, KEYBIND.Colors.background)
    
    draw.SimpleText("Set Bind for key: " .. key, "BindDialogFont", 10, 15, 
        KEYBIND.Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

    
    local closeBtn = vgui.Create("DButton", dialog)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(dialog:GetWide() - 35, 0)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local color = self:IsHovered() and Color(255, 80, 80) or Color(200, 60, 60)
        draw.SimpleText("✕", "BindDialogFont", w/2, h/2, color, 
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function() dialog:Remove() end
    
    local textEntry = vgui.Create("DTextEntry", dialog)
    textEntry:SetPos(10, 40)
    textEntry:SetSize(dialog:GetWide() - 20, 30)
    textEntry:SetFont("BindDialogFont")
    textEntry:SetPlaceholderText("Enter command (e.g., say /advert raid!)")
    
    textEntry.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, KEYBIND.Colors.keyDefault)
        self:DrawTextEntryText(
            KEYBIND.Colors.text,
            KEYBIND.Colors.accent,
            KEYBIND.Colors.text
        )
        
        if self:GetText() == "" then
            draw.SimpleText(self:GetPlaceholderText(), "BindDialogFont", 5, h/2,
                Color(KEYBIND.Colors.text.r, KEYBIND.Colors.text.g, KEYBIND.Colors.text.b, 100),
                TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
    
    local cmdList = vgui.Create("DPanel", dialog)
    cmdList:SetPos(10, 80)
    cmdList:SetSize(dialog:GetWide() - 20, 50)
    cmdList.Paint = function(self, w, h)
        draw.SimpleText("Possible Commands:", "BindDialogFont", 0, 0, KEYBIND.Colors.text)
        local y = 20
        for _, cmd in ipairs(KEYBIND.Config.WhitelistedCommands) do
            draw.SimpleText("• " .. cmd, "BindDialogFont", 10, y, 
                Color(KEYBIND.Colors.text.r, KEYBIND.Colors.text.g, KEYBIND.Colors.text.b, 200))
            y = y + 15
        end
    end

    local buttonContainer = vgui.Create("DPanel", dialog)
    buttonContainer:SetPos(10, dialog:GetTall() - 40)
    buttonContainer:SetSize(dialog:GetWide() - 20, 30)
    buttonContainer:SetPaintBackground(false)
    
    local btnSet = vgui.Create("DButton", buttonContainer)
    btnSet:SetSize((buttonContainer:GetWide() - 10) * 0.7, 30)
    btnSet:Dock(LEFT)
    btnSet:SetText("")
    
    btnSet.Paint = function(self, w, h)
        local baseColor = self:IsHovered() and KEYBIND.Colors.accent or KEYBIND.Colors.keyDefault
        draw.RoundedBox(6, 0, 0, w, h, baseColor)
        
        surface.SetDrawColor(255, 255, 255, 20)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        
        draw.SimpleText("Set Bind", "BindDialogFont", w/2, h/2,
            KEYBIND.Colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    local btnRemove = vgui.Create("DButton", buttonContainer)
    btnRemove:SetSize((buttonContainer:GetWide() - 10) * 0.3, 30)
    btnRemove:Dock(RIGHT)
    btnRemove:SetText("")
    
    btnRemove.Paint = function(self, w, h)
        local baseColor = self:IsHovered() and Color(200, 60, 60) or Color(170, 50, 50)
        draw.RoundedBox(6, 0, 0, w, h, baseColor)
        
        surface.SetDrawColor(255, 255, 255, 20)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        
        draw.SimpleText("Remove", "BindDialogFont", w/2, h/2,
            KEYBIND.Colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    btnSet.DoClick = function()
        local command = textEntry:GetValue()
        if self:ValidateCommand(command, key) then
            KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile].binds[key] = command
            KEYBIND.Storage:SaveBinds()
            
            if KEYBIND.Settings.Config.showFeedback then
                chat.AddText(Color(0, 255, 0), "[BindMenu] Bind set for key " .. key)
            end
            
            dialog:Remove()
            self:RefreshKeyboardLayout()
        else
            chat.AddText(Color(255, 0, 0), "[BindMenu] Use a valid command")
        end
    end

    btnRemove.DoClick = function()
        KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile].binds[key] = nil
        KEYBIND.Storage:SaveBinds()
        
        if KEYBIND.Settings.Config.showFeedback then
            chat.AddText(Color(255, 80, 80), "[BindMenu] Removed bind for key " .. key)
        end
        
        dialog:Remove()
        self:RefreshKeyboardLayout()
    end
end

function KEYBIND.Menu:ValidateCommand(command, key)
    if key == "KP_KP_ENTER" then
        key = "ENTER" 
    end

    for _, allowed in ipairs(KEYBIND.Config.WhitelistedCommands) do
        if string.StartWith(command, allowed) then
            return true
        end
    end
    return false
end

function KEYBIND.Menu:RefreshKeyboardLayout()
    if IsValid(self.Frame) then
        self.Frame:Remove()
        self:Create()
    end
end

function KEYBIND.Menu:GetKeyWidth(key, baseSize)
    local widths = {
        ["BACKSPACE"] = 2,
        ["TAB"] = 1.5,
        ["CAPS"] = 1.75,
        ["ENTER"] = 2.25,
        ["SHIFT"] = 2.5,
        ["SPACE"] = 6.25,
        ["CTRL"] = 1.5,
        ["WIN"] = 1.25,
        ["ALT"] = 1.25,
        ["MENU"] = 1.25
    }
    
    return (widths[key] or 1) * baseSize
end

function KEYBIND.Menu:AddFadeAnimation(panel)
    panel:SetAlpha(0)
    panel:AlphaTo(255, 0.2, 0)
end

concommand.Add("editbinds", function()
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

hook.Add("InitPostEntity", "KEYBIND_Initialize", function()
    timer.Simple(1, function()
        if not KEYBIND.Storage.CurrentProfile then
            KEYBIND.Storage.CurrentProfile = "Profile 1"
        end
        
        if not KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile] then
            KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile] = {
                binds = {}
            }
        end
        
        KEYBIND.Menu:Create()
    end)
end)