#!/usr/bin/env bash

# allow touch id for sudo
sudo sed -i '' '2i\'$'\n''auth       sufficient     pam_tid.so'$'\n' /etc/pam.d/sudo
