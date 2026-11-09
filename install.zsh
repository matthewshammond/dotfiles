#!/usr/bin/env zsh

################################################################################
#                        🚀 macOS System Setup Script                           #
# Installs all software, sets system preferences, configures applications and  #
# links dotfiles. Safe to re-run.                                              #
#                                                                              #
#   ./install.zsh          full setup                                          #
#   ./install.zsh --link   only copy private files + re-link dotfiles (stow)   #
################################################################################

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

# Print functions
print_header()  { printf "\n${BLUE}${STAR} %s ${STAR}${NC}\n" "$1" }
print_step()    { printf "${CYAN}${ARROW} %s${NC}\n" "$1" }
print_success() { printf "${GREEN}${CHECK} %s${NC}\n" "$1" }
print_warning() { printf "${YELLOW}${WARN} %s${NC}\n" "$1" }
print_error()   { printf "${RED}${WARN} %s${NC}\n" "$1" }
print_info()    { printf "${PURPLE}${INFO} %s${NC}\n" "$1" }

# Everything that goes wrong is collected here and shown in a summary at the end
failures=()
fail() { print_error "$1"; failures+=("$1") }
current_step="starting"
step() { current_step="$1"; print_header "$1" }

print_summary() {
  local exit_code=$1
  echo
  if (( exit_code != 0 )); then
    printf "${RED}╭──────────────────────────────────────────────────────────────╮${NC}\n"
    printf "${RED}│ ✗ Install stopped during: %-35s│${NC}\n" "$current_step"
    printf "${RED}╰──────────────────────────────────────────────────────────────╯${NC}\n"
    print_info "Fix the error above, then re-run ./install.zsh (it's safe to re-run)"
  fi
  if (( ${#failures} )); then
    printf "${YELLOW}╭──────────────────────────────────────────────────────────────╮${NC}\n"
    printf "${YELLOW}│ ⚠️  %-2d thing(s) need attention                               │${NC}\n" ${#failures}
    printf "${YELLOW}╰──────────────────────────────────────────────────────────────╯${NC}\n"
    local f; for f in $failures; do printf "${YELLOW}  • %s${NC}\n" "$f"; done
  elif (( exit_code == 0 )); then
    printf "${GREEN}╭──────────────────────────────────────────────────────────────╮${NC}\n"
    printf "${GREEN}│ ✓ Everything installed with no failures                      │${NC}\n"
    printf "${GREEN}╰──────────────────────────────────────────────────────────────╯${NC}\n"
  fi
}

ask() { # ask <var> <question> <default y|n>
  local reply
  read "reply?$(printf "${CYAN}${GEAR} %s (y/n) [%s]: ${NC}" "$2" "$3")"
  typeset -g "$1=${reply:-$3}"
}

# Run from the repo no matter where the script is called from
dotfiledir="${0:A:h}"
cd "$dotfiledir"
export dotfiledir

mode=full
[[ $1 == --link ]] && mode=link
trap 'print_summary $?' EXIT

timestamp=$(date +%Y%m%d-%H%M%S)
backupdir="$HOME/.dotfiles-backup/$timestamp"

# A clone made over SSH (git@github.com:...) is "my" machine and gets private
is_private_clone() {
  [[ "$(git -C "$dotfiledir" config --get remote.origin.url)" == git@github.com:* ]]
}

# The bootstrap key (pasted from 1Password) lives in macOS's built-in ssh-agent.
# Once ~/.ssh/config is linked it points every host at 1Password's agent, which
# isn't signed in yet on a fresh Mac - so prefer the built-in agent while it has a key.
use_bootstrap_agent() {
  if [[ -n $SSH_AUTH_SOCK ]] && ssh-add -l >/dev/null 2>&1; then
    export GIT_SSH_COMMAND="ssh -o IdentityAgent=\"$SSH_AUTH_SOCK\""
  fi
}

###############################################################################
# Private repo                                                                #
###############################################################################

# Files from the private submodule that get copied into the repo root so stow
# links them. Keep this in sync with gpc in aliases.zsh.
private_items=(.gitconfig .ntfy.yml .ssh .gnupg .config/asciinema .config/gh)

setup_private() {
  step "Private files"
  if ! is_private_clone; then
    print_info "Public clone (https) - skipping private files"
    return 0
  fi

  print_step "Fetching private submodule..."
  use_bootstrap_agent
  if ! git -c submodule.private.update=checkout submodule update --init private; then
    print_error "Couldn't fetch the private repo. Is your SSH key loaded? (ssh-add -l)"
    exit 1
  fi

  # Copy each private file into the repo root unless a different local copy
  # already exists (that would be an edit not yet saved with gpc - never clobber it)
  local item f src dst
  for item in $private_items; do
    [[ -e private/$item ]] || continue
    for f in ${(f)"$(cd private && find "$item" -type f ! -name .DS_Store)"}; do
      src="private/$f"
      dst="$f"
      if [[ ! -e $dst ]]; then
        mkdir -p "${dst:h}"
        cp -p "$src" "$dst"
        print_success "Copied private file: $f"
      elif ! cmp -s "$src" "$dst"; then
        fail "$f differs from private copy - kept the local one (save it with: gpc $f \"msg\")"
      fi
    done
  done
}

###############################################################################
# Link dotfiles with stow                                                     #
###############################################################################

link_dotfiles() {
  step "Linking dotfiles"

  # These must be real directories. If they don't exist, stow would turn the
  # whole directory into a symlink into this repo, and everything apps write
  # there (Claude history and credentials, ssh known_hosts, gpg keyrings, gh
  # tokens) would land inside the public repo's working tree.
  mkdir -p ~/.config ~/.claude ~/.config/gh ~/.config/herdr ~/.ssh ~/.gnupg
  chmod 700 ~/.ssh ~/.gnupg

  local stow=(/opt/homebrew/bin/stow --dir="$dotfiledir" --target="$HOME")

  # Clear anything stow would refuse to replace. Two kinds of conflict:
  #  - "over existing target X since..."      a real file -> move it to the backup folder
  #  - "existing target is not owned by stow: X"  usually an old hand-made symlink into
  #    this repo -> just remove the link (stow recreates it); anything else is backed up
  local target conflicts
  conflicts=$($stow -n --restow . 2>&1 || true)
  for target in ${(f)"$(print -r -- "$conflicts" | sed -n \
      -e 's/.* over existing target \(.*\) since .*/\1/p' \
      -e 's/.*existing target is not owned by stow: \(.*\)$/\1/p')"}; do
    local p="$HOME/$target"
    if [[ -L $p && ${p:A} == $dotfiledir/* ]]; then
      rm "$p"
    else
      mkdir -p "$backupdir/${target:h}"
      mv "$HOME/$target" "$backupdir/$target"
      print_info "Backed up existing ~/$target to $backupdir"
    fi
  done

  print_step "Running stow..."
  $stow --restow .
  print_success "Dotfiles linked"
}

if [[ $mode == link ]]; then
  setup_private
  link_dotfiles
  print_success "Done - dotfiles re-linked"
  exit 0
fi

###############################################################################
# Full install starts here                                                    #
###############################################################################

print_header "Welcome to the macOS System Setup Script!"
print_info "This script will set up your macOS system with all necessary software and configurations."

# Ask for sudo upfront and keep it alive
print_step "Requesting administrator privileges..."
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!

# Prevent system sleep during install
/usr/bin/caffeinate -d &
CAFFEINATE_PID=$!
trap 'kill $CAFFEINATE_PID $SUDO_KEEPALIVE_PID 2>/dev/null; print_summary $?' EXIT

# Logging
mkdir -p "$HOME/logs"
exec > >(tee "$HOME/logs/install.log") 2>&1
print_success "Logs will be saved to $HOME/logs/install.log"

osascript -e 'quit app "System Settings"' 2>/dev/null || true

# Xcode Command Line Tools (git needs these, so they're normally already here)
print_step "Checking for Xcode Command Line Tools..."
if ! xcode-select -p >/dev/null 2>&1; then
  print_warning "Installing Xcode Command Line Tools - finish the dialog that pops up..."
  xcode-select --install || true
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi
print_success "Xcode Command Line Tools installed"

# Rosetta 2 (some apps still need it on Apple Silicon)
if [[ $(uname -m) == arm64 ]] && ! /usr/bin/pgrep -q oahd; then
  print_step "Installing Rosetta 2..."
  /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  print_success "Rosetta 2 installed"
fi

# Computer name
print_step "Setting up computer identity..."
while true; do
  read "name?$(printf "${CYAN}${GEAR} Enter computer name: ${NC}")"
  [[ -n $name ]] && break
  print_warning "Computer name cannot be empty. Please try again."
done

# Installation options (used by conditional lines in the Brewfile)
print_header "Installation Options"
ask INSTALL_PYTHON "Install Python?" y
ask INSTALL_RUBY   "Install Ruby?"   n
ask INSTALL_GO     "Install Go?"     n
ask INSTALL_RUST   "Install Rust?"   n
export INSTALL_PYTHON INSTALL_RUBY INSTALL_GO INSTALL_RUST

###############################################################################
# Private files and projects first - they need the bootstrap SSH key, which   #
# only lasts an hour, and the Homebrew step can take longer than that         #
###############################################################################

setup_private

clone_projects() {
  local list="$dotfiledir/private/repos.txt"
  [[ -f $list ]] || return 0
  step "Cloning projects into ~/projects"
  use_bootstrap_agent
  mkdir -p ~/projects
  local repo folder rest
  while read -r repo folder rest; do
    [[ -z $repo || $repo == \#* ]] && continue
    [[ -z $folder || $folder == \#* ]] && folder=$repo
    if [[ -d ~/projects/$folder/.git ]]; then
      print_info "Already cloned: $folder"
    elif git clone -q "git@github.com:matthewshammond/$repo.git" ~/projects/$folder; then
      print_success "Cloned $repo -> ~/projects/$folder"
    else
      fail "Couldn't clone $repo into ~/projects/$folder"
    fi
  done < "$list"
}
is_private_clone && clone_projects

###############################################################################
# Software                                                                    #
###############################################################################

current_step="Installing software (Homebrew)"
source "$dotfiledir/scripts/brew.zsh"

link_dotfiles

# GPG public key (private keys live on the YubiKey)
if is_private_clone && [[ -f $dotfiledir/.gnupg/pub.asc ]]; then
  step "Setting up GPG"
  /opt/homebrew/bin/gpg --import "$dotfiledir/.gnupg/pub.asc"
  print_success "GPG public key imported"
fi

# zsh-defer for lazy loading
if [[ ! -d ~/.zsh-defer ]]; then
  print_step "Installing zsh-defer..."
  git clone -q https://github.com/romkatv/zsh-defer.git ~/.zsh-defer
fi
print_success "zsh-defer installed"

# Neovim: install LazyVim plugins now so theme switching works on first use
step "Setting up Neovim"
nvim --headless "+Lazy! sync" +qa || fail "Neovim plugin install had errors - open nvim to retry"
print_success "Neovim plugins installed"

# Sketchybar: SbarLua + Simon Symbol font
step "Setting up Sketchybar"
rm -rf /tmp/SbarLua
git clone -q https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua
(cd /tmp/SbarLua && make install)
rm -rf /tmp/SbarLua
mkdir -p "$HOME/Library/Fonts"
cp "$dotfiledir/.config/sketchybar/icons/simon/SimonSymbol.otf" "$HOME/Library/Fonts/"
brew services restart sketchybar || true
print_success "Sketchybar setup complete"

# Übersicht flip-clock widget
widgets="$HOME/Library/Application Support/Übersicht/widgets"
mkdir -p "$widgets"
cp -R "$dotfiledir/.config/Übersicht/widgets/flip-clock.widget" "$widgets/"
print_success "Übersicht flip-clock widget installed"

# Touch ID for sudo (sudo_local survives macOS updates; /etc/pam.d/sudo doesn't)
step "Configuring Security"
if ! grep -qs pam_tid /etc/pam.d/sudo_local; then
  echo "auth       sufficient     pam_tid.so" | sudo tee -a /etc/pam.d/sudo_local >/dev/null
fi
print_success "Touch ID configured for sudo"

# yabai's scripting addition is loaded with 'sudo yabai --load-sa' from yabairc,
# so allow exactly this yabai binary to do that without a password
# (update_yabai in aliases.zsh refreshes the hash after upgrades)
yabai_bin=$(command -v yabai || true)
if [[ -n $yabai_bin ]]; then
  echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 "$yabai_bin" | cut -d ' ' -f 1) $yabai_bin --load-sa" \
    | sudo tee /private/etc/sudoers.d/yabai >/dev/null
  sudo visudo -cf /private/etc/sudoers.d/yabai >/dev/null || { sudo rm -f /private/etc/sudoers.d/yabai; fail "yabai sudoers entry was invalid and was removed"; }
  print_success "yabai can load its scripting addition"
else
  fail "yabai not installed - skipped its sudoers entry"
fi

###############################################################################
# System Preferences                                                          #
###############################################################################

step "Configuring System Preferences"

# Cmd+1..8 switches to Desktop 1..8 (sketchybar space clicks send these keys)
print_step "Setting Cmd+1..8 to switch desktops..."
space_keycodes=(18 19 20 21 23 22 26 28)
for i in {1..8}; do
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add $((117 + i)) \
    "<dict><key>enabled</key><true/><key>value</key><dict><key>type</key><string>standard</string><key>parameters</key><array><integer>$((48 + i))</integer><integer>${space_keycodes[$i]}</integer><integer>1048576</integer></array></dict></dict>"
done
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
print_success "Cmd+1..8 desktop shortcuts set"

###############################################################################
# General UI/UX                                                               #
###############################################################################

step "Configuring General UI/UX Settings"

print_step "Setting computer name..."
sudo scutil --set ComputerName "$name"
sudo scutil --set HostName "$name"
sudo scutil --set LocalHostName "$name"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$name"
print_success "Computer name set to: $name"

print_step "Applying custom UI colors..."
defaults write NSGlobalDomain AppleHighlightColor -string "0.6392156863 0.7450980392 0.5490196078"

print_step "Expanding save and print dialogs..."
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

print_step "Adjusting security dialogs..."
defaults write com.apple.LaunchServices LSQuarantine -bool false
defaults write com.apple.CrashReporter DialogType -string "none"

print_step "Customizing login window..."
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

print_step "Turning off Siri..."
defaults write com.apple.assistant.support "Assistant Enabled" -bool false
defaults write com.apple.Siri StatusMenuVisible -bool false
defaults write com.apple.Siri VoiceTriggerUserEnabled -bool false
defaults write com.apple.Siri UserHasDeclinedEnable -bool true

# Spotlight: free up Cmd+Space (Raycast) and Opt+Cmd+Space, hide the menu bar icon.
# Indexing stays ON - Raycast file search, Mail and Finder search depend on it.
print_step "Turning off Spotlight shortcuts..."
for hotkey in 64 65; do
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add $hotkey \
    "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>49</integer><integer>$(( hotkey == 64 ? 1048576 : 1572864 ))</integer></array><key>type</key><string>standard</string></dict></dict>"
done
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

print_step "Setting time format..."
defaults write com.apple.menuextra.clock DateFormat -string 'EEE MMM d  H:mm'
print_success "General UI/UX configured"

###############################################################################
# Screen                                                                      #
###############################################################################

step "Configuring Screen Settings"

defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
print_success "Immediate password requirement enabled for screensaver"

mkdir -p "$HOME/Downloads"
defaults write com.apple.screencapture location -string "$HOME/Downloads"
defaults write com.apple.screencapture type -string "jpg"
defaults write com.apple.screencapture disable-shadow -bool true
print_success "Screenshots configured: JPG format, no shadow, saved to Downloads"

###############################################################################
# Finder                                                                      #
###############################################################################

step "Configuring Finder Settings"

defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/Documents/"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
print_success "Finder configured"

###############################################################################
# Dock & Menu Bar                                                             #
###############################################################################

step "Configuring Dock and Menu Bar"

print_step "Configuring Dock..."
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock "autohide-delay" -float 1000
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
defaults write com.apple.dock tilesize -int 1

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

dock_item() {
  printf '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>%s</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>' "$1"
}

dock_folder() {
  printf '<dict><key>tile-data</key><dict><key>arrangement</key><integer>1</integer><key>displayas</key><integer>1</integer><key>file-data</key><dict><key>_CFURLString</key><string>%s</string><key>_CFURLStringType</key><integer>15</integer></dict><key>file-label</key><string>%s</string><key>file-type</key><integer>2</integer><key>is-beta</key><integer>0</integer><key>preferreditemsize</key><string>-1</string><key>showas</key><integer>3</integer></dict><key>tile-type</key><string>directory-tile</string></dict>' "$1" "$2"
}

# TODO(review together): Dock apps, in order. Apps that aren't installed are skipped.
dock_apps=(
  "/System/Applications/Mail.app"
  "/Applications/Microsoft Outlook.app"
  "/System/Applications/Calendar.app"
  "/System/Applications/Messages.app"
  "/Applications/Microsoft Teams.app"
  "/Applications/Signal.app"
  "/Applications/Safari.app"
  "/System/Applications/Notes.app"
)

print_step "Setting Dock items..."
persistent_apps=()
for app in $dock_apps; do
  if [[ -d $app ]]; then
    persistent_apps+=("$(dock_item "file://${app// /%20}/")")
  else
    fail "Not added to the Dock (not installed): ${app:t}"
  fi
done
defaults write com.apple.dock persistent-apps -array $persistent_apps
defaults write com.apple.dock persistent-others -array \
  "$(dock_folder "file:///Applications/" "Applications")" \
  "$(dock_folder "file://$HOME/Documents/" "Documents")" \
  "$(dock_folder "file://$HOME/Downloads/" "Downloads")"
print_success "Dock configured"

print_step "Configuring Menu Bar..."
defaults write NSGlobalDomain _HIHideMenuBar -bool true
print_success "Menu Bar will auto-hide"

print_step "Applying UI changes..."
killall Dock Finder 2>/dev/null || true

###############################################################################
# Final Steps & Manual To-Do List                                             #
###############################################################################

print_header "Final Steps & Manual To-Do List ${STAR}"

print_info "The following items need to be completed manually:"

print_step "Bootstrap SSH key:"
echo "  ${ARROW} 1Password → Settings → Developer → turn on 'Use the SSH agent'"
echo "  ${ARROW} Then remove the pasted key from memory:  ssh-add -D"
echo "  ${ARROW} iPhone: delete the note holding the key (and Recently Deleted)"

print_step "System Settings:"
echo "  ${ARROW} Sign in to Apple ID / iCloud services"
echo "  ${ARROW} Configure Time Machine backup"
echo "  ${ARROW} Set up Touch ID fingerprints"
echo "  ${ARROW} Grant Accessibility / Screen Recording to yabai, skhd, sketchybar, Karabiner"
echo "  ${ARROW} Confirm 8 Spaces/Desktops exist (yabai creates them when its scripting addition loads; otherwise Control + Up Arrow to add)"
echo "  ${ARROW} Enable FileVault and the firewall"

print_step "Applications:"
echo "  ${ARROW} Sign in to 1Password, browsers, Teams, Outlook"
echo "  ${ARROW} Set up Little Snitch rules"
echo "  ${ARROW} Install apps not in Homebrew or the App Store (see README)"

print_step "sketchybar Theme System:"
echo "  ${ARROW} System Settings > Wallpaper: change to ANY image (not the macOS default)"
echo "  ${ARROW} Enable 'Show on all Spaces'"
echo "  ${WARN} Required once for sketchybar theme switching to change wallpapers"

# Raycast: opening a .rayconfig file starts Raycast's own import (it asks for
# the export password). There's no way to import silently.
rayconfig="$dotfiledir/private/Raycast.rayconfig"
if [[ -f $rayconfig ]]; then
  ask import_raycast "Import Raycast settings now? (finish Raycast's welcome screens first)" y
  if [[ $import_raycast == y ]]; then
    open -a Raycast "$rayconfig" || fail "Couldn't open the Raycast import - run: open ~/.dotfiles/private/Raycast.rayconfig"
  else
    print_info "Later: open ~/.dotfiles/private/Raycast.rayconfig"
  fi
fi

if [[ -d $backupdir ]]; then
  print_warning "Files replaced by symlinks were backed up to $backupdir"
fi

print_header "Installation Complete! 🎉"
print_info "Review the manual steps above - the summary below lists anything that failed"
current_step="done"
