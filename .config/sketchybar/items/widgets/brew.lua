local settings = require("settings")
local colors = require("colors")
local icons = require("icons")

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

local brew = sbar.add("item", "widgets.brew", {
	position = "right",
	icon = {
		string = "􀐛", -- Brew icon
		color = colors.brew_widget_icon or colors.white,
		padding_left = 4,
		font = {
			style = settings.font.style_map["Regular"],
			size = 16.0,
		},
	},
	label = {
		string = "0",
		color = colors.brew_widget_text or colors.white,
		padding_right = 4,
		font = { family = settings.font.numbers },
	},
	background = {
		color = colors.brew_widget_bg or colors.transparent,
		border_color = colors.brew_widget_border or colors.border2,
		border_width = 1,
		height = 20,
	},
	update_freq = 300, -- Update every 5 minutes
})

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

-- Function to update brew count using sbar.exec
local function brew_update()
	sbar.exec("timeout 30 brew update && brew outdated | wc -l | tr -d ' ' 2>/dev/null || echo '0'", function(result, exit_code)
		if not exit_code or exit_code == 0 or exit_code == 124 then -- nil means success, 124 is timeout exit code
			-- Extract just the number from the result (handle newlines and other text)
			local count = 0
			for num in string.gmatch(result, "%d+") do
				count = tonumber(num) or 0
				break -- Take the first number found
			end
			local color = colors.brew_widget_icon or colors.white
			
			if count > 0 then
				color = colors.brew_widget_alert or colors.red
			end
			
			brew:set({
				icon = { color = color },
				label = { string = tostring(count) },
			})
		else
			-- Fallback to 0 on error
			brew:set({
				icon = { color = colors.brew_widget_icon or colors.white },
				label = { string = "0" },
			})
		end
	end)
end

-- Function to get brew packages for popup using sbar.exec
local popup_items = {} -- Track created popup items

local function clear_popup_items()
	-- Remove all tracked popup items
	for _, item_name in ipairs(popup_items) do
		sbar.remove(item_name)
	end
	popup_items = {} -- Clear the tracking array
end

local function get_brew_packages()
	sbar.exec("brew outdated", function(result, exit_code)
		if not exit_code or exit_code == 0 then -- nil means success
			-- Clear existing popup items
			clear_popup_items()
			
			-- Add brew packages with unique names
			local i = 0
			for package in string.gmatch(result, "[^\r\n]+") do
				if not package:match("^==>") then
					local package_name = package:match("^([^%s]+)")
					if package_name then
						local unique_name = "brew.popup." .. i .. "." .. os.time()
						sbar.add("item", unique_name, {
							position = "popup." .. brew.name,
							icon = {
								string = "🍺",
								color = colors.brew_widget_icon or colors.white,
								font = { size = 14.0 },
							},
							label = {
								string = package_name,
								color = colors.brew_widget_text or colors.white,
								font = { family = settings.font.text },
							},
						})
						table.insert(popup_items, unique_name) -- Track the item
						i = i + 1
					end
				end
			end
		end
	end)
end

-- Subscribe to events
local popup_visible = false

brew:subscribe("mouse.entered", function()
	if not popup_visible then
		popup_visible = true
		brew:set({ popup = { drawing = true } })
		get_brew_packages()
	end
end)

brew:subscribe("mouse.exited", function()
	-- Don't hide popup immediately, let mouse.exited.global handle it
end)

brew:subscribe("mouse.exited.global", function()
	popup_visible = false
	brew:set({ popup = { drawing = false } })
	-- Clear popup items using tracked names
	clear_popup_items()
end)

-- Subscribe to events like calendar widget
brew:subscribe({ "forced", "routine", "system_woke" }, function(env)
	brew_update()
end)
