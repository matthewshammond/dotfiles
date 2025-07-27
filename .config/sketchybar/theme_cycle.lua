#!/usr/bin/env lua

-- Standalone theme cycling script
-- Usage: lua theme_cycle.lua [next|prev|theme_name]

-- Add the current directory to the package path
local config_dir = os.getenv("CONFIG_DIR") or "."
package.path = package.path .. ";" .. config_dir .. "/?.lua"

local theme_system = require("themes")
local ThemeManager = theme_system.manager

-- State file to persist current theme index
local state_file = config_dir .. "/theme_state.txt"

-- Load current theme index from state file
local function load_theme_index()
    local file = io.open(state_file, "r")
    if file then
        local index = tonumber(file:read("*line"))
        file:close()
        return index or 1
    end
    return 1
end

-- Save current theme index to state file
local function save_theme_index(index)
    local file = io.open(state_file, "w")
    if file then
        file:write(tostring(index))
        file:close()
    end
end

-- Set the current theme index from state file
ThemeManager.current_theme_index = load_theme_index()

local action = arg[1] or "next"

if action == "next" then
    ThemeManager.next_theme()
    save_theme_index(ThemeManager.current_theme_index)
    print("Switched to theme: " .. ThemeManager.get_current_theme().name)
elseif action == "prev" then
    ThemeManager.prev_theme()
    save_theme_index(ThemeManager.current_theme_index)
    print("Switched to theme: " .. ThemeManager.get_current_theme().name)
elseif action == "list" then
    print("Available themes:")
    for i, theme_name in ipairs(ThemeManager.theme_names) do
        local theme = ThemeManager.themes[theme_name]
        local marker = (i == ThemeManager.current_theme_index) and " *" or ""
        print(string.format("  %d. %s%s", i, theme.name, marker))
    end
elseif action == "current" then
    print("Current theme: " .. ThemeManager.get_current_theme().name)
else
    -- Try to set specific theme
    local theme = ThemeManager.set_theme(action)
    if theme then
        save_theme_index(ThemeManager.current_theme_index)
        print("Switched to theme: " .. theme.name)
    else
        print("Unknown theme: " .. action)
        print("Available themes: " .. table.concat(ThemeManager.theme_names, ", "))
    end
end

-- Wallpaper management functions (duplicated from themes.lua for standalone use)
local function find_wallpaper_for_theme(theme_name)
    local themes_dir = config_dir .. "/themes"
    local image_extensions = {"png", "jpg", "jpeg", "gif", "bmp", "tiff", "webp"}
    
    for _, ext in ipairs(image_extensions) do
        local wallpaper_path = themes_dir .. "/" .. theme_name .. "." .. ext
        local file = io.open(wallpaper_path, "r")
        if file then
            file:close()
            return wallpaper_path
        end
    end
    return nil
end

local function set_wallpaper_for_all_spaces(wallpaper_path)
    if not wallpaper_path then
        return false
    end
    
    -- Convert relative path to absolute path
    local absolute_path = wallpaper_path
    if wallpaper_path:sub(1, 1) == "." then
        absolute_path = os.getenv("PWD") .. wallpaper_path:sub(2)
    end
    
    -- Use the macOS Sonoma .plist method for setting wallpapers on all spaces
    local plist_path = os.getenv("HOME") .. "/Library/Application Support/com.apple.wallpaper/Store/Index.plist"
    
    -- Check if the plist file exists
    local plist_file = io.open(plist_path, "r")
    if not plist_file then
        -- Fallback to AppleScript if plist doesn't exist
        local script = string.format([[
            tell application "System Events"
                set desktopCount to count of desktops
                repeat with i from 1 to desktopCount
                    set picture of desktop i to "%s"
                end repeat
            end tell
        ]], absolute_path)
        
        local result = os.execute("osascript -e '" .. script .. "'")
        return result == 0 or result == true
    end
    plist_file:close()
    
    -- Update the existing plist structure using PlistBuddy
    -- Update SystemDefault
    local command = string.format('/usr/libexec/PlistBuddy -c "set SystemDefault:Desktop:Content:Choices:0:Files:0:relative file://%s" "%s"', absolute_path, plist_path)
    local result = os.execute(command)
    
    -- Update Displays
    command = string.format('/usr/libexec/PlistBuddy -c "set Displays:37D8832A-2D66-02CA-B9F7-8F30A301B230:Desktop:Content:Choices:0:Files:0:relative file://%s" "%s"', absolute_path, plist_path)
    result = os.execute(command) or result
    
    -- Update known space IDs
    local known_space_ids = {
        "7C01335A-6F11-438B-A860-B77627C0A098",
        "54733FBD-7461-40A5-93EA-438A010028B8", 
        "877F7393-DFDD-4C7B-AA73-E16E80BDC4C7",
        "9DD66961-2812-4505-8854-1B209C7F1B8A",
        "CF83B9F3-30DD-4311-BC58-45D159A7792F",
        "158B1F3B-B95F-48D1-83B8-EBDE139B4B2D"
    }
    
    for _, space_id in ipairs(known_space_ids) do
        command = string.format('/usr/libexec/PlistBuddy -c "set Spaces:%s:Default:Desktop:Content:Choices:0:Files:0:relative file://%s" "%s"', space_id, absolute_path, plist_path)
        os.execute(command .. " 2>/dev/null")
        
        command = string.format('/usr/libexec/PlistBuddy -c "set Spaces:%s:Displays:37D8832A-2D66-02CA-B9F7-8F30A301B230:Desktop:Content:Choices:0:Files:0:relative file://%s" "%s"', space_id, absolute_path, plist_path)
        os.execute(command .. " 2>/dev/null")
    end
    
    local success = (result == 0 or result == true)
    
    if success then
        -- Kill WallpaperAgent to apply changes
        os.execute("killall WallpaperAgent 2>/dev/null")
        return true
    else
        -- Fallback to AppleScript if PlistBuddy fails
        local script = string.format([[
            tell application "System Events"
                set desktopCount to count of desktops
                repeat with i from 1 to desktopCount
                    set picture of desktop i to "%s"
                end repeat
            end tell
        ]], absolute_path)
        
        local result = os.execute("osascript -e '" .. script .. "'")
        return result == 0 or result == true
    end
end

-- If we're being called from sketchybar, apply the theme
if os.getenv("CONFIG_DIR") or true then
    -- This is being called from sketchybar, so apply the theme
    local theme = ThemeManager.get_current_theme()
    local theme_name = ThemeManager.get_current_theme_name()
    
    -- Update bar configuration
    os.execute(string.format('sketchybar --bar height=%d corner_radius=%d y_offset=%d color=0x%x', 
        theme.bar_config.height, 
        theme.bar_config.corner_radius, 
        theme.bar_config.y_offset,
        theme.colors.bar.bg))
    
    -- Try to set wallpaper for the theme
    local wallpaper_path = find_wallpaper_for_theme(theme_name)
    if wallpaper_path then
        local success = set_wallpaper_for_all_spaces(wallpaper_path)
        if success then
            os.execute(string.format('osascript -e \'display notification "%s (wallpaper set)" with title "SketchyBar Theme"\'', theme.name))
        else
            os.execute(string.format('osascript -e \'display notification "%s (wallpaper failed)" with title "SketchyBar Theme"\'', theme.name))
        end
    else
        -- No wallpaper found, just show theme change notification
        os.execute(string.format('osascript -e \'display notification "%s" with title "SketchyBar Theme"\'', theme.name))
    end
    
    -- Trigger the theme_changed event to recreate spaces and update all widgets
    os.execute('sketchybar --trigger theme_changed')
end 