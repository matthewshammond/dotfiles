local theme_system = require("themes")
local ThemeManager = theme_system.manager

-- Widget registry - add new widgets here
local WIDGET_REGISTRY = {
	cpu = "items.widgets.cpu",
	wifi = "items.widgets.wifi",
	volume = "items.widgets.volume",
	battery = "items.widgets.battery",
	media = "items.widgets.media",
	calendar = "items.widgets.calendar",
	brew = "items.widgets.brew",
	mail = "items.widgets.mail",
	-- Add new widgets here as they're created:
	-- memory = "items.widgets.memory",
	-- disk = "items.widgets.disk",
	-- weather = "items.widgets.weather",
	-- clock = "items.widgets.clock",
}

-- Get enabled widgets from current theme
local enabled_widgets = ThemeManager.get_enabled_widgets()

-- Load only the widgets that are enabled in the current theme
-- Load in reverse order so they appear in the correct order (first = leftmost)
for i = #enabled_widgets, 1, -1 do
	local widget_name = enabled_widgets[i]
	local widget_path = WIDGET_REGISTRY[widget_name]
	if widget_path then
		require(widget_path)
	else
		print("Warning: Unknown widget '" .. widget_name .. "' in theme configuration")
	end
end

-- Fallback: if no widgets are configured, load all widgets
if #enabled_widgets == 0 then
	for widget_name, widget_path in pairs(WIDGET_REGISTRY) do
		require(widget_path)
	end
end
