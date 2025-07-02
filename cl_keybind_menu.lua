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
    startY = 40,
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
        startY = 40,
        keySize = 43,
        spacing = 9,
        rows = {
            {{"PRTSC", {width = 1.2, height = 1, prefix = "", isVertical = false}}, 
             {"SCRLK", {width = 1.2, height = 1, prefix = "", isVertical = false}}, 
             {"PAUSE", {width = 1.2, height = 1, prefix = "", isVertical = false}}},
            {{"INS", {width = 1.2, height = 1, prefix = "KP_", isVertical = false}}, 
             {"HOME", {width = 1.2, height = 1, prefix = "KP_", isVertical = false}}, 
             {"PGUP", {width = 1.2, height = 1, prefix = "KP_", isVertical = false}}},
            {{"DEL", {width = 1.2, height = 1, prefix = "KP_", isVertical = false}}, 
             {"END", {width = 1.2, height = 1, prefix = "KP_", isVertical = false}}, 
             {"PGDN", {width = 1.2, height = 1, prefix = "KP_", isVertical = false}}},
            {{"", {width = 1, height = 1, prefix = "", isVertical = false}}},
            {{"", {width = 1, height = 1, prefix = "", isVertical = false}}, 
             {"↑", {width = 1.2, height = 1, prefix = "KP_", isVertical = false}}, 
             {"", {width = 1.3, height = 1, prefix = "", isVertical = false}}},
            {{"←", {width = 1.3, height = 1, prefix = "KP_", isVertical = false}}, 
             {"↓", {width = 1.3, height = 1, prefix = "KP_", isVertical = false}}, 
             {"→", {width = 1.3, height = 1, prefix = "KP_", isVertical = false}}}
        }
    },
    
    numpadSection = {
        startX = 0, 
        startY = 40,
        keySize = 43,
        spacing = 11,
        rows = {
            {{"NMLK", {width = 1, height = 1, prefix = "KP_"}}, {"/", {width = 1, height = 1, prefix = "KP_"}}, {"*", {width = 1, height = 1, prefix = "KP_"}}, {"-", {width = 1, height = 1, prefix = "KP_"}}},
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
        print("[BindMenu] Failed to load icon for profile: " .. name)
        KEYBIND.Menu.ProfileIcons[name] = nil
    end
end

--[[ Default profile icon ]]--
KEYBIND.Menu.DefaultIcon = Material("icon16/user.png", "smooth")

local function SafeDrawGradient(material, x, y, w, h, color)
    if not material or material:IsError() then return end
    
    surface.SetDrawColor(color or Color(255, 255, 255, 10))
    surface.SetMaterial(material)
    surface.DrawTexturedRect(x, y, w, h)
end

function KEYBIND.Menu:CreateProfileSelector(parent)
    -- Create necessary fonts
    surface.CreateFont("KeybindDropdownTitle", {
        font = "Roboto",
        size = 16,
        weight = 700,
        antialias = true
    })
    
    surface.CreateFont("KeybindDropdownText", {
        font = "Roboto",
        size = 16,  -- Reduced from 18
        weight = 600,
        antialias = true
    })
    
    surface.CreateFont("KeybindDropdownSubtext", {
        font = "Roboto",
        size = 14,
        weight = 400,
        antialias = true
    })

    -- Create container panel
    local selector = vgui.Create("DPanel", parent)
    selector:Dock(FILL)
    selector:SetPaintBackground(false)
    
    -- Add title label
    local titleLabel = vgui.Create("DLabel", selector)
    titleLabel:SetPos(10, 5)  -- Positioned higher
    titleLabel:SetFont("KeybindDropdownTitle")
    titleLabel:SetText("ACTIVE PROFILE")
    titleLabel:SetTextColor(Color(150, 150, 150))
    titleLabel:SizeToContents()
    
    -- Get available profiles
    local profiles = {}
    local userGroup = LocalPlayer():GetUserGroup()
    local maxProfiles = 3
    
    if userGroup == "premium" then
        maxProfiles = 5
    elseif userGroup == "loyalty" then
        maxProfiles = 7
    end
    
    local baseProfiles = {
        {name = "Profile1", displayName = "Profile 1", icon = "Profile1", access = 0, color = Color(60, 130, 200)},
        {name = "Profile2", displayName = "Profile 2", icon = "Profile2", access = 0, color = Color(60, 130, 200)},
        {name = "Profile3", displayName = "Profile 3", icon = "Profile3", access = 0, color = Color(60, 130, 200)},
        {name = "Premium1", displayName = "Premium 4", icon = "Premium1", access = 1, color = Color(200, 130, 60)},
        {name = "Premium2", displayName = "Premium 5", icon = "Premium2", access = 1, color = Color(200, 130, 60)},
        {name = "Premium3", displayName = "Loyalty 6", icon = "Premium3", access = 2, color = Color(130, 200, 60)},
        {name = "Premium4", displayName = "Loyalty 7", icon = "Premium4", access = 2, color = Color(130, 200, 60)}
    }
    
    -- Populate available profiles
    for i, profileData in ipairs(baseProfiles) do
        -- Check access level
        local hasAccess = false
        if profileData.access == 0 then
            hasAccess = true
        elseif profileData.access == 1 then
            hasAccess = userGroup == "premium" or userGroup == "loyalty"
        elseif profileData.access == 2 then
            hasAccess = userGroup == "loyalty"
        end
        
        if hasAccess and i <= maxProfiles then
            if not KEYBIND.Storage.Profiles[profileData.name] then
                KEYBIND.Storage.Profiles[profileData.name] = {
                    binds = {},
                    name = profileData.name,
                    displayName = profileData.displayName
                }
            end
            
            local storedProfile = KEYBIND.Storage.Profiles[profileData.name]
            local displayName = storedProfile.displayName or profileData.displayName
            
            -- Count binds
            local bindCount = 0
            if storedProfile.binds then
                bindCount = table.Count(storedProfile.binds)
            end
            
            table.insert(profiles, {
                name = profileData.name,
                displayName = displayName,
                icon = profileData.icon,
                color = profileData.color,
                bindCount = bindCount
            })
        end
    end
    
    -- Find current profile
    local selectedProfile = nil
    for _, profile in ipairs(profiles) do
        if profile.name == KEYBIND.Storage.CurrentProfile then
            selectedProfile = profile
            break
        end
    end
    
    -- Calculate optimal width for dropdown
    local optionsButtonWidth = 40
    local optionsButtonMargin = 10
    local dropdownMargin = 10
    local dropdownWidth = parent:GetWide() - optionsButtonWidth - optionsButtonMargin - (dropdownMargin * 2)
    
    -- Create dropdown button with increased height
    local dropdownHeight = 45  -- Increased height for better text visibility
    local dropdownBtn = vgui.Create("DButton", selector)
    dropdownBtn:SetSize(dropdownWidth, dropdownHeight)
    dropdownBtn:SetPos(dropdownMargin, titleLabel:GetTall() + 8)  -- Adjusted position
    dropdownBtn:SetText("")
    
    -- Store dropdown state
    selector.dropdownOpen = false
    selector.selectedProfile = selectedProfile
    
    -- Custom paint function for the button with fixed positioning
    dropdownBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        
        -- Main dropdown box
        draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 45))
        
        -- Hover effect
        if hovered then
            draw.RoundedBox(8, 0, 0, w, h, Color(60, 130, 200, 30))
        end
        
        -- Selected profile display with fixed positioning
        if selector.selectedProfile then
            local profile = selector.selectedProfile
            local textX = 15
            
            -- Draw icon at fixed position
            local icon = KEYBIND.Menu.ProfileIcons[profile.icon]
            if icon then
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(icon)
                surface.DrawTexturedRect(textX, 8, 24, 24)  -- Fixed position near top
                textX = textX + 30
            end
            
            -- Calculate available width for text
            local availableTextWidth = w - textX - 80
            
            -- Draw profile name at fixed position
            local displayName = profile.displayName
            surface.SetFont("KeybindDropdownText")
            local textWidth = surface.GetTextSize(displayName)
            
            if textWidth > availableTextWidth then
                local ratio = availableTextWidth / textWidth
                local charCount = math.floor(#displayName * ratio) - 3
                displayName = string.sub(displayName, 1, charCount) .. "..."
            end
            
            -- Draw profile name on top line
            draw.SimpleText(displayName, "KeybindDropdownText", textX, 12, 
                Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            -- Draw bind count on bottom line
            local bindText = profile.bindCount .. " binds"
            draw.SimpleText(bindText, "KeybindDropdownSubtext", textX, 28, 
                Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            -- Draw arrow at fixed position
            local arrowSize = 8
            local arrowX = w - 20
            local arrowY = h / 2
            
            surface.SetDrawColor(230, 230, 230, 200)
            surface.DrawLine(arrowX - arrowSize, arrowY - arrowSize/2, arrowX, arrowY + arrowSize/2)
            surface.DrawLine(arrowX, arrowY + arrowSize/2, arrowX + arrowSize, arrowY - arrowSize/2)
        else
            -- Draw "Select a Profile" text at fixed position
            draw.SimpleText("Select a Profile", "KeybindDropdownText", 15, h/2 - 2, 
                Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
            -- Draw arrow
            local arrowSize = 8
            local arrowX = w - 20
            local arrowY = h / 2
            
            surface.SetDrawColor(230, 230, 230, 200)
            surface.DrawLine(arrowX - arrowSize, arrowY - arrowSize/2, arrowX, arrowY + arrowSize/2)
            surface.DrawLine(arrowX, arrowY + arrowSize/2, arrowX + arrowSize, arrowY - arrowSize/2)
        end
    end
    
    -- Create the actual dropdown as a separate panel
    local function CreateDropdownPanel()
        -- Remove existing dropdown if it exists
        if IsValid(selector.dropdownPanel) then
            selector.dropdownPanel:Remove()
        end
        
        -- Get position relative to screen
        local x, y = dropdownBtn:LocalToScreen(0, dropdownHeight)
        
        -- Create dropdown panel
        local dropdownPanel = vgui.Create("DPanel")
        dropdownPanel:SetSize(dropdownBtn:GetWide(), #profiles * dropdownHeight)
        dropdownPanel:SetPos(x, y)
        dropdownPanel:MakePopup()
        dropdownPanel:SetKeyboardInputEnabled(false) -- Don't steal keyboard focus
        dropdownPanel:SetZPos(32767) -- Ensure it's on top
        
        -- Store reference
        selector.dropdownPanel = dropdownPanel
        
        -- Custom paint function
        dropdownPanel.Paint = function(self, w, h)
            -- Draw dropdown list background
            draw.RoundedBoxEx(8, 0, 0, w, h, Color(45, 45, 50), false, false, true, true)
            
            -- Draw profile options
            for i, profile in ipairs(profiles) do
                local itemY = (i-1) * dropdownHeight
                
                -- Hover detection for each item
                local itemHovered = self:IsHovered() and self.mouseY and 
                                   self.mouseY > itemY and self.mouseY < itemY + dropdownHeight
                
                -- Item background
                if itemHovered then
                    draw.RoundedBox(0, 0, itemY, w, dropdownHeight, Color(60, 130, 200, 50))
                end
                
                -- Selected item indicator
                if profile.name == KEYBIND.Storage.CurrentProfile then
                    draw.RoundedBox(0, 0, itemY, 4, dropdownHeight, profile.color)
                end
                
                -- Draw icon at fixed position
                local icon = KEYBIND.Menu.ProfileIcons[profile.icon]
                if icon then
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(icon)
                    surface.DrawTexturedRect(15, itemY + 8, 24, 24)
                end
                
                -- Calculate available width for text
                local textX = 45
                local availableTextWidth = w - textX - 80
                
                -- Draw profile name with ellipsis if needed
                local displayName = profile.displayName
                surface.SetFont("KeybindDropdownText")
                local textWidth = surface.GetTextSize(displayName)
                
                if textWidth > availableTextWidth then
                    local ratio = availableTextWidth / textWidth
                    local charCount = math.floor(#displayName * ratio) - 3
                    displayName = string.sub(displayName, 1, charCount) .. "..."
                end
                
                -- Draw profile name on top line
                draw.SimpleText(displayName, "KeybindDropdownText", textX, itemY + 12, 
                    Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                -- Draw bind count on bottom line
                local bindText = profile.bindCount .. " binds"
                draw.SimpleText(bindText, "KeybindDropdownSubtext", textX, itemY + 28, 
                    Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                -- Add separator line except for last item
                if i < #profiles then
                    surface.SetDrawColor(60, 60, 65)
                    surface.DrawLine(0, itemY + dropdownHeight, w, itemY + dropdownHeight)
                end
            end
        end
        
        -- Track mouse position for hover effects
        dropdownPanel.OnCursorMoved = function(self, x, y)
            self.mouseY = y
        end
        
        -- Handle clicks
        dropdownPanel.OnMousePressed = function(self, mouseCode)
            if mouseCode == MOUSE_LEFT then
                local itemIndex = math.floor(self.mouseY / dropdownHeight) + 1
                
                if itemIndex >= 1 and itemIndex <= #profiles then
                    local profile = profiles[itemIndex]
                    
                    if profile.name ~= KEYBIND.Storage.CurrentProfile then
                        -- Select the profile
                        KEYBIND.Storage.CurrentProfile = profile.name
                        selector.selectedProfile = profile
                        KEYBIND.Storage:SaveBinds()
                        
                        net.Start("KEYBIND_SelectProfile")
                        net.WriteString(profile.name)
                        net.SendToServer()
                        
                        surface.PlaySound("buttons/button14.wav")
                        
                        KEYBIND.Menu:RefreshKeyboardLayout()
                    end
                end
                
                -- Close dropdown
                selector.dropdownOpen = false
                self:Remove()
            end
        end
        
        -- Close dropdown when clicking elsewhere
        dropdownPanel.Think = function(self)
            if not self:IsHovered() and input.IsMouseDown(MOUSE_LEFT) then
                selector.dropdownOpen = false
                self:Remove()
            end
        end
    end
    
    -- Toggle dropdown on button click
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
    
    -- Add options button
    local optionsBtn = vgui.Create("DButton", selector)
    optionsBtn:SetSize(optionsButtonWidth, 40)
    optionsBtn:SetPos(parent:GetWide() - optionsButtonWidth - optionsButtonMargin, titleLabel:GetTall() + 5)
    optionsBtn:SetText("")
    optionsBtn:SetTooltip("Profile Options")
    
    optionsBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(60, 130, 200, 200) or Color(50, 50, 55)
        
        draw.RoundedBox(8, 0, 0, w, h, color)
        
        -- Draw three dots
        local dotSize = 4
        local spacing = 8
        local startX = w/2 - spacing
        local y = h/2
        
        for i = 0, 2 do
            draw.RoundedBox(dotSize, startX + i * spacing, y - dotSize/2, dotSize, dotSize, Color(230, 230, 230))
        end
    end
    
    optionsBtn.DoClick = function()
        -- Close dropdown if open
        if selector.dropdownOpen and IsValid(selector.dropdownPanel) then
            selector.dropdownOpen = false
            selector.dropdownPanel:Remove()
        end
        
        local menu = DermaMenu()
        
        if selector.selectedProfile then
            menu:AddOption("Rename Profile", function()
                local profile = selector.selectedProfile
                
                Derma_StringRequest(
                    "Rename Profile",
                    "Enter new name for " .. profile.displayName,
                    profile.displayName,
                    function(newName)
                        KEYBIND.Storage:RenameProfile(profile.name, newName)
                        
                        -- Update the selected profile
                        profile.displayName = newName
                        
                        -- Refresh the menu
                        KEYBIND.Menu:RefreshKeyboardLayout()
                    end,
                    function() end,
                    "Confirm",
                    "Cancel"
                )
            end)
            
            menu:AddOption("Reset Profile Binds", function()
                local profile = selector.selectedProfile
                
                Derma_Query(
                    "Are you sure you want to reset all binds for " .. profile.displayName .. "?",
                    "Confirm Reset",
                    "Yes", function()
                        KEYBIND.Storage.Profiles[profile.name].binds = {}
                        KEYBIND.Storage:SaveBinds()
                        
                        -- Update bind count
                        profile.bindCount = 0
                        
                        -- Refresh the menu
                        KEYBIND.Menu:RefreshKeyboardLayout()
                        
                        if KEYBIND.Settings.Config.showFeedback then
                            chat.AddText(Color(0, 255, 0), "[BindMenu] Reset all binds for profile: " .. profile.displayName)
                        end
                    end,
                    "No", function() end
                )
            end)
            
            menu:AddSpacer()
        end
        
        menu:AddOption("Settings", function()
            KEYBIND.Settings:Create()
        end)
        
        menu:Open()
    end
    
    -- Clean up when parent is removed
    parent.OnRemove = function()
        if IsValid(selector.dropdownPanel) then
            selector.dropdownPanel:Remove()
        end
    end
    
    return selector
end

function KEYBIND.Settings:CreateProfilePictureSelector(parent, profileName)
    local storedProfile = KEYBIND.Storage.Profiles[profileName]
    if not storedProfile then return end
    
    -- Create container panel
    local container = vgui.Create("DPanel", parent)
    container:SetSize(parent:GetWide(), 240)
    container:Dock(TOP)
    container:DockMargin(0, 10, 0, 10)
    container:SetPaintBackground(false)
    
    -- Create title
    local title = vgui.Create("DLabel", container)
    title:SetText("Profile Picture")
    title:SetFont("KeybindSettingsText")
    title:SetTextColor(Color(230, 230, 230))
    title:SizeToContents()
    title:SetPos(10, 5)
    
    -- Get current icon
    local currentIcon = storedProfile.icon or "Profile1"
    
    -- Create icon grid
    local iconGrid = vgui.Create("DIconLayout", container)
    iconGrid:SetPos(10, 30)
    iconGrid:SetSize(container:GetWide() - 20, 200)
    iconGrid:SetSpaceX(10)
    iconGrid:SetSpaceY(10)
    
    -- Define available icons
    local availableIcons = {
        -- Standard icons
        {name = "Profile1", displayName = "Default 1", category = "Standard"},
        {name = "Profile2", displayName = "Default 2", category = "Standard"},
        {name = "Profile3", displayName = "Default 3", category = "Standard"},
        
        -- Premium icons
        {name = "Premium1", displayName = "Diamond Green", category = "Premium", access = 1},
        {name = "Premium2", displayName = "Diamond Blue", category = "Premium", access = 1},
        
        -- Loyalty icons
        {name = "Premium3", displayName = "Diamond Orange", category = "Loyalty", access = 2},
        {name = "Premium4", displayName = "Diamond Yellow", category = "Loyalty", access = 2}
    }
    
    -- Get user access level
    local userGroup = LocalPlayer():GetUserGroup()
    local accessLevel = 0
    
    if userGroup == "loyalty" then
        accessLevel = 2
    elseif userGroup == "premium" then
        accessLevel = 1
    end
    
    -- Track categories we've seen
    local categories = {}
    
    -- Add icons to grid
    for _, iconData in ipairs(availableIcons) do
        -- Check access level
        local hasAccess = true
        if iconData.access then
            hasAccess = accessLevel >= iconData.access
        end
        
        if hasAccess then
            -- Add category header if we haven't seen this category yet
            if not categories[iconData.category] then
                categories[iconData.category] = true
                
                local categoryPanel = iconGrid:Add("DPanel")
                categoryPanel:SetSize(iconGrid:GetWide() - 10, 30)
                categoryPanel:SetPaintBackground(false)
                
                local categoryLabel = vgui.Create("DLabel", categoryPanel)
                categoryLabel:SetText(iconData.category .. " Icons")
                categoryLabel:SetFont("KeybindSettingsText")
                categoryLabel:SetTextColor(Color(180, 180, 180))
                categoryLabel:SizeToContents()
                categoryLabel:SetPos(5, 5)
            end
            
            -- Create icon button
            local iconBtn = iconGrid:Add("DButton")
            iconBtn:SetSize(60, 60)
            iconBtn:SetText("")
            
            -- Get icon material
            local iconMat = KEYBIND.Menu.ProfileIcons[iconData.name]
            
            iconBtn.Paint = function(self, w, h)
                local isSelected = currentIcon == iconData.name
                local isHovered = self:IsHovered()
                
                -- Background
                local bgColor = isSelected and Color(60, 130, 200) or (isHovered and Color(50, 50, 55) or Color(40, 40, 45))
                draw.RoundedBox(8, 0, 0, w, h, bgColor)
                
                -- Icon
                if iconMat then
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(iconMat)
                    surface.DrawTexturedRect(w/2 - 20, h/2 - 20, 40, 40)
                else
                    -- Fallback if icon is missing
                    draw.SimpleText("?", "DermaLarge", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                
                -- Selection indicator
                if isSelected then
                    surface.SetDrawColor(255, 255, 255, 100)
                    surface.DrawOutlinedRect(0, 0, w, h, 2)
                end
            end
            
            -- Tooltip
            iconBtn:SetTooltip(iconData.displayName)
            
            -- Click handler
            iconBtn.DoClick = function()
                -- Update profile icon
                storedProfile.icon = iconData.name
                currentIcon = iconData.name
                
                -- Save to storage
                KEYBIND.Storage:SaveBinds()
                
                -- Play sound
                surface.PlaySound("buttons/button14.wav")
                
                -- Show feedback
                if KEYBIND.Settings.Config.showFeedback then
                    chat.AddText(Color(0, 255, 0), "[BindMenu] Profile picture updated")
                end
            end
        end
    end
    
    return container
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

    -- Create fonts for the menu
    surface.CreateFont("KeybindMenuTitle", {
        font = "Roboto",
        size = 24,
        weight = 600,
        antialias = true
    })
    
    surface.CreateFont("KeybindMenuSubtitle", {
        font = "Roboto",
        size = 18,
        weight = 500,
        antialias = true
    })

    -- Calculate responsive size
    local screenW, screenH = ScrW(), ScrH()
    local frameW = math.min(1485, screenW * 0.9)
    local frameH = math.min(550, screenH * 0.8)

    -- Create the main frame with modern styling
    self.Frame = vgui.Create("DFrame")
    self.Frame:SetSize(frameW, frameH)
    self.Frame:Center()
    self.Frame:SetTitle("")
    self.Frame:MakePopup()
    self.Frame:ShowCloseButton(false)
    self.Frame:SetDraggable(true)

    -- Modern dark theme with blur
    self.Frame.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0)
        
        -- Main background
        draw.RoundedBox(10, 0, 0, w, h, Color(20, 20, 25, 240))
        
        -- Top accent bar
        draw.RoundedBoxEx(10, 0, 0, w, 60, Color(40, 90, 140), true, true, false, false)
        
        -- Title with shadow
        draw.SimpleText("", "KeybindMenuTitle", 25, 30, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("", "KeybindMenuTitle", 24, 29, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Keyboard area background
        local kbX, kbY = 50, 70
        local kbW, kbH = w - 100, 400
        draw.RoundedBox(8, kbX, kbY, kbW, kbH, Color(30, 30, 35))
    end

    -- Modern close button
    local closeBtn = vgui.Create("DButton", self.Frame)
    closeBtn:SetSize(40, 40)
    closeBtn:SetPos(self.Frame:GetWide() - 50, 10)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(255, 80, 80, 200) or Color(255, 255, 255, 30)
        
        draw.RoundedBox(8, 0, 0, w, h, color)
        
        -- X icon
        local thickness = 2
        local padding = 14
        local color = hovered and Color(255, 255, 255) or Color(220, 220, 220)
        
        surface.SetDrawColor(color)
        surface.DrawLine(padding, padding, w-padding, h-padding)
        surface.DrawLine(w-padding, padding, padding, h-padding)
    end
    closeBtn.DoClick = function()
        self:CleanUp()
        self.Frame:Remove()
    end

    -- Settings button with modern styling
    local settingsBtn = vgui.Create("DButton", self.Frame)
    settingsBtn:SetSize(40, 40)
    settingsBtn:SetPos(self.Frame:GetWide() - 100, 10)
    settingsBtn:SetText("")
    
    local gear = Material("bindmenu/settings.png")
    
    settingsBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(60, 130, 200, 200) or Color(255, 255, 255, 30)
        
        draw.RoundedBox(8, 0, 0, w, h, color)
        
        if gear and !gear:IsError() then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(gear)
            surface.DrawTexturedRect(w/2-10, h/2-10, 20, 20)
        else
            -- Fallback if icon is missing
            draw.SimpleText("⚙", "KeybindMenuTitle", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    settingsBtn.DoClick = function()
        surface.PlaySound("buttons/button14.wav")
        KEYBIND.Settings:Create()
    end
    
    settingsBtn:SetTooltip("Open Settings")

    -- Create profile selector with modern styling
    local profileSelector = vgui.Create("DPanel", self.Frame)
    profileSelector:SetPos(50, 10)
    profileSelector:SetSize(self.Frame:GetWide() - 160, 40)
    profileSelector:SetPaintBackground(false)
    self:CreateProfileSelector(profileSelector)

    -- Create keyboard container (keep existing keyboard layout)
    local keyboardContainer = vgui.Create("DPanel", self.Frame)
    keyboardContainer:SetPos(50, 70)
    keyboardContainer:SetSize(self.Frame:GetWide() - 100, 400)
    keyboardContainer:SetPaintBackground(false)

    -- Render the keyboard (keep existing implementation)
    self:RenderCompleteKeyboard(keyboardContainer)
end

function KEYBIND.Menu:CreateKeyButton(parent, key, xPos, yPos, keyWidth, keyHeight, properties)
    local keyBtn = vgui.Create("DButton", parent)
    keyBtn:SetPos(xPos, yPos)
    keyBtn:SetSize(keyWidth, keyHeight)
    keyBtn:SetText("")  

    local hue = 0
    local roundness = 6 -- Increased roundness for modern look
    local fullKey = (properties and properties.prefix or "") .. key

    -- Create a font for the key text based on key size
    local fontSize = math.min(keyHeight, keyWidth) * 0.4
    local fontName = "KeybindKeyFont_" .. fontSize
    
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
        if profile then
            local bound = profile.binds[fullKey]
            local textColor = Color(230, 230, 230) -- Brighter text for better contrast

            if bound then
                -- Rainbow effect for bound keys
                hue = (hue + 0.5) % 360  
                local boundColor = HSVToColor(hue, 0.7, 0.9) -- Less saturated, brighter colors
                
                -- Key with shadow effect
                draw.RoundedBox(roundness, 2, 2, w-4, h-4, Color(0, 0, 0, 100))
                draw.RoundedBox(roundness, 0, 0, w, h, boundColor)
                
                -- Add subtle gradient
                surface.SetDrawColor(255, 255, 255, 30)
                surface.SetMaterial(Material("gui/gradient_up"))
                surface.DrawTexturedRect(0, 0, w, h)
                
                -- Add subtle inner border
                surface.SetDrawColor(255, 255, 255, 50)
                surface.DrawOutlinedRect(2, 2, w-4, h-4, 1)
                
                textColor = Color(255, 255, 255)
            else
                -- Unbounded key with modern styling
                local baseColor = self:IsHovered() and Color(50, 50, 55) or Color(40, 40, 45)
                
                -- Key with shadow effect
                draw.RoundedBox(roundness, 2, 2, w-4, h-4, Color(0, 0, 0, 50))
                draw.RoundedBox(roundness, 0, 0, w, h, baseColor)
                
                -- Add subtle highlight on hover
                if self:IsHovered() then
                    surface.SetDrawColor(255, 255, 255, 15)
                    surface.SetMaterial(Material("gui/gradient_up"))
                    surface.DrawTexturedRect(0, 0, w, h)
                    
                    -- Add subtle border on hover
                    surface.SetDrawColor(80, 150, 220, 100)
                    surface.DrawOutlinedRect(1, 1, w-2, h-2, 1)
                end
            end

            local keyText = key
            if properties and properties.prefix == "KP_" and key == "ENTER" then
                keyText = "ENTER"
            elseif key == "SPACE" then
                keyText = "SPACE"
            elseif #key > 5 then
                -- Abbreviate long key names
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
                -- Handle vertical text
                local textRotation = 90
                local centerX = w / 2
                local centerY = h / 2
                
                surface.SetFont(fontName)
                local tw, th = surface.GetTextSize(keyText)
                
                -- Draw shadow
                surface.SetTextColor(0, 0, 0, 100)
                surface.SetTextPos(centerX - tw/2 + 1, centerY - th/2 + 1)
                surface.DrawText(keyText)
                
                -- Draw text
                surface.SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)
                surface.SetTextPos(centerX - tw/2, centerY - th/2)
                surface.DrawText(keyText)
            else
                -- Draw text with shadow for depth
                draw.SimpleText(keyText, fontName, w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(keyText, fontName, w/2, h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                -- Add a small indicator dot for bound keys
                if bound then
                    local dotSize = 4
                    draw.RoundedBox(dotSize/2, w-dotSize-3, 3, dotSize, dotSize, Color(255, 255, 255, 200))
                end
            end
        else
            -- Error state
            draw.RoundedBox(roundness, 0, 0, w, h, Color(35, 35, 40))
            draw.SimpleText("X", fontName, w/2, h/2, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    keyBtn.OnCursorEntered = function(self) 
        local profile = KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile]
        if not profile then return end
        local bound = profile.binds[fullKey]
        
        if bound then
            self:SetTooltip("Bound to: " .. bound .. "\nClick to modify")
        else
            self:SetTooltip("Click to set bind")
        end
        
        surface.PlaySound("buttons/button15.wav")
    end

    keyBtn.DoClick = function()
        if not KEYBIND.Storage.CurrentProfile then
            print("Please select a profile before setting binds.")
            return
        end
        surface.PlaySound("buttons/button14.wav")
        self:OpenBindDialog(fullKey)
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
    -- Add a background panel for the keyboard with modern styling
    local keyboardBg = vgui.Create("DPanel", container)
    keyboardBg:Dock(FILL)
    keyboardBg.Paint = function(self, w, h)
        -- Subtle background for the keyboard area
        draw.RoundedBox(8, 0, 0, w, h, Color(25, 25, 30))
        
        -- Add subtle grid pattern
        surface.SetDrawColor(40, 40, 45, 50)
        for x = 0, w, 20 do
            surface.DrawLine(x, 0, x, h)
        end
        for y = 0, h, 20 do
            surface.DrawLine(0, y, w, y)
        end
    end
    
    local layout = self.CompleteKeyboardLayout
    local sectionSpacing = 45 
    
    local mainWidth = self:CalculateSectionWidth(layout.mainSection)
    
    layout.navSection.startX = layout.mainSection.startX + mainWidth + sectionSpacing
    
    local navWidth = self:CalculateSectionWidth(layout.navSection)
    
    layout.numpadSection.startX = layout.navSection.startX + navWidth + sectionSpacing

    -- Add section labels
    local mainLabel = vgui.Create("DLabel", container)
    mainLabel:SetPos(layout.mainSection.startX, layout.mainSection.startY - 25)
    mainLabel:SetFont("KeybindSettingsText")
    mainLabel:SetText("")
    mainLabel:SetTextColor(Color(150, 150, 150))
    mainLabel:SizeToContents()
    
    local navLabel = vgui.Create("DLabel", container)
    navLabel:SetPos(layout.navSection.startX, layout.navSection.startY - 25)
    navLabel:SetFont("KeybindSettingsText")
    navLabel:SetText("")
    navLabel:SetTextColor(Color(150, 150, 150))
    navLabel:SizeToContents()
    
    local numpadLabel = vgui.Create("DLabel", container)
    numpadLabel:SetPos(layout.numpadSection.startX, layout.numpadSection.startY - 25)
    numpadLabel:SetFont("KeybindSettingsText")
    numpadLabel:SetText("")
    numpadLabel:SetTextColor(Color(150, 150, 150))
    numpadLabel:SizeToContents()

    self:RenderKeyboardSection(container, layout.mainSection)
    self:RenderKeyboardSection(container, layout.navSection)
    self:RenderKeyboardSection(container, layout.numpadSection)
    
    -- Add a help text at the bottom
    local helpText = vgui.Create("DLabel", container)
    helpText:SetPos(layout.mainSection.startX, container:GetTall() - 25)
    helpText:SetFont("KeybindSettingsText")
    helpText:SetText("Click on any key to set or modify a bind.                                                                                                                  Profile selector at the top allows for you to have multiple binds set to 1 key and easily switch between them in an instance.")
    helpText:SetTextColor(Color(150, 150, 150))
    helpText:SizeToContents()
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
            end
            
            if key ~= "" then
                local keyWidth = keySize * properties.width
                local keyHeight = keySize * properties.height
                
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

function KEYBIND.Menu:CleanUp()
    if timer.Exists("KEYBIND_KeyHandler") then
        timer.Remove("KEYBIND_KeyHandler")
    end
    hook.Remove("Think", "KEYBIND_KeyHandler")
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
    local dialog = vgui.Create("DFrame")
    dialog:SetSize(350, 150)
    dialog:Center()
    dialog:SetTitle("")
    dialog:MakePopup()
    dialog:ShowCloseButton(false)
    dialog:SetDraggable(true)
    
    dialog.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0)
        
        -- Main background with rounded corners
        draw.RoundedBox(10, 0, 0, w, h, Color(20, 20, 25, 240))
        
        -- Header bar
        draw.RoundedBoxEx(10, 0, 0, w, 40, Color(200, 60, 60), true, true, false, false)
        
        -- Header text with shadow
        draw.SimpleText("Confirm Reset", "BindDialogFont", 15, 20, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Confirm Reset", "BindDialogFont", 14, 19, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Message
        draw.SimpleText("Are you sure you want to reset all binds", "BindDialogFont", w/2, 60, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("for this profile?", "BindDialogFont", w/2, 80, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Modern close button
    local closeBtn = vgui.Create("DButton", dialog)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(dialog:GetWide() - 40, 5)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(255, 80, 80, 200) or Color(255, 255, 255, 30)
        
        draw.RoundedBox(8, 0, 0, w, h, color)
        
        -- X icon
        local padding = 10
        local color = hovered and Color(255, 255, 255) or Color(220, 220, 220)
        
        surface.SetDrawColor(color)
        surface.DrawLine(padding, padding, w-padding, h-padding)
        surface.DrawLine(w-padding, padding, padding, h-padding)
    end
    closeBtn.DoClick = function() dialog:Remove() end
    
    -- Button container
    local buttonContainer = vgui.Create("DPanel", dialog)
    buttonContainer:SetPos(15, dialog:GetTall() - 50)
    buttonContainer:SetSize(dialog:GetWide() - 30, 36)
    buttonContainer:SetPaintBackground(false)
    
    -- Yes button
    local btnYes = vgui.Create("DButton", buttonContainer)
    btnYes:SetSize((buttonContainer:GetWide() - 10) * 0.5, 36)
    btnYes:Dock(LEFT)
    btnYes:SetText("")
    
    btnYes.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(220, 70, 70) or Color(200, 60, 60)
        
        draw.RoundedBox(6, 0, 0, w, h, color)
        
        -- Add subtle gradient
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        
        -- Text with shadow
        draw.SimpleText("Yes, Reset", "BindDialogFont", w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Yes, Reset", "BindDialogFont", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- No button
    local btnNo = vgui.Create("DButton", buttonContainer)
    btnNo:SetSize((buttonContainer:GetWide() - 10) * 0.5, 36)
    btnNo:Dock(RIGHT)
    btnNo:SetText("")
    
    btnNo.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(70, 70, 75) or Color(60, 60, 65)
        
        draw.RoundedBox(6, 0, 0, w, h, color)
        
        -- Add subtle gradient
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        
        -- Text with shadow
        draw.SimpleText("Cancel", "BindDialogFont", w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Cancel", "BindDialogFont", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    btnYes.DoClick = function()
        KEYBIND.Storage.Profiles[profile.name].binds = {}
        KEYBIND.Storage:SaveBinds()
        self:RefreshKeyboardLayout()
        dialog:Remove()
        
        if KEYBIND.Settings.Config.showFeedback then
            chat.AddText(Color(0, 255, 0), "[BindMenu] Reset all binds for profile: " .. profile.displayName)
        end
    end
    
    btnNo.DoClick = function()
        dialog:Remove()
    end
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
        
    SafeDrawGradient(gradient, 0, 0, w, h, Color(255, 255, 255, 10))
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
    dialog:SetDraggable(true)
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
        
        -- Main background with rounded corners
        draw.RoundedBox(10, 0, 0, w, h, Color(20, 20, 25, 240))
        
        -- Header bar
        draw.RoundedBoxEx(10, 0, 0, w, 40, Color(40, 90, 140), true, true, false, false)
        
        -- Header text with shadow
        draw.SimpleText("Set Bind for Key: " .. key, "BindDialogFont", 15, 20, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Set Bind for Key: " .. key, "BindDialogFont", 14, 19, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- Modern close button
    local closeBtn = vgui.Create("DButton", dialog)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(dialog:GetWide() - 40, 5)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(255, 80, 80, 200) or Color(255, 255, 255, 30)
        
        draw.RoundedBox(8, 0, 0, w, h, color)
        
        -- X icon
        local padding = 10
        local color = hovered and Color(255, 255, 255) or Color(220, 220, 220)
        
        surface.SetDrawColor(color)
        surface.DrawLine(padding, padding, w-padding, h-padding)
        surface.DrawLine(w-padding, padding, padding, h-padding)
    end
    closeBtn.DoClick = function() dialog:Remove() end
    
    -- Modern text entry
    local textEntry = vgui.Create("DTextEntry", dialog)
    textEntry:SetPos(15, 55)
    textEntry:SetSize(dialog:GetWide() - 30, 36)
    textEntry:SetFont("BindDialogFont")
    textEntry:SetPlaceholderText("Enter command (e.g., say /advert raid!)")
    
    textEntry.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 40))
        
        -- Add focus highlight
        if self:HasFocus() then
            surface.SetDrawColor(60, 130, 200)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
        end
        
        self:DrawTextEntryText(
            Color(230, 230, 230),
            Color(60, 130, 200),
            Color(230, 230, 230)
        )
        
        if self:GetText() == "" then
            draw.SimpleText(self:GetPlaceholderText(), "BindDialogFont", 5, h/2,
                Color(150, 150, 150, 180),
                TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Command list with modern styling
    local cmdList = vgui.Create("DPanel", dialog)
    cmdList:SetPos(15, 100)
    cmdList:SetSize(dialog:GetWide() - 30, 40)
    cmdList:SetPaintBackground(false)
    
    cmdList.Paint = function(self, w, h)
        draw.SimpleText("Possible Commands:", "BindDialogFont", 0, 0, Color(230, 230, 230))
        
        local y = 20
        local commands = {"say", "me", "advert", "!unbox", "!goto", "!return", "!bring", "!tp"}
        local commandText = table.concat(commands, "   •   ")
        
        draw.SimpleText(commandText, "BindDialogFont", 10, y, 
            Color(150, 150, 150, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- Button container
    local buttonContainer = vgui.Create("DPanel", dialog)
    buttonContainer:SetPos(15, dialog:GetTall() - 50)
    buttonContainer:SetSize(dialog:GetWide() - 30, 36)
    buttonContainer:SetPaintBackground(false)
    
    -- Set bind button
    local btnSet = vgui.Create("DButton", buttonContainer)
    btnSet:SetSize((buttonContainer:GetWide() - 10) * 0.7, 36)
    btnSet:Dock(LEFT)
    btnSet:SetText("")
    
    btnSet.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(70, 150, 220) or Color(60, 130, 200)
        
        draw.RoundedBox(6, 0, 0, w, h, color)
        
        -- Add subtle gradient
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        
        -- Text with shadow
        draw.SimpleText("Set Bind", "BindDialogFont", w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Set Bind", "BindDialogFont", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Remove bind button
    local btnRemove = vgui.Create("DButton", buttonContainer)
    btnRemove:SetSize((buttonContainer:GetWide() - 10) * 0.3, 36)
    btnRemove:Dock(RIGHT)
    btnRemove:SetText("")
    
    btnRemove.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and Color(220, 70, 70) or Color(200, 60, 60)
        
        draw.RoundedBox(6, 0, 0, w, h, color)
        
        -- Add subtle gradient
        surface.SetDrawColor(255, 255, 255, 15)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(0, 0, w, h)
        
        -- Text with shadow
        draw.SimpleText("Remove", "BindDialogFont", w/2+1, h/2+1, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Remove", "BindDialogFont", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
