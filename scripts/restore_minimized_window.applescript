try
	tell application "System Events"
		set frontApp to name of first application process whose frontmost is true
		tell application process frontApp
			set minimizedWindows to every window whose value of attribute "AXMinimized" is true
			repeat with w in minimizedWindows
				set value of attribute "AXMinimized" of w to false
			end repeat
		end tell
	end tell
on error errMsg
	display dialog "Error: " & errMsg
end try
