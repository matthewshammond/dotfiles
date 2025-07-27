-- Color conversion utilities (make available to theme files)
local function hex_to_rgba(hex_color, alpha)
    -- Remove # if present
    hex_color = hex_color:gsub("#", "")
    
    -- Parse hex color
    local r = tonumber(hex_color:sub(1, 2), 16)
    local g = tonumber(hex_color:sub(3, 4), 16)
    local b = tonumber(hex_color:sub(5, 6), 16)
    
    -- Default alpha to 255 (fully opaque) if not provided
    alpha = alpha or 255
    
    -- Convert to 0xAARRGGBB format using arithmetic operations
    return (alpha * 16777216) + (r * 65536) + (g * 256) + b
end

-- Helper function to create colors with standard hex format
local function color(hex_color, alpha)
    if type(hex_color) == "string" and hex_color:match("^#%x%x%x%x%x%x$") then
        return hex_to_rgba(hex_color, alpha)
    end
    return hex_color -- Return as-is if already in 0x format
end

-- Helper function to create transparent colors
local function transparent(hex_color, alpha_percent)
    local alpha = math.floor((alpha_percent or 100) * 255 / 100)
    return color(hex_color, alpha)
end

-- Wallpaper management functions
local function find_wallpaper_for_theme(theme_name)
    local themes_dir = (os.getenv("CONFIG_DIR") or ".") .. "/themes"
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

local ThemeManager = {
    themes = {},
    current_theme_index = 1,
    theme_names = {},
}

-- Load themes from the themes directory
local function load_themes_from_directory()
    local themes_dir = (os.getenv("CONFIG_DIR") or ".") .. "/themes"
    
    -- Get list of files in themes directory
    local handle = io.popen("ls " .. themes_dir .. "/*.lua 2>/dev/null")
    if handle then
        local result = handle:read("*a")
        handle:close()
        
        for filename in result:gmatch("[^\r\n]+") do
            local theme_name = filename:match("([^/]+)%.lua$")
            if theme_name and theme_name ~= "sample" then
                -- Load the theme file
                local theme_file = loadfile(filename)
                if theme_file then
                    -- Create a wrapper that provides the color functions
                    local function load_theme_with_colors()
                        -- Make color functions available in global scope for this load
                        _G.color = color
                        _G.transparent = transparent
        
                        -- Load the theme
                        local theme = theme_file()
        
                        -- Clean up global functions
                        _G.color = nil
                        _G.transparent = nil
        
                        return theme
                    end
                    
                    local theme = load_theme_with_colors()
                    if theme and theme.name then
                        ThemeManager.themes[theme_name] = theme
                        table.insert(ThemeManager.theme_names, theme_name)
                    end
                end
            end
        end
    end
end

-- Load themes from directory
load_themes_from_directory()

-- Get current theme
function ThemeManager.get_current_theme()
    return ThemeManager.themes[ThemeManager.theme_names[ThemeManager.current_theme_index]]
end

-- Get current theme name
function ThemeManager.get_current_theme_name()
    return ThemeManager.theme_names[ThemeManager.current_theme_index]
end

-- Get widget configuration from current theme
function ThemeManager.get_widget_config()
    local theme = ThemeManager.get_current_theme()
    return theme and theme.widgets or {}
end

-- Check if a widget is enabled in current theme
function ThemeManager.is_widget_enabled(widget_name)
    local widgets = ThemeManager.get_widget_config()
    for _, widget in ipairs(widgets) do
        if widget == widget_name then
            return true
        end
    end
    return false
end

-- Get enabled widgets in order from current theme
function ThemeManager.get_enabled_widgets()
    local theme = ThemeManager.get_current_theme()
    if theme and theme.widgets then
        return theme.widgets
    end
    return {}
end

-- Cycle to next theme
function ThemeManager.next_theme()
    ThemeManager.current_theme_index = ThemeManager.current_theme_index + 1
    if ThemeManager.current_theme_index > #ThemeManager.theme_names then
        ThemeManager.current_theme_index = 1
    end
    return ThemeManager.get_current_theme()
end

-- Cycle to previous theme
function ThemeManager.prev_theme()
    ThemeManager.current_theme_index = ThemeManager.current_theme_index - 1
    if ThemeManager.current_theme_index < 1 then
        ThemeManager.current_theme_index = #ThemeManager.theme_names
    end
    return ThemeManager.get_current_theme()
end

-- Set specific theme by name
function ThemeManager.set_theme(theme_name)
    for i, name in ipairs(ThemeManager.theme_names) do
        if name == theme_name then
            ThemeManager.current_theme_index = i
            return ThemeManager.get_current_theme()
        end
    end
    return nil
end

-- Apply theme to sketchybar
function ThemeManager.apply_theme()
    local theme = ThemeManager.get_current_theme()
    local theme_name = ThemeManager.get_current_theme_name()

    -- Update bar configuration
    sbar.bar({
        topmost = "window",
        height = theme.bar_config.height,
        color = theme.colors.bar.bg,
        padding_right = 0,
        padding_left = 0,
        margin = 5,
        corner_radius = theme.bar_config.corner_radius,
        y_offset = theme.bar_config.y_offset,
    })

    -- Try to set wallpaper for the theme
    local wallpaper_path = find_wallpaper_for_theme(theme_name)
    if wallpaper_path then
        set_wallpaper_for_all_spaces(wallpaper_path)
    end
    
    -- Show theme change notification
    sbar.exec("osascript -e 'display notification \"Theme: " .. theme.name .. '" with title "SketchyBar"\'')

    -- Trigger refresh for all items
    sbar.trigger("theme_changed")
end

return {
    manager = ThemeManager,
    find_wallpaper_for_theme = find_wallpaper_for_theme,
    set_wallpaper_for_all_spaces = set_wallpaper_for_all_spaces,
}
