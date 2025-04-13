#!/usr/bin/env zsh

################################################################################
#                        🚀 macOS System Setup Script                           #
# This script installs all packages and software, sets system preferences,     #
# configures applications, and links dotfiles. Works on both Intel and ARM.    #
################################################################################

# Set strict error handling
set -e

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Icons
CHECK="✓"
WARN="⚠️"
INFO="ℹ️"
ARROW="→"
STAR="⭐"
GEAR="⚙️"
LOCK="🔒"

# Print functions
print_header() {
  printf "\n${BLUE}${STAR} %s ${STAR}${NC}\n" "$1"
}

print_step() {
  printf "${CYAN}${ARROW} %s${NC}\n" "$1"
}

print_success() {
  printf "${GREEN}${CHECK} %s${NC}\n" "$1"
}

print_warning() {
  printf "${YELLOW}${WARN} %s${NC}\n" "$1"
}

print_error() {
  printf "${RED}${WARN} %s${NC}\n" "$1"
}

print_info() {
  printf "${PURPLE}${INFO} %s${NC}\n" "$1"
}

# Check arguments
if [ "$#" -ne 1 ]; then
  print_error "Usage: install.zsh <home_directory>"
  exit 1
fi

homedir=$1
export homedir
dotfiledir=${homedir}/.dotfiles
export dotfiledir

# Print welcome message
print_header "Welcome to the macOS System Setup Script!"
print_info "This script will set up your macOS system with all necessary software and configurations."

# Ask for sudo upfront
print_step "Requesting administrator privileges..."
sudo -v

# Keep sudo alive
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

# Prevent system sleep during install
print_step "Preventing system sleep during installation..."
/usr/bin/caffeinate -d &

# Check and setup logging
print_step "Setting up logging..."
[ ! -d $HOME/logs ] && mkdir $HOME/logs
exec 1> >(tee $HOME/logs/install.log) 2>&1
print_success "Logs will be saved to $HOME/logs/install.log"

# Close System Preferences
print_step "Closing System Preferences..."
osascript -e 'tell application "System Preferences" to quit'

# Check for Xcode Command Line Tools
print_step "Checking for Xcode Command Line Tools..."
if [ $(
  xcode-select -p 1>/dev/null
  echo $?
) != 0 ]; then
  print_warning "Installing Xcode Command Line Tools..."
  sudo xcodebuild -license accept
  print_success "Xcode Command Line Tools installed"
else
  print_success "Xcode Command Line Tools already installed"
fi

# Check for ARM and install Rosetta if needed
if [ $(uname -a | awk '{print $(NF)}') = 'arm64' ]; then
  print_step "ARM processor detected, installing Rosetta 2..."
  /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  print_success "Rosetta 2 installed"
fi

# Get computer name
print_step "Setting up computer identity..."
while true; do
    read "name?$(printf "${CYAN}${GEAR} Enter computer name: ${NC}")"
    if [ -z "$name" ]; then
        print_warning "Computer name cannot be empty. Please try again."
    else
        break
    fi
done

# Installation options with defaults
print_header "Installation Options"
read "install_python?$(printf "${CYAN}${GEAR} Install Python? (y/n) [y]: ${NC}")"
install_python=${install_python:-y}

read "install_ruby?$(printf "${CYAN}${GEAR} Install Ruby? (y/n) [n]: ${NC}")"
install_ruby=${install_ruby:-n}

read "install_go?$(printf "${CYAN}${GEAR} Install Go? (y/n) [n]: ${NC}")"
install_go=${install_go:-n}

read "install_rust?$(printf "${CYAN}${GEAR} Install Rust? (y/n) [n]: ${NC}")"
install_rust=${install_rust:-n}

read "install_pentest_tools?$(printf "${CYAN}${GEAR} Install pentesting tools? (y/n) [n]: ${NC}")"
install_pentest_tools=${install_pentest_tools:-n}

# Setup dotfiles
print_header "Setting up dotfiles"
print_step "Checking repository type..."

# Check if private repository
if [[ "$(git config --get remote.origin.url)" == *"git@github.com"* ]]; then
  print_info "Private repository detected"
  print_step "Initializing private repository..."
  git submodule init
  git submodule update
  print_success "Private files initialized"
else
  print_info "Public repository detected, skipping private files"
fi

# Run Homebrew script
print_header "Installing Software"
print_step "Running Homebrew installation..."
zsh ${dotfiledir}/scripts/brew.sh "$install_python" "$install_ruby" "$install_go" "$install_rust" "$install_transmission" "$install_pentest_tools"

# Setup shell history
print_header "Configuring Shell"
print_step "Setting up shell history..."
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HISTIGNOREALLDUPS
print_success "Shell history configured"

# Setup GPG
print_header "Setting up GPG"
if [[ "$(git config --get remote.origin.url)" == *"git@github.com"* ]]; then
  print_step "Configuring GPG..."
  gpgfiles=('dirmngr.conf' 'gpg-agent.conf' 'gpg.conf')
  cd ${homedir}/.gnupg
  for file in ${gpgfiles}; do
    [ -f "$file" ] && rm -rf $file
    print_info "Removed $file"
  done
  print_step "Importing GPG public keyring..."
  gpg --import ${dotfiledir}/.gnupg/pub.asc
  print_success "GPG configured"
else
  print_info "Skipping GPG setup (public repository)"
fi

# Install LazyVim
print_header "Setting up Neovim"
print_step "Installing LazyVim..."
rm -rf ~/.config/nvim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
rm -rf ~/.config/nvim/lua
print_success "LazyVim installed"

# Create symlinks
print_header "Creating Symlinks"
print_step "Running stow..."
cd ${dotfiledir}
/opt/homebrew/bin/stow .
print_success "Symlinks created"

# Install SbarLua & Sketchybar Font
print_header "Setting up Sketchybar"
print_step "Installing custom font and SbarLua..."
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.5/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)
brew services restart sketchybar
print_success "Sketchybar setup complete"

# Configure powerlevel10k
print_header "Setting up Shell Theme"
print_step "Configuring Powerlevel10k..."
# Create powerlevel10k configuration directory if it doesn't exist
mkdir -p "${homedir}/.cache"
# Create a basic .p10k.zsh file if it doesn't exist
if [ ! -f "${homedir}/.p10k.zsh" ]; then
    cat > "${homedir}/.p10k.zsh" << 'EOL'
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOL
fi
print_success "Powerlevel10k configured"

# Source zshrc
print_step "Sourcing zshrc..."
source ${homedir}/.zshrc
print_success "Shell configuration loaded"

# Configure Touch ID for sudo
print_header "Configuring Security"
print_step "Setting up Touch ID for sudo..."
sudo sed -i '' '2i\'$'\n''auth       sufficient     pam_tid.so'$'\n' /etc/pam.d/sudo
print_success "Touch ID configured for sudo"

# System Modifications
print_header "Configuring System Preferences"

###############################################################################
# General UI/UX                                                               #
###############################################################################

print_header "Configuring General UI/UX Settings"

# Set computer name and network identity
print_step "Setting computer name..."
sudo scutil --set ComputerName $name
sudo scutil --set HostName $name
sudo scutil --set LocalHostName $name
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $name
print_success "Computer name set to: $name"

# Set highlight color
print_step "Applying custom UI colors..."
defaults write NSGlobalDomain AppleHighlightColor -string "0.6392156863 0.7450980392 0.5490196078"
print_success "Highlight color customized"

# Expand save panel by default
print_step "Expanding save dialogs..."
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
print_success "Save panels will be expanded by default"

# Expand print panel by default
print_step "Expanding print dialogs..."
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
print_success "Print panels will be expanded by default"

# Auto-quit printer app
print_step "Configuring printer behavior..."
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
print_success "Print app will quit when finished"

# Disable "Are you sure you want to open this application?" dialog
print_step "Adjusting security dialogs..."
defaults write com.apple.LaunchServices LSQuarantine -bool false
print_success "App security warnings disabled"

# Disable crash reporter
print_step "Configuring crash reporting..."
defaults write com.apple.CrashReporter DialogType -string "none"
print_success "Crash reporter dialogs disabled"

# Show system info in login window
print_step "Customizing login window..."
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
print_success "System info enabled in login window"

# Set 24-hour time
print_step "Setting time format..."
defaults write com.apple.menuextra.clock DateFormat -string 'EEE MMM d  H:mm'
print_success "24-hour time format enabled"

###############################################################################
# Screen                                                                      #
###############################################################################

print_header "Configuring Screen Settings"

# Screen lock settings
print_step "Configuring screen security..."
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
print_success "Immediate password requirement enabled for screensaver"

# Screenshot settings
print_step "Setting up screenshots..."
defaults write com.apple.screencapture location -string "${HOME}/Downloads"
defaults write com.apple.screencapture type -string "jpg"
defaults write com.apple.screencapture disable-shadow -bool true
print_success "Screenshots configured: JPG format, no shadow, saved to Downloads"

###############################################################################
# Finder                                                                      #
###############################################################################

print_header "Configuring Finder Settings"

# Set default location
print_step "Setting default Finder location..."
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Documents"
print_success "New Finder windows will open to Documents"

# Configure desktop icons
print_step "Configuring desktop icons..."
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
print_success "Desktop icons configured"

# Show file extensions
print_step "Adjusting file visibility..."
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
print_success "File extensions will be shown"

# Show status bar and path bar
print_step "Enhancing Finder interface..."
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
print_success "Status bar and path bar enabled"

# Keep folders on top when sorting
print_step "Setting sort preferences..."
defaults write com.apple.finder _FXSortFoldersFirst -bool true
print_success "Folders will appear first in sorting"

# Search current folder by default
print_step "Configuring search behavior..."
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
print_success "Search will default to current folder"

###############################################################################
# Dock & Menu Bar                                                             #
###############################################################################

print_header "Configuring Dock and Menu Bar"

# Dock settings
print_step "Configuring Dock..."
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock "autohide-delay" -float 0
defaults write com.apple.dock "autohide-time-modifier" -float 0.5
defaults write com.apple.dock "enable-spring-load-actions-on-all-items" -bool true
defaults write com.apple.dock "expose-animation-duration" -float 0.1
defaults write com.apple.dock "expose-group-apps" -bool false
defaults write com.apple.dock largesize -int 128
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock loc -string "en_US:US"
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock "minimize-to-application" -bool true
defaults write com.apple.dock "mouse-over-hilite-stack" -bool true
defaults write com.apple.dock "mru-spaces" -bool false
defaults write com.apple.dock "no-bouncing" -bool false
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock "show-process-indicators" -bool true
defaults write com.apple.dock "show-recents" -bool false
defaults write com.apple.dock showLaunchpadGestureEnabled -bool false
defaults write com.apple.dock showhidden -bool true
defaults write com.apple.dock tilesize -int 32

# Disable click wallpaper to show desktop
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# Hot corners
defaults write com.apple.dock "wvous-bl-corner" -int 13
defaults write com.apple.dock "wvous-bl-modifier" -int 524288
defaults write com.apple.dock "wvous-br-corner" -int 14
defaults write com.apple.dock "wvous-br-modifier" -int 0
defaults write com.apple.dock "wvous-tl-corner" -int 1
defaults write com.apple.dock "wvous-tl-modifier" -int 0
defaults write com.apple.dock "wvous-tr-corner" -int 0
defaults write com.apple.dock "wvous-tr-modifier" -int 0

# Clear existing Dock items
print_step "Clearing existing Dock items..."
defaults delete com.apple.dock persistent-apps
defaults delete com.apple.dock persistent-others

# Add applications to Dock
print_step "Adding applications to Dock..."
dock_item() {
    printf '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>%s</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>', "$1"
}

Mail=$(dock_item "file:///System/Applications/Mail.app/")
Outlook=$(dock_item "file:///Applications/Microsoft%20Outlook.app/")
Spark=$(dock_item "file:///Applications/Spark.app/")
Calendars=$(dock_item "file:///Applications/Calendars.app/")
Calendar=$(dock_item "file:///System/Applications/Calendar.app/")
Messages=$(dock_item "file:///System/Applications/Messages.app/")
Discord=$(dock_item "file:///Applications/Discord.app/")
Signal=$(dock_item "file:///Applications/Signal.app/")
Safari=$(dock_item "file:///System/Cryptexes/App/System/Applications/Safari.app/")
Notes=$(dock_item "file:///System/Applications/Notes.app/")
iTerm=$(dock_item "file:///Applications/iTerm.app/")

# Add folders to Dock with proper attributes
print_step "Adding folders to Dock..."
dock_folder() {
    printf '<dict><key>tile-data</key><dict><key>arrangement</key><integer>1</integer><key>displayas</key><integer>1</integer><key>file-data</key><dict><key>_CFURLString</key><string>%s</string><key>_CFURLStringType</key><integer>15</integer></dict><key>file-label</key><string>%s</string><key>file-type</key><integer>2</integer><key>is-beta</key><integer>0</integer><key>preferreditemsize</key><string>-1</string><key>showas</key><integer>3</integer></dict><key>tile-type</key><string>directory-tile</string></dict>', "$1" "$2"
}

Applications=$(dock_folder "file:///Applications/" "Applications")
Documents=$(dock_folder "file:///Users/matthammond/Documents/" "Documents")
Downloads=$(dock_folder "file:///Users/matthammond/Downloads/" "Downloads")

# Set Dock items
defaults write com.apple.dock persistent-apps -array "$Mail" "$Outlook" "$Spark" "$Calendars" "$Calendar" "$Messages" "$Discord" "$Signal" "$Safari" "$Notes" "$iTerm"
defaults write com.apple.dock persistent-others -array "$Applications" "$Documents" "$Downloads"

print_success "Dock configured"

# Menu Bar settings
print_step "Configuring Menu Bar..."
defaults write NSGlobalDomain _HIHideMenuBar -bool true
print_success "Menu Bar will auto-hide"

# Restart Dock and Finder to apply changes
print_step "Applying UI changes..."
killall Dock
killall Finder
print_success "UI changes applied"

# Function to create spaces
create_spaces() {
    print_step "Creating spaces..."
    
    # Generate UUIDs for the spaces
    space1_uuid=$(uuidgen)
    space2_uuid=$(uuidgen)
    space3_uuid=$(uuidgen)
    space4_uuid=$(uuidgen)
    space5_uuid=$(uuidgen)
    space6_uuid=$(uuidgen)
    space7_uuid=$(uuidgen)
    
    # Create a temporary plist file
    cat > /tmp/spaces.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>SpacesDisplayConfiguration</key>
    <dict>
        <key>Management Data</key>
        <dict>
            <key>Age</key>
            <string>0</string>
            <key>Management Mode</key>
            <integer>1</integer>
            <key>Monitors</key>
            <array>
                <dict>
                    <key>Current Space</key>
                    <dict>
                        <key>ManagedSpaceID</key>
                        <integer>3</integer>
                        <key>id64</key>
                        <integer>3</integer>
                        <key>type</key>
                        <integer>0</integer>
                        <key>uuid</key>
                        <string>${space1_uuid}</string>
                    </dict>
                    <key>Display Identifier</key>
                    <string>Main</string>
                    <key>Spaces</key>
                    <array>
                        <dict>
                            <key>ManagedSpaceID</key>
                            <integer>1</integer>
                            <key>id64</key>
                            <integer>1</integer>
                            <key>type</key>
                            <integer>0</integer>
                            <key>uuid</key>
                            <string></string>
                            <key>wsid</key>
                            <integer>1</integer>
                        </dict>
                        <dict>
                            <key>ManagedSpaceID</key>
                            <integer>3</integer>
                            <key>id64</key>
                            <integer>3</integer>
                            <key>type</key>
                            <integer>0</integer>
                            <key>uuid</key>
                            <string>${space1_uuid}</string>
                        </dict>
                        <dict>
                            <key>ManagedSpaceID</key>
                            <integer>4</integer>
                            <key>id64</key>
                            <integer>4</integer>
                            <key>type</key>
                            <integer>0</integer>
                            <key>uuid</key>
                            <string>${space2_uuid}</string>
                        </dict>
                        <dict>
                            <key>ManagedSpaceID</key>
                            <integer>5</integer>
                            <key>id64</key>
                            <integer>5</integer>
                            <key>type</key>
                            <integer>0</integer>
                            <key>uuid</key>
                            <string>${space3_uuid}</string>
                        </dict>
                        <dict>
                            <key>ManagedSpaceID</key>
                            <integer>6</integer>
                            <key>id64</key>
                            <integer>6</integer>
                            <key>type</key>
                            <integer>0</integer>
                            <key>uuid</key>
                            <string>${space4_uuid}</string>
                        </dict>
                        <dict>
                            <key>ManagedSpaceID</key>
                            <integer>7</integer>
                            <key>id64</key>
                            <integer>7</integer>
                            <key>type</key>
                            <integer>0</integer>
                            <key>uuid</key>
                            <string>${space5_uuid}</string>
                        </dict>
                        <dict>
                            <key>ManagedSpaceID</key>
                            <integer>8</integer>
                            <key>id64</key>
                            <integer>8</integer>
                            <key>type</key>
                            <integer>0</integer>
                            <key>uuid</key>
                            <string>${space6_uuid}</string>
                        </dict>
                        <dict>
                            <key>ManagedSpaceID</key>
                            <integer>9</integer>
                            <key>id64</key>
                            <integer>9</integer>
                            <key>type</key>
                            <integer>0</integer>
                            <key>uuid</key>
                            <string>${space7_uuid}</string>
                        </dict>
                    </array>
                </dict>
            </array>
            <key>Primary</key>
            <dict>
                <key>CreatedCount</key>
                <integer>0</integer>
                <key>DeletedCount</key>
                <integer>0</integer>
                <key>LifetimeEntryCount</key>
                <integer>0</integer>
                <key>LifetimeMax</key>
                <integer>0</integer>
                <key>LifetimeMin</key>
                <integer>0</integer>
                <key>LifetimeSum</key>
                <integer>0</integer>
                <key>PersistedCount</key>
                <integer>0</integer>
            </dict>
            <key>Secondary</key>
            <dict>
                <key>CreatedCount</key>
                <integer>0</integer>
                <key>DeletedCount</key>
                <integer>0</integer>
                <key>LifetimeEntryCount</key>
                <integer>0</integer>
                <key>LifetimeMax</key>
                <integer>0</integer>
                <key>LifetimeMin</key>
                <integer>0</integer>
                <key>LifetimeSum</key>
                <integer>0</integer>
                <key>PersistedCount</key>
                <integer>0</integer>
            </dict>
        </dict>
        <key>Space Properties</key>
        <array>
            <dict>
                <key>name</key>
                <string></string>
                <key>windows</key>
                <array>
                    <integer>39694</integer>
                    <integer>10</integer>
                    <integer>9</integer>
                    <integer>8</integer>
                    <integer>7</integer>
                    <integer>40789</integer>
                    <integer>74</integer>
                </array>
            </dict>
            <dict>
                <key>name</key>
                <string>${space1_uuid}</string>
                <key>windows</key>
                <array>
                    <integer>39694</integer>
                    <integer>12335</integer>
                    <integer>8073</integer>
                    <integer>130</integer>
                    <integer>131</integer>
                    <integer>132</integer>
                    <integer>10</integer>
                    <integer>9</integer>
                    <integer>8</integer>
                    <integer>7</integer>
                    <integer>40789</integer>
                    <integer>13430</integer>
                </array>
            </dict>
            <dict>
                <key>name</key>
                <string>${space2_uuid}</string>
                <key>windows</key>
                <array>
                    <integer>39694</integer>
                    <integer>10</integer>
                    <integer>9</integer>
                    <integer>8</integer>
                    <integer>7</integer>
                    <integer>40789</integer>
                    <integer>39859</integer>
                    <integer>78</integer>
                    <integer>21294</integer>
                    <integer>21304</integer>
                    <integer>21301</integer>
                </array>
            </dict>
            <dict>
                <key>name</key>
                <string>${space3_uuid}</string>
                <key>windows</key>
                <array>
                    <integer>39694</integer>
                    <integer>10</integer>
                    <integer>9</integer>
                    <integer>8</integer>
                    <integer>7</integer>
                    <integer>40789</integer>
                    <integer>920</integer>
                    <integer>39563</integer>
                    <integer>36469</integer>
                    <integer>40875</integer>
                    <integer>38732</integer>
                </array>
            </dict>
            <dict>
                <key>name</key>
                <string>${space4_uuid}</string>
                <key>windows</key>
                <array>
                    <integer>39694</integer>
                    <integer>10</integer>
                    <integer>9</integer>
                    <integer>8</integer>
                    <integer>7</integer>
                    <integer>40789</integer>
                    <integer>111</integer>
                </array>
            </dict>
            <dict>
                <key>name</key>
                <string>${space5_uuid}</string>
                <key>windows</key>
                <array>
                    <integer>39694</integer>
                    <integer>10</integer>
                    <integer>9</integer>
                    <integer>8</integer>
                    <integer>7</integer>
                    <integer>40789</integer>
                    <integer>21779</integer>
                    <integer>150</integer>
                    <integer>262</integer>
                </array>
            </dict>
            <dict>
                <key>name</key>
                <string>${space6_uuid}</string>
                <key>windows</key>
                <array>
                    <integer>39694</integer>
                    <integer>10</integer>
                    <integer>9</integer>
                    <integer>8</integer>
                    <integer>7</integer>
                    <integer>40789</integer>
                    <integer>66</integer>
                </array>
            </dict>
            <dict>
                <key>name</key>
                <string>${space7_uuid}</string>
                <key>windows</key>
                <array>
                    <integer>39694</integer>
                    <integer>10</integer>
                    <integer>9</integer>
                    <integer>8</integer>
                    <integer>7</integer>
                    <integer>40789</integer>
                    <integer>66</integer>
                </array>
            </dict>
        </array>
    </dict>
    <key>app-bindings</key>
    <dict>
        <key>com.apple.ical</key>
        <string>${space7_uuid}</string>
        <key>com.apple.mail</key>
        <string>${space5_uuid}</string>
        <key>com.apple.mobilesms</key>
        <string>${space2_uuid}</string>
        <key>com.apple.notes</key>
        <string></string>
        <key>com.apple.safari</key>
        <string>${space1_uuid}</string>
        <key>com.hnc.discord</key>
        <string>${space2_uuid}</string>
        <key>com.microsoft.outlook</key>
        <string>${space5_uuid}</string>
        <key>com.readdle.smartemail-mac</key>
        <string>${space5_uuid}</string>
        <key>org.whispersystems.signal-desktop</key>
        <string>${space2_uuid}</string>
    </dict>
</dict>
</plist>
EOF

    # Import the plist file
    defaults import com.apple.spaces /tmp/spaces.plist
    
    # Clean up
    rm /tmp/spaces.plist
    
    print_success "Spaces configuration created"
    
    # Restart Dock to apply changes
    killall Dock
}

# Call the function after Dock configuration
create_spaces

###############################################################################
# Final Steps & Manual To-Do List                                             #
###############################################################################

print_header "Final Steps & Manual To-Do List ${STAR}"

print_info "The following items need to be completed manually:"

print_step "System Preferences:"
echo "  ${ARROW} Sign in to Apple ID"
echo "  ${ARROW} Configure Apple ID preferences"
echo "  ${ARROW} Set up iCloud services"
echo "  ${ARROW} Configure Time Machine backup"
echo "  ${ARROW} Set up Touch ID"
echo "  ${ARROW} Configure Keyboard shortcuts"
echo "  ${ARROW} Set up Hot Corners"
echo "  ${ARROW} Set up 7 Spaces/Desktops (Control + Up Arrow to add new spaces)"

print_step "Applications:"
echo "  ${ARROW} Sign in to 1Password"
echo "  ${ARROW} Configure iTerm2 to use custom profile"
echo "  ${ARROW} Set up GPG keys"
echo "  ${ARROW} Configure Git with GPG signing"
echo "  ${ARROW} Set up SSH keys"
echo "  ${ARROW} Sign in to browsers and set up sync"
echo "  ${ARROW} Configure Karabiner-Elements"
echo "  ${ARROW} Set up Little Snitch rules"
echo "  ${ARROW} Configure Raycast"

print_step "Development Environment:"
echo "  ${ARROW} Set up Python virtual environments"
echo "  ${ARROW} Configure Node.js environment"
echo "  ${ARROW} Set up Ruby gems"
echo "  ${ARROW} Initialize Go workspace"

print_step "Security:"
echo "  ${ARROW} Enable FileVault"
echo "  ${ARROW} Configure firewall settings"
echo "  ${ARROW} Set up VPN configurations"
echo "  ${ARROW} Review and adjust privacy settings"

print_warning "Please complete these steps to finish setting up your system"

print_header "Installation Complete! 🎉"
print_success "Your development environment has been set up successfully"
print_info "Please review the manual steps above to complete the configuration" 
