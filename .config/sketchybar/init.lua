-- Require the sketchybar module
sbar = require("sketchybar")

-- Set the bar name, if you are using another bar instance than sketchybar
-- sbar.set_bar_name("bottom_bar")

-- Load theme system first
local theme_system = require("themes")
local ThemeManager = theme_system.manager

-- Load saved theme state
local state_file = os.getenv("CONFIG_DIR") and (os.getenv("CONFIG_DIR") .. "/theme_state.txt") or "theme_state.txt"
local file = io.open(state_file, "r")
if file then
    local index = tonumber(file:read("*line"))
    file:close()
    if index and index >= 1 and index <= #ThemeManager.theme_names then
        ThemeManager.current_theme_index = index
    end
end

-- Bundle the entire initial configuration into a single message to sketchybar
sbar.begin_config()
require("bar")
require("default")
require("items")
sbar.end_config()

-- Run the event loop of the sketchybar module (without this there will be no
-- callback functions executed in the lua module)
sbar.event_loop()
