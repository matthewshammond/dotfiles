local settings = require("settings")
local colors = require("colors")
local icons = require("icons")

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

local mail = sbar.add("item", "widgets.mail", {
	position = "right",
	icon = {
		string = "􀍖", -- Mail icon (same as space 6)
		color = colors.mail_widget_icon or colors.white,
		padding_left = 4,
		font = {
			style = settings.font.style_map["Regular"],
			size = 16.0,
		},
	},
	label = {
		string = "0",
		color = colors.mail_widget_text or colors.white,
		padding_right = 4,
		font = { family = settings.font.numbers },
	},
	background = {
		color = colors.mail_widget_bg or colors.transparent,
		border_color = colors.mail_widget_border or colors.border2,
		border_width = 1,
		height = 20,
	},
	update_freq = 120, -- Update every 2 minutes
})

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

-- Function to clear popup items
local function clear_popup()
	-- Try to remove items, but don't worry about errors
	sbar.remove("mail.popup.*")
	sbar.remove("mail.popup.title.*")
	sbar.remove("mail.popup.[0-9].*")
	-- Force a small delay to ensure items are cleared
	sbar.exec("sleep 0.1", function() end)
end

-- Function to update mail count
local function mail_update()
	local applescript = [[
tell application "Mail"
  set total_unread to 0
  repeat with a in every account whose enabled is true
    try
      set total_unread to total_unread + unread count of mailbox "INBOX" of a
    end try
  end repeat
  return total_unread
end tell
  ]]
	local tmpfile = "/tmp/sketchybar_mail_count.scpt"
	-- Write the script to a file
	local f = io.open(tmpfile, "w")
	f:write(applescript)
	f:close()
	-- Run osascript on the file
	sbar.exec("osascript " .. tmpfile, function(result, exit_code)
		os.remove(tmpfile)
		if exit_code and exit_code ~= 0 then
			-- Set to 0 on error
			mail:set({
				icon = { color = colors.mail_widget_icon or colors.white },
				label = { string = "0", color = colors.mail_widget_icon or colors.white },
			})
			return
		end
		
		local unread_count = tonumber(result) or 0
		local color
		
		if unread_count == 0 then
			color = colors.mail_widget_icon or colors.white
		elseif unread_count > 0 and unread_count < 10 then
			color = colors.mail_widget_warning or colors.yellow
		else
			color = colors.mail_widget_alert or colors.red
		end

		mail:set({
			icon = { color = color },
			label = {
				string = tostring(unread_count),
				color = color,
			},
		})
	end)
end

-- Function to get mailboxes
local function get_mailboxes()
	local applescript = [[
tell application "Mail"
  set _output to ""
  repeat with a in every account whose enabled is true
    try
      set _output to _output & unread count of mailbox "INBOX" of a & "  " & name of a & "\n"
    end try
  end repeat
  return _output
end tell
  ]]
	local tmpfile = "/tmp/sketchybar_mailboxes.scpt"
	-- Write the script to a file
	local f = io.open(tmpfile, "w")
	f:write(applescript)
	f:close()
	-- Run osascript on the file
	sbar.exec("osascript " .. tmpfile, function(mailboxes, exit_code)
		os.remove(tmpfile)
		if exit_code and exit_code ~= 0 then
			-- Show a simple message instead of failing
			clear_popup()
			sbar.add("item", "mail.popup.error", {
				position = "popup." .. mail.name,
				label = {
					string = "Mail not accessible",
					color = colors.mail_widget_text or colors.white,
				},
			})
			return
		end
		
		-- Clear existing popup items
		clear_popup()
		
		-- Add title
		sbar.add("item", "mail.popup.title", {
			position = "popup." .. mail.name,
			background = { color = colors.mail_widget_bg or colors.transparent },
			icon = {
				string = "􀍖",
				color = colors.mail_widget_icon or colors.white,
				font = { size = 16.0 },
			},
			label = {
				string = "Mailboxes:",
				color = colors.mail_widget_text or colors.white,
				font = { family = settings.font.text },
			},
		})
		
		-- Add mailboxes
		local i = 0
		for line in string.gmatch(mailboxes, "[^\n]+") do
			local splitter = {}
			for word in string.gmatch(line, "%S+") do
				table.insert(splitter, word)
			end
			
			if #splitter >= 2 then
				local unread_count = splitter[1]
				local account_name = splitter[2]
				
				local mailbox_item = sbar.add("item", "mail.popup." .. i, {
					position = "popup." .. mail.name,
					icon = {
						string = "􀍖 " .. unread_count,
						color = colors.mail_widget_icon or colors.white,
						font = { size = 14.0 },
					},
					label = {
						string = account_name,
						color = colors.mail_widget_text or colors.white,
						font = { family = settings.font.text },
					},
				})
				
				-- Subscribe to click events
				mailbox_item:subscribe("mouse.clicked", function()
					local activate_script = [[
tell application "Mail"
  activate
  set acc to account "]] .. account_name .. [["
end tell
  ]]
					local tmpfile = "/tmp/sketchybar_mail_activate.scpt"
					local f = io.open(tmpfile, "w")
					f:write(activate_script)
					f:close()
					sbar.exec("osascript " .. tmpfile, function()
						os.remove(tmpfile)
					end)
				end)
				
				i = i + 1
			end
		end
	end)
end

-- Subscribe to events
local popup_visible = false

mail:subscribe("mouse.entered", function()
	if not popup_visible then
		popup_visible = true
		clear_popup() -- Clear any existing popup first
		mail:set({ popup = { drawing = true } })
		mail_update() -- Update the main widget first
		get_mailboxes() -- Then update the popup
	end
end)

mail:subscribe("mouse.exited.global", function()
	popup_visible = false
	mail:set({ popup = { drawing = false } })
end)

mail:subscribe("mouse.clicked", function()
	mail_update()
end)

-- Subscribe to events like calendar widget
mail:subscribe({ "forced", "routine", "system_woke" }, function(env)
	mail_update()
end) 