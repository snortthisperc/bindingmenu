KEYBIND.Handler = KEYBIND.Handler or {}

KEYBIND.Handler.KeyStates = {}

KEYBIND.Handler.KeyCodeMap = {
    ["F1"] = KEY_F1,
    ["F2"] = KEY_F2,
    ["F3"] = KEY_F3,
    ["F4"] = KEY_F4,
    ["F5"] = KEY_F5,
    ["F6"] = KEY_F6,
    ["F7"] = KEY_F7,
    ["F8"] = KEY_F8,
    ["F9"] = KEY_F9,
    ["F10"] = KEY_F10,
    ["F11"] = KEY_F11,
    ["F12"] = KEY_F12,
    
    -- Navigation keys
    ["INS"] = KEY_INSERT,
    ["HOME"] = KEY_HOME,
    ["PGUP"] = KEY_PAGEUP,
    ["DEL"] = KEY_DELETE,
    ["END"] = KEY_END,
    ["PGDN"] = KEY_PAGEDOWN,
    
    -- Arrow keys
    ["←"] = KEY_LEFT,
    ["→"] = KEY_RIGHT,
    ["↑"] = KEY_UP,
    ["↓"] = KEY_DOWN,
    
    -- Numpad
    ["KP_0"] = KEY_PAD_0,
    ["KP_1"] = KEY_PAD_1,
    ["KP_2"] = KEY_PAD_2,
    ["KP_3"] = KEY_PAD_3,
    ["KP_4"] = KEY_PAD_4,
    ["KP_5"] = KEY_PAD_5,
    ["KP_6"] = KEY_PAD_6,
    ["KP_7"] = KEY_PAD_7,
    ["KP_8"] = KEY_PAD_8,
    ["KP_9"] = KEY_PAD_9,
    ["KP_/"] = KEY_PAD_DIVIDE,
    ["KP_*"] = KEY_PAD_MULTIPLY,
    ["KP_-"] = KEY_PAD_MINUS,
    ["KP_+"] = KEY_PAD_PLUS,
    ["KP_ENTER"] = KEY_PAD_ENTER,
    ["KP_."] = KEY_PAD_DECIMAL
}

function KEYBIND.Handler:Initialize()
    hook.Add("Think", "KEYBIND_KeyHandler", function()
        self:CheckKeys()
    end)
end

function KEYBIND.Handler:CheckKeys()
    local profile = KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile]
    if not profile then return end

    -- Check if chat or any menu is open
    if IsValid(g_SpawnMenu) and g_SpawnMenu:IsVisible() then return end 
    if IsValid(g_ContextMenu) and g_ContextMenu:IsVisible() then return end 
    if gui.IsConsoleVisible() then return end 
    if gui.IsGameUIVisible() then return end 
    if IsValid(LocalPlayer()) and LocalPlayer():IsTyping() then return end 
    if vgui.CursorVisible() then return end 

    local isCtrl = input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL)
    local isAlt = input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT)
    local isShift = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)

    for key, command in pairs(profile.binds) do
        local keyCode = self.KeyCodeMap[key] or input.GetKeyCode(key)
        if keyCode and input.IsKeyDown(keyCode) then
            if not self.KeyStates[key] then
                self.KeyStates[key] = true
                -- Additional check for any visible VGUI panels
                if not vgui.GetHoveredPanel() or vgui.GetHoveredPanel():GetClassName() == "CGModGameUIPanel" then
                    self:ExecuteCommand(command, {
                        ctrl = isCtrl,
                        alt = isAlt,
                        shift = isShift
                    })
                end
            end
        else
            self.KeyStates[key] = false
        end
    end
end

local allowedCommands = {
    "!unbox",
    "!",
    "!goto",
    "!return",
    "!bring",
    "!tp"
}

function KEYBIND.Handler:ExecuteCommand(command)
    -- Don't execute if any menu is open
    if IsValid(g_SpawnMenu) and g_SpawnMenu:IsVisible() then return end
    if IsValid(g_ContextMenu) and g_ContextMenu:IsVisible() then return end
    if gui.IsConsoleVisible() then return end
    if gui.IsGameUIVisible() then return end
    if IsValid(LocalPlayer()) and LocalPlayer():IsTyping() then return end
    if vgui.CursorVisible() then return end

    if string.StartWith(command, "say ") then
        LocalPlayer():ConCommand(command)
    elseif string.StartWith(command, "me ") then
        LocalPlayer():ConCommand("say /me " .. string.sub(command, 4))
    elseif string.StartWith(command, "advert ") then
        LocalPlayer():ConCommand("say /advert " .. string.sub(command, 8))
    elseif string.StartWith(command, "!") then
        local cmdBase = string.match(command, "^(!%w+)")
        if table.HasValue(allowedCommands, cmdBase) then
            LocalPlayer():ConCommand("say " .. command)
        end
    end
end

hook.Add("Initialize", "KEYBIND_Handler_Init", function()
    KEYBIND.Handler:Initialize()
end)
