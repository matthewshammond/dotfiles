#!/usr/bin/env zsh
################################################################################
# This script installs all packages and software.  It will also set all system #
# preferences, application configurations, and link .dotfiles.  It will work   #
# on both Intel and Arm chips.                                                 #
################################################################################

set -e

if [ "$#" -ne 1 ]; then
	echo "Usage: install.zsh <home_directory>"
	exit 1
fi

# Ask for the administrator password upfront
echo "\nAsk for sudo password now and keep alive for remainder of install."
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# check for xcode tools
# if [ $(xcode-select -p 1>/dev/null;echo $?) != 0 ]; then
#     echo "Install xcode tools before running script."
#     echo "xcode-select --install"
#     exit 1
# fi

# check for xcode tools
if [ $(xcode-select -p 1>/dev/null;echo $?) != 0 ]; then
    echo "Installing xcode tools."
    echo "sudo xcodebuild -license accept"
    sudo xcodebuild -license accept
fi

/usr/bin/caffeinate -d &

# If ARM, install Rosetta 2
if [ $(uname -a | awk '{print $(NF)}') = 'arm64' ]; then
    echo "Installing Rosetta 2"
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
fi

homedir=$1
export homedir # allows variable to be passed to other scripts

# check for logs directory and create if does not exist
[ ! -d $HOME/logs ] && mkdir $HOME/logs

# redirect STDOUT and STDERR to log
exec 1> >(tee $HOME/logs/install.log) 2>&1

# Close System Preferences to prevent changes from being made
echo "\nClosing system preferences."
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
# echo "\nAsk for sudo password now and keep alive for remainder of install."
# sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
# while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "\nHello $(whoami)! This script will install all packages and software."
echo "It will also set all of your preferences and setup .dotfiles"

# Ask for ComputerName, HostName, LocalHostName for later in script
echo "\nWhat name do you want to set your ComputerName"
echo "HostName, LocalHostName, and NetBIOSName to?"
read name

# Ask to install python, ruby, go, rust, and transmission-cli
echo "\nDo you want to install python? (y/n)"
read install_python

echo "\nDo you want to install ruby? (y/n)"
read install_ruby

echo "\nDo you want to install golang? (y/n)"
read install_go

echo "\nDo you want to install rust? (y/n)"
read install_rust

echo "\nDo you want to install transmission? (y/n)"
read install_transmission

echo "\nDo you want to install pentesting tools? (y/n)"
read install_pentest_tools

# dotfiles directory
dotfiledir=${homedir}/.dotfiles
export dotfiledir # allows variable to be passed to other scripts

# Run the Homebrew Script
echo "\nRunning Homebrew script to install formulae and applications."
zsh ${dotfiledir}/scripts/brew.zsh "$install_python" "$install_ruby" "$install_go" "$install_rust" "$install_transmission" "$install_pentest_tools"

# set shell history
echo "\nSetting up shell history"
setopt HIST_VERIFY # perform history expansion and reload line
setopt SHARE_HISTORY # each session shares history
setopt APPEND_HISTORY # each session appends history to file
setopt HISTIGNOREALLDUPS # ignore duplicates

# list of files to symlink in .gnupg
gpgfiles=('dirmngr.conf' 'gpg-agent.conf' 'gpg.conf')

# change to the .gnupg directory
echo "\nChanging to the .gnupg directory"
cd ${homedir}/.gnupg
echo "...done"

# delete gpgfiles files within .gnupg folder
for file in ${gpgfiles}; do
	[ -f "$file" ] && rm -rf $file
	echo "\nDeleted $file from .gnupg directory."
done

# import gpg pub keyring
echo "\nImporting gpg public keyring"
gpg --import ${dotfiledir}/.gnupg/pub.asc

# create symlinks for dotfiles using GNU Stow
echo "\nCreating symlinks for dotfiles."
cd ${dotfiledir}
stow .

# Install SbarLua & Sketchybar Font
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.5/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)
brew services restart sketchybar

# start transmission-daemon
case $install_transmission in
    y|Y|yes|Yes)
        echo "\nStarting transmission-daemon"
        transmission-daemon --logfile ${homedir}/logs/transmission-daemon.log --config-dir ${homedir}/.config/transmission-daemon
        transmission-daemon
        ;;
    *) ;;
esac

# symlink airport
sudo ln -s /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport /usr/local/bin/airport

# configure powerlevel10k
echo "\nConfigure powerelevel10k"
p10k configure

# source zshrc file
echo "\nSourcing zshrc"
source ${homedir}/.zshrc

# allow touch id for sudo
sudo sed -i '' '2i\'$'\n''auth       sufficient     pam_tid.so'$'\n' /etc/pam.d/sudo

echo "\nNow making system modifications:"

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName $name
sudo scutil --set HostName $name
sudo scutil --set LocalHostName $name
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $name

# Set highlight color to green
# defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"
defaults write NSGlobalDomain AppleHighlightColor -string "0.6392156863 0.7450980392 0.5490196078"

# Always show scrollbars
# defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
# Possible values: `WhenScrolling`, `Automatic` and `Always`

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable the crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Set time to 24 hour time
defaults write com.apple.menuextra.clock DateFormat -string 'EEE MMM d  H:mm'

###############################################################################
# Screen                                                                      #
###############################################################################

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Downloads"

# Save screenshots in JPG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "jpg"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

# Set Documents as the default location for new Finder windows
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Documents"

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Finder: show hidden files by default
#defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`, `Nlsv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
# defaults write com.apple.finder FXInfoPanesExpanded -dict \
#   General -bool true \
#   OpenWith -bool true \
#   Privileges -bool true

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

# Automatically hide and show the Menu Bar
defaults write NSGlobalDomain _HIHideMenuBar -bool true

# Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# Set the icon size of Dock items to 32 pixels
defaults write com.apple.dock tilesize -int 32

# Change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Wipe all (default) app icons from the Dock
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array

# Show only open applications in the Dock
# defaults write com.apple.dock static-only -bool true

# Don’t animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0.6

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Move Dock to left side
defaults write com.apple.dock orientation -string "left"

# Hide recent applications
defaults write com.apple.dock show-recents -bool false

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Disable the Launchpad gesture (pinch with thumb and three fingers)
defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

# Hot corners
# Possible values:
# 13: Lock Screen
# 14: Quick Note
# 1048576 is ⌘
# 524288 is ⌥ 
# Top left screen corner → Desktop
# defaults write com.apple.dock wvous-tl-corner -int 4
# defaults write com.apple.dock wvous-tl-modifier -int 1048576
# Top right screen corner → Desktop
# defaults write com.apple.dock wvous-tr-corner -int 4
# defaults write com.apple.dock wvous-tr-modifier -int 1048576
# Bottom left screen corner → Lock Screen
defaults write com.apple.dock wvous-bl-corner -int 13
defaults write com.apple.dock wvous-bl-modifier -int 524288
# Bottom right screen corner → Quick Note
defaults write com.apple.dock wvous-br-corner -int 14
defaults write com.apple.dock wvous-br-modifier -int 0

# Add Spark to Dock
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/Spark.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>'

# Add Messages to Dock
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///System/Applications/Messages.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>'

# Add Signal to Dock
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/Signal.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>'

# Add Safari to Dock
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/Safari.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>'

# Add Tor Browser to Dock
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/Tor%20Browser.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>'

# Add iTerm to Dock
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/iTerm.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>'

# Add Veracrypt to Dock
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/VeraCrypt.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>'

# Add Applications to Dock
defaults write com.apple.dock persistent-others -array-add '<dict><key>tile-data</key><dict><key>arrangement</key><integer>1</integer><key>displayas</key><integer>1</integer><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/</string><key>_CFURLStringType</key><integer>15</integer></dict><key>file-type</key><integer>2</integer><key>showas</key><integer>3</integer></dict><key>tile-type</key><string>directory-tile</string></dict>'

# Add Documents to Dock
defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-data</key><dict><key>arrangement</key><integer>1</integer><key>displayas</key><integer>1</integer><key>file-data</key><dict><key>_CFURLString</key><string>file:///${HOME}/Documents/</string><key>_CFURLStringType</key><integer>15</integer></dict><key>file-type</key><integer>2</integer><key>showas</key><integer>3</integer></dict><key>tile-type</key><string>directory-tile</string></dict>"

# Add Downloads to Dock
defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-data</key><dict><key>arrangement</key><integer>1</integer><key>displayas</key><integer>1</integer><key>file-data</key><dict><key>_CFURLString</key><string>file:///${HOME}/Downloads/</string><key>_CFURLStringType</key><integer>15</integer></dict><key>file-type</key><integer>2</integer><key>showas</key><integer>3</integer></dict><key>tile-type</key><string>directory-tile</string></dict>"

###############################################################################
# Spotlight                                                                   #
###############################################################################

# Hide Spotlight tray-icon (and subsequent helper)
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1

###############################################################################
# Contacts								      #
###############################################################################

# Change sorting order in Contacts
defaults write com.apple.AddressBook ABNameSortingFormat -string 'sortingFirstName sortingLastName'

###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in "Contacts" \
  "Dock" \
  "Finder" \
  "Safari" \
  "SystemUIServer"; do
  killall "${app}" &>/dev/null
done
echo "Done. Note that some of these changes require a logout/restart to take effect."


printf "TODO:\n\
login to: \n\
  1Password \n\
  Little Snitch \n\
  LogTen Pro X \n\
  Micro Snitch \n\
  Microsoft Office \n\
  Plex \n\
  Private Internet Access \n\
  Signal \n\
  Spark \n\
\n\
setup: \n\
  NVIM \n\
  Obsidian \n\
  OpenVPN \n\
  Raycast \n\
  Unsplash Wallpapers \n\
  Yubikey MacOS Login (https://support.yubico.com/hc/en-us/articles/360016649059) \n\
\n\
Installation complete.\n\
"
ntfy -t "$(hostname)" send "Installion of $name completed at $(date +%Y/%m/%d-%H:%M:%S)."

exit
