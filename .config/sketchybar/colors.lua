local theme_system = require("themes")
local ThemeManager = theme_system.manager

-- Function to get current theme colors
local function get_colors()
    return ThemeManager.get_current_theme().colors
end

-- Note: Color conversion functions are now available in themes.lua for theme files

-- Export colors with theme support
local colors = setmetatable({}, {
    __index = function(_, key)
        local colors = get_colors()
        return colors[key]
    end,
    __newindex = function(_, key, value)
        -- Allow setting colors for backward compatibility
        rawset(get_colors(), key, value)
    end
})

-- Add the with_alpha function
colors.with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then
        return color
    end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

return colors
