#!/bin/bash
# fn+m (skhd): swap between sketchybar and the macOS menu bar so exactly one
# is always on screen.
#   sketchybar mode: sketchybar shown; menu bar auto-hidden and invisible
#   menu bar mode:   sketchybar hidden; menu bar always shown (no auto-hide)
# yabai reserves 32px for sketchybar only in sketchybar mode; in menu bar mode
# the visible menu bar already pushes windows down.

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

set_autohide() {
	osascript -e "tell application \"System Events\" to set autohide menu bar of dock preferences to $1"
}

if sketchybar --query bar | grep -q '"hidden": "off"'; then
	# -> menu bar mode
	sketchybar --bar hidden=on
	yabai -m config external_bar main:0:0
	yabai -m config menubar_opacity 1.0
	set_autohide false
else
	# -> sketchybar mode
	set_autohide true
	yabai -m config menubar_opacity 0.0
	yabai -m config external_bar main:32:0
	sketchybar --bar hidden=off
fi
