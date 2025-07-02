if SERVER then
    -- Send client files
    AddCSLuaFile("bindmenu/sh_init.lua")
    AddCSLuaFile("bindmenu/cl_keybind_storage.lua")
    AddCSLuaFile("bindmenu/cl_keybind_handler.lua")
    AddCSLuaFile("bindmenu/cl_keybind_settings.lua")
    AddCSLuaFile("bindmenu/cl_keybind_menu.lua")

    -- Include server files
    include("autorun/server/keybind_init.lua")
    include("autorun/server/keybind_net.lua")

    -- Resources
    resource.AddFile("materials/bindmenu/profile1.png")
    resource.AddFile("materials/bindmenu/profile2.png")
    resource.AddFile("materials/bindmenu/profile3.png")
    resource.AddFile("materials/bindmenu/settings.png")
    resource.AddFile("materials/bindmenu/diamond-green.png")
    resource.AddFile("materials/bindmenu/diamond-orange.png")
    resource.AddFile("materials/bindmenu/diamond-yellow.png")
    resource.AddFile("materials/bindmenu/diamond-blue.png")
end

if CLIENT then
    -- Load in correct order
    include("bindmenu/sh_init.lua")         -- Load shared stuff first
    include("bindmenu/cl_keybind_storage.lua")  -- Load storage before menu
    include("bindmenu/cl_keybind_handler.lua")
    include("bindmenu/cl_keybind_settings.lua")
    include("bindmenu/cl_keybind_menu.lua")  -- Load menu last
end
