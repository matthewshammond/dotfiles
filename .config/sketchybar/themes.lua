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
    
    -- Function to check if a plist path exists
    local function plist_path_exists(path)
        local command = string.format('/usr/libexec/PlistBuddy -c "Print %s" "%s" 2>/dev/null', path, plist_path)
        local result = os.execute(command)
        return result == 0 or result == true
    end
    
    -- Function to update Configuration data (for macOS Tahoe)
    -- Uses Python to create binary plist and update the Configuration key
    local function update_configuration_data(choices_path, wallpaper_path)
        local config_path = choices_path .. ":Configuration"
        
        -- Check if Configuration exists
        if not plist_path_exists(config_path) then
            return false
        end
        
        -- Create temporary Python script file
        local python_script_file = os.tmpname() .. ".py"
        local python_script = string.format([[
import plistlib
import tempfile
import sys

config = {
    'type': 'imageFile',
    'url': {
        'relative': 'file://%s'
    }
}

# Create binary plist
binary_data = plistlib.dumps(config, fmt=plistlib.FMT_BINARY)

# Write to temp file
temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.plist')
temp_file.write(binary_data)
temp_file.close()
print(temp_file.name)
]], wallpaper_path:gsub("\\", "\\\\"):gsub("'", "\\'"))
        
        -- Write Python script to temp file
        local script_file = io.open(python_script_file, "w")
        if not script_file then
            return false
        end
        script_file:write(python_script)
        script_file:close()
        
        -- Execute Python script to create binary plist
        local python_command = string.format('python3 "%s" 2>/dev/null', python_script_file)
        local handle = io.popen(python_command)
        if not handle then
            os.remove(python_script_file)
            return false
        end
        
        local temp_plist = handle:read("*line")
        handle:close()
        os.remove(python_script_file)
        
        if not temp_plist or temp_plist == "" then
            return false
        end
        
        -- Use PlistBuddy to import the binary data
        local import_command = string.format('/usr/libexec/PlistBuddy -c "Import %s %s" "%s" 2>/dev/null', config_path, temp_plist, plist_path)
        local result = os.execute(import_command)
        
        -- Clean up temp plist file
        os.remove(temp_plist)
        
        return result == 0 or result == true
    end
    
    -- Function to get all keys in a dictionary
    local function get_dict_keys(dict_path)
        local command = string.format('/usr/libexec/PlistBuddy -c "Print %s" "%s" 2>/dev/null', dict_path, plist_path)
        local handle = io.popen(command)
        if not handle then return {} end
        
        local content = handle:read("*all")
        handle:close()
        
        local keys = {}
        for key in content:gmatch('([%w%-]+) = Dict') do
            table.insert(keys, key)
        end
        return keys
    end
    
    local success = false
    
    -- Try to update SystemDefault if it exists (macOS Tahoe uses Configuration data)
    local system_default_choices = "SystemDefault:Desktop:Content:Choices:0"
    if plist_path_exists(system_default_choices) then
        success = update_configuration_data(system_default_choices, absolute_path) or success
    end
    
    -- Try to update AllSpacesAndDisplays if it exists (macOS Tahoe uses Configuration data)
    local all_spaces_choices = "AllSpacesAndDisplays:Desktop:Content:Choices:0"
    if plist_path_exists(all_spaces_choices) then
        success = update_configuration_data(all_spaces_choices, absolute_path) or success
    end
    
    -- Try to update Displays section if it exists (macOS Tahoe uses Configuration data)
    if plist_path_exists("Displays") then
        local display_keys = get_dict_keys("Displays")
        for _, display_id in ipairs(display_keys) do
            local display_choices = string.format("Displays:%s:Desktop:Content:Choices:0", display_id)
            if plist_path_exists(display_choices) then
                if update_configuration_data(display_choices, absolute_path) then
                    success = true
                end
            end
        end
    end
    
    -- Try to update Spaces section if it exists (macOS Tahoe uses Configuration data)
    if plist_path_exists("Spaces") then
        local space_keys = get_dict_keys("Spaces")
        for _, space_id in ipairs(space_keys) do
            -- Try different possible paths for each space
            local space_choices_paths = {
                string.format("Spaces:%s:Desktop:Content:Choices:0", space_id),
                string.format("Spaces:%s:Default:Desktop:Content:Choices:0", space_id)
            }
            
            for _, space_choices in ipairs(space_choices_paths) do
                if plist_path_exists(space_choices) then
                    if update_configuration_data(space_choices, absolute_path) then
                        success = true
                    end
                end
            end
            
            -- Also try to update any displays within this space
            local space_displays_path = string.format("Spaces:%s:Displays", space_id)
            if plist_path_exists(space_displays_path) then
                local display_keys = get_dict_keys(space_displays_path)
                for _, display_id in ipairs(display_keys) do
                    local display_choices = string.format("Spaces:%s:Displays:%s:Desktop:Content:Choices:0", space_id, display_id)
                    if plist_path_exists(display_choices) then
                        if update_configuration_data(display_choices, absolute_path) then
                            success = true
                        end
                    end
                end
            end
        end
    end
    
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
