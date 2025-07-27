#!/usr/bin/env lua

-- Standalone theme cycling script
-- Usage: lua theme_cycle.lua [next|prev|theme_name]

-- Add the current directory to the package path
package.path = package.path .. ";" .. os.getenv("CONFIG_DIR") .. "/?.lua"

local theme_system = require("themes")
local ThemeManager = theme_system.manager

-- State file to persist current theme index
local state_file = os.getenv("CONFIG_DIR") and (os.getenv("CONFIG_DIR") .. "/theme_state.txt") or "theme_state.txt"

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

-- If we're being called from sketchybar, apply the theme
if os.getenv("CONFIG_DIR") then
    -- This is being called from sketchybar, so apply the theme
    local theme = ThemeManager.get_current_theme()
    
    -- Update bar configuration
    os.execute(string.format('sketchybar --bar height=%d corner_radius=%d y_offset=%d color=0x%x', 
        theme.bar_config.height, 
        theme.bar_config.corner_radius, 
        theme.bar_config.y_offset,
        theme.colors.bar.bg))
    
    -- Trigger the theme_changed event to recreate spaces and update all widgets
    os.execute('sketchybar --trigger theme_changed')
    
    -- Show notification of theme change
    os.execute(string.format('osascript -e \'display notification "%s" with title "SketchyBar Theme"\'', theme.name))
end 