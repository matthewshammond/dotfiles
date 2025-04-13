#!/usr/bin/env bash

# usage mac-spoof.sh XX:XX:XX:XX:XX:XX

# Spoof MAC address of Wi-Fi interface
networksetup -setairportpower en0 on
sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport --disassociate
sudo ifconfig en0 ether "$1"
printf "%s\n" "Spoofed MAC address of en0 interface to $(ifconfig en0 | grep ether | awk '{print $2}')"
printf "%s\n" "Hardware MAC address of en0 interface is $(networksetup -listallhardwareports | awk -v RS= '/en0/{print $NF}')"
