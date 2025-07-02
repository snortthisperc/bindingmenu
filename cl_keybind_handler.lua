local DEBUG_KEYBINDS = true

local function DebugLog(...)
    if DEBUG_KEYBINDS then
        print("[KEYBIND DEBUG]", ...)
    end
end

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
    print("[BindMenu] Initializing key handler")
    
    -- Remove existing timer if it exists
    if timer.Exists("KEYBIND_KeyHandler") then
        timer.Remove("KEYBIND_KeyHandler")
        print("[BindMenu] Removed existing key handler timer")
    end
    
    -- Create a new timer
    timer.Create("KEYBIND_KeyHandler", 0.05, 0, function()
        self:CheckKeys()
    end)
    
    print("[BindMenu] Key handler initialized with timer")
    
    -- Also add a Think hook as backup
    hook.Add("Think", "KEYBIND_KeyHandlerBackup", function()
        if not timer.Exists("KEYBIND_KeyHandler") then
            print("[BindMenu] Key handler timer missing, recreating")
            timer.Create("KEYBIND_KeyHandler", 0.05, 0, function()
                self:CheckKeys()
            end)
        end
    end)
end

function KEYBIND.Handler:CheckKeys()
    local profile = KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile]
    if not profile then 
        DebugLog("No active profile found")
        return 
    end
    
    if not profile.binds then
        DebugLog("Profile has no binds table")
        return
    end

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

    -- Debug: Print all binds in current profile
    if input.IsKeyDown(KEY_F11) and not self.KeyStates["F11"] then
        self.KeyStates["F11"] = true
        DebugLog("Current profile binds:")
        for k, v in pairs(profile.binds) do
            DebugLog("  " .. k .. " -> " .. v)
        end
    elseif not input.IsKeyDown(KEY_F11) then
        self.KeyStates["F11"] = false
    end

    for key, command in pairs(profile.binds) do
        local keyCode = self.KeyCodeMap[key] or input.GetKeyCode(key)
        
        if keyCode then
            if input.IsKeyDown(keyCode) then
                if not self.KeyStates[key] then
                    DebugLog("Key pressed: " .. key .. " (code: " .. tostring(keyCode) .. ")")
                    self.KeyStates[key] = true
                    
                    -- Additional check for any visible VGUI panels
                    if not vgui.GetHoveredPanel() or vgui.GetHoveredPanel():GetClassName() == "CGModGameUIPanel" then
                        DebugLog("Executing command: " .. command)
                        self:ExecuteCommand(command, {
                            ctrl = isCtrl,
                            alt = isAlt,
                            shift = isShift
                        })
                    else
                        DebugLog("Not executing command because a panel is hovered: " .. 
                            (vgui.GetHoveredPanel() and vgui.GetHoveredPanel():GetClassName() or "unknown"))
                    end
                end
            else
                if self.KeyStates[key] then
                    DebugLog("Key released: " .. key)
                    self.KeyStates[key] = false
                end
            end
        else
            DebugLog("Warning: No keycode found for key: " .. key)
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

function KEYBIND.Handler:ExecuteCommand(command, modifiers)
    DebugLog("ExecuteCommand called with: " .. tostring(command))
    
    -- Don't execute if any menu is open
    if IsValid(g_SpawnMenu) and g_SpawnMenu:IsVisible() then 
        DebugLog("Not executing: Spawn menu is open")
        return 
    end
    if IsValid(g_ContextMenu) and g_ContextMenu:IsVisible() then 
        DebugLog("Not executing: Context menu is open")
        return 
    end
    if gui.IsConsoleVisible() then 
        DebugLog("Not executing: Console is visible")
        return 
    end
    if gui.IsGameUIVisible() then 
        DebugLog("Not executing: Game UI is visible")
        return 
    end
    if IsValid(LocalPlayer()) and LocalPlayer():IsTyping() then 
        DebugLog("Not executing: Player is typing")
        return 
    end
    if vgui.CursorVisible() then 
        DebugLog("Not executing: Cursor is visible")
        return 
    end

    -- Handle different command types
    if string.StartWith(command, "say ") then
        DebugLog("Executing say command via ConCommand")
        LocalPlayer():ConCommand(command)
        return true
    elseif string.StartWith(command, "me ") then
        DebugLog("Executing me command via ConCommand")
        LocalPlayer():ConCommand("say /me " .. string.sub(command, 4))
        return true
    elseif string.StartWith(command, "advert ") then
        DebugLog("Executing advert command via ConCommand")
        LocalPlayer():ConCommand("say /advert " .. string.sub(command, 8))
        return true
    elseif string.StartWith(command, "!") then
        DebugLog("Checking if ! command is allowed")
        local cmdBase = string.match(command, "^(!%w+)")
        local allowedCommands = {
            "!unbox",
            "!",
            "!goto",
            "!return",
            "!bring",
            "!tp"
        }
        
        if table.HasValue(allowedCommands, cmdBase) then
            DebugLog("Executing allowed ! command: " .. cmdBase)
            LocalPlayer():ConCommand("say " .. command)
            return true
        else
            DebugLog("Command not in allowed list: " .. tostring(cmdBase))
        end
    else
        DebugLog("Command doesn't match any known pattern: " .. command)
    end
    
    DebugLog("Command not executed: " .. command)
    return false
end

hook.Add("Initialize", "KEYBIND_Handler_Init", function()
    KEYBIND.Handler:Initialize()
end)

function KEYBIND.Handler:TestBind(key, command)
    print("[BindMenu] Testing bind: " .. key .. " -> " .. command)
    self:ExecuteCommand(command)
end

-- Add a console command to test binds
concommand.Add("bindmenu_keytest", function()
    print("[BindMenu] Press any key to test...")
    
    hook.Add("Think", "KEYBIND_KeyTest", function()
        for i = 1, KEY_COUNT do
            if input.IsKeyDown(i) then
                print("[BindMenu] Key pressed: " .. input.GetKeyName(i) .. " (code: " .. i .. ")")
                hook.Remove("Think", "KEYBIND_KeyTest")
                break
            end
        end
    end)
    
    timer.Create("KEYBIND_KeyTestTimeout", 5, 1, function()
        hook.Remove("Think", "KEYBIND_KeyTest")
        print("[BindMenu] Key test timed out")
    end)
end)

concommand.Add("bindmenu_dump", function()
    local profile = KEYBIND.Storage.Profiles[KEYBIND.Storage.CurrentProfile]
    if not profile then
        print("[BindMenu] No active profile")
        return
    end
    
    print("[BindMenu] Current profile: " .. KEYBIND.Storage.CurrentProfile)
    print("[BindMenu] Binds:")
    
    if not profile.binds then
        print("  No binds defined")
        return
    end
    
    for key, command in pairs(profile.binds) do
        local keyCode = KEYBIND.Handler.KeyCodeMap[key] or input.GetKeyCode(key)
        print("  " .. key .. " (code: " .. tostring(keyCode) .. ") -> " .. command)
    end
end)

function KEYBIND.Handler:VerifyKeyCodeMap()
    print("[BindMenu] Verifying key code map...")
    
    -- Test a few key codes
    local testKeys = {"F1", "F2", "A", "B", "1", "2", "KP_1", "KP_2"}
    
    for _, key in ipairs(testKeys) do
        local keyCode = self.KeyCodeMap[key] or input.GetKeyCode(key)
        print("  " .. key .. " -> " .. tostring(keyCode))
    end
    
    -- Print all entries in the key code map
    print("[BindMenu] Full key code map:")
    for key, code in pairs(self.KeyCodeMap) do
        print("  " .. key .. " -> " .. tostring(code))
    end
end

-- Call this during initialization
hook.Add("InitPostEntity", "KEYBIND_VerifyKeyCodeMap", function()
    timer.Simple(2, function()
        KEYBIND.Handler:VerifyKeyCodeMap()
    end)
end)
