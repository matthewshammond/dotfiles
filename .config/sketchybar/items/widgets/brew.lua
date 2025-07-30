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
	-- Get brew outdated count
	sbar.exec("timeout 30 brew update && brew outdated | wc -l | tr -d ' ' 2>/dev/null || echo '0'", function(brew_result, brew_exit_code)
		-- Get mas outdated count
		sbar.exec("timeout 30 mas outdated | wc -l | tr -d ' ' 2>/dev/null || echo '0'", function(mas_result, mas_exit_code)
			local brew_count = 0
			local mas_count = 0
			
			-- Parse brew count
			if not brew_exit_code or brew_exit_code == 0 or brew_exit_code == 124 then
				for num in string.gmatch(brew_result, "%d+") do
					brew_count = tonumber(num) or 0
					break
				end
			end
			
			-- Parse mas count
			if not mas_exit_code or mas_exit_code == 0 or mas_exit_code == 124 then
				for num in string.gmatch(mas_result, "%d+") do
					mas_count = tonumber(num) or 0
					break
				end
			end
			
			local total_count = brew_count + mas_count
			local color = colors.brew_widget_icon or colors.white
			
			if total_count > 0 then
				color = colors.brew_widget_alert or colors.red
			end
			
			brew:set({
				icon = { color = color },
				label = { string = tostring(total_count) },
			})
		end)
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
	-- Clear existing popup items
	clear_popup_items()
	
	local timestamp = os.time()
	local brew_counter = 0
	local mas_counter = 1000 -- Start mas counter at 1000 to avoid conflicts
	
	-- Get brew packages (runs in parallel)
	sbar.exec("brew outdated", function(brew_result, brew_exit_code)
		-- Add brew packages
		if not brew_exit_code or brew_exit_code == 0 then
			for package in string.gmatch(brew_result, "[^\r\n]+") do
				if not package:match("^==>") then
					local package_name = package:match("^([^%s]+)")
					if package_name then
						local unique_name = "brew.popup." .. brew_counter .. "." .. timestamp
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
						table.insert(popup_items, unique_name)
						brew_counter = brew_counter + 1
					end
				end
			end
		end
	end)
	
	-- Get mas packages (runs in parallel)
	sbar.exec("mas outdated", function(mas_result, mas_exit_code)
		if not mas_exit_code or mas_exit_code == 0 then
			for package in string.gmatch(mas_result, "[^\r\n]+") do
				-- mas outdated format: "ID Name (Current -> Latest)"
				-- Extract the app name between ID and version info
				local app_name = package:match("^%d+%s+([^%(]+)")
				if app_name then
					app_name = app_name:gsub("%s+$", "") -- trim trailing spaces
					local unique_name = "mas.popup." .. mas_counter .. "." .. timestamp
					sbar.add("item", unique_name, {
						position = "popup." .. brew.name,
						icon = {
							string = "📱",
							color = colors.brew_widget_icon or colors.white,
							font = { size = 14.0 },
						},
						label = {
							string = app_name,
							color = colors.brew_widget_text or colors.white,
							font = { family = settings.font.text },
						},
					})
					table.insert(popup_items, unique_name)
					mas_counter = mas_counter + 1
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
