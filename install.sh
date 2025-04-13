#!/usr/bin/env bash

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
  print_error "Usage: install.sh <home_directory>"
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
read -p "$(printf "${CYAN}${GEAR} Enter computer name: ${NC}")" name

# Installation options
print_header "Installation Options"
read -p "$(printf "${CYAN}${GEAR} Install Python? (y/n): ${NC}")" install_python
read -p "$(printf "${CYAN}${GEAR} Install Ruby? (y/n): ${NC}")" install_ruby
read -p "$(printf "${CYAN}${GEAR} Install Go? (y/n): ${NC}")" install_go
read -p "$(printf "${CYAN}${GEAR} Install Rust? (y/n): ${NC}")" install_rust
read -p "$(printf "${CYAN}${GEAR} Install pentesting tools? (y/n): ${NC}")" install_pentest_tools

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
bash ${dotfiledir}/scripts/brew.sh "$install_python" "$install_ruby" "$install_go" "$install_rust" "$install_transmission" "$install_pentest_tools"

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
stow .
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
p10k configure
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
