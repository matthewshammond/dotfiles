#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Ghostty
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Smart Ghostty behavior: fullscreen quick terminal, or jump to app on space 5
# @raycast.author Matt Hammond

quick_terminal_fill() {
  /usr/bin/osascript <<'APPLESCRIPT'
  tell application "System Events"
    tell application process "Ghostty"
      if exists (menu item "Fill" of menu "Window" of menu bar 1) then
        click menu item "Fill" of menu "Window" of menu bar 1
      end if
    end tell
  end tell
APPLESCRIPT
}

go_to_space_5() {
  skhd --key "cmd-5"
}

is_ghostty_running() {
  /usr/bin/osascript <<EOF | grep -q "true"
  tell application "System Events"
    return (name of processes) contains "Ghostty"
  end tell
EOF
}

launch_ghostty() {
  /usr/bin/osascript <<EOF
  tell application "Ghostty"
    if it is not running then launch
  end tell
EOF
}

visible_quick_terminal() {
  yabai -m query --windows |
    jq -e '.[] | select(.app == "Ghostty" and .subrole == "AXFloatingWindow" and .["is-visible"] == true)' >/dev/null
}

# Main logic
if visible_quick_terminal; then
  quick_terminal_fill
else
  if ! is_ghostty_running; then
    launch_ghostty
    sleep 0.75
  fi
  go_to_space_5
fi
