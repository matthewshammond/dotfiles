#!/usr/bin/env bash

# stop yabai
yabai --stop-service

# upgrade yabai with homebrew (remove old service file because homebrew changes binary path)
yabai --uninstall-service
brew upgrade yabai

# start yabai service
yabai --start-service

# give yabai root privileges
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai
