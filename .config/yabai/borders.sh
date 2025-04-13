#!/usr/bin/env bash

windows="$(yabai -m query --spaces --space | jq '.windows')"
label="$(yabai -m query --spaces --space | jq '.label')"

if [[ $windows == *","* ]] && [[ $label == *"dev"* ]]; then
	yabai -m rule --remove "border off"
	yabai -m rule --add app="^kitty$" border=on label="border on"
	yabai -m rule --add title="^(Main Terminal)$" border=on label="border on"
else
	yabai -m rule --remove "border on"
	yabai -m rule --add app="^kitty$" border=off label="border off"
	yabai -m rule --add title="^(Main Terminal)$" border=off label="border off"
fi
