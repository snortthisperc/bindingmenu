net.Receive("KEYBIND_SelectProfile", function(len, ply)
    if not IsValid(ply) then
        print("[KEYBIND] Error: Invalid player in KEYBIND_SelectProfile net message")
        return
    end
    
    local selectedProfile = net.ReadString()
    if selectedProfile and selectedProfile ~= "" then
        -- Store the current profile for this player
        if not KEYBIND.PlayerProfiles then
            KEYBIND.PlayerProfiles = {}
        end
        KEYBIND.PlayerProfiles[ply:SteamID()] = selectedProfile
        
        -- Run the hook with proper player validation
        hook.Run("KEYBIND_ProfileSelected", ply, selectedProfile)

        -- Send confirmation back to client
        net.Start("KEYBIND_SelectedProfile")
        net.WriteString(selectedProfile)
        net.Send(ply)
        
        print("[KEYBIND] Player " .. ply:Nick() .. " selected profile: " .. selectedProfile)
    else
        print("[KEYBIND] Error: Empty profile name received from player " .. ply:Nick())
    end
end)
