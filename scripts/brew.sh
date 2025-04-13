#!/usr/bin/env bash

# Terminal colors and icons (matching install.sh)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

CHECK="✓"
WARN="⚠️"
INFO="ℹ️"
ARROW="→"
STAR="⭐"
BEER="🍺"
PKG="📦"

# Print functions (matching install.sh)
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

# Error handling
set -e
trap 'print_error "An error occurred during package installation. Check the logs for details."' ERR

# Store arguments
install_python=$1
install_ruby=$2
install_go=$3
install_rust=$4
install_transmission=$5
install_pentest_tools=$6

print_header "Starting Homebrew Installation and Setup ${BEER}"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    print_step "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_success "Homebrew installed successfully"
else
    print_info "Homebrew already installed"
fi

# If ARM, add brew path to .zprofile and eval
if [ $(uname -a | awk '{print $(NF)}') = 'arm64' ]; then
    print_step "Configuring Homebrew for Apple Silicon..."
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    print_success "Homebrew configured for Apple Silicon"
fi

print_step "Configuring Homebrew settings..."
brew analytics off
print_success "Analytics disabled"

print_step "Updating Homebrew..."
brew upgrade
print_success "Homebrew updated to latest version"

###############################################################################
# Taps                                                                         #
###############################################################################

print_header "Adding Homebrew Taps"

print_step "Tapping additional repositories..."
brew tap FelixKratz/formulae
brew tap koekeishiya/formulae
print_success "Additional repositories tapped"

###############################################################################
# Core Development Tools                                                       #
###############################################################################

print_header "Installing Core Development Tools"

# Programming Languages
if [[ "$install_python" =~ ^[Yy] ]]; then
    print_step "Installing Python environment..."
    brew install pyenv
    brew install pyenv-virtualenv
    pyenv install 3.12.2
    pyenv global 3.12.2
    pip3 install ntfy
    pyenv rehash
    print_success "Python 3.12.2 installed and configured"
else
    print_info "Skipping Python installation"
    sed -i '' '17s/^/#/' ${dotfiledir}/.zshrc
    sed -i '' '18s/^/#/' ${dotfiledir}/.zshrc
    sed -i '' '23s/^/#/' ${dotfiledir}/.zshrc
    sed -i '' '24s/^/#/' ${dotfiledir}/.zshrc
    sed -i '' '27s/^/#/' ${dotfiledir}/.zshrc
    sed -i '' '28s/^/#/' ${dotfiledir}/.zshrc
fi

if [[ "$install_go" =~ ^[Yy] ]]; then
    print_step "Installing Go environment..."
    brew install goenv --HEAD
    goenv install 1.22.1
    goenv global 1.22.1
    goenv rehash
    print_success "Go 1.22.1 installed and configured"
else
    print_info "Skipping Go installation"
    sed -i '' '20s/^/#/' ${dotfiledir}/.zshrc
    sed -i '' '35s/^/#/' ${dotfiledir}/.zshrc
    sed -i '' '36s/^/#/' ${dotfiledir}/.zshrc
fi

if [[ "$install_ruby" =~ ^[Yy] ]]; then
    print_step "Installing Ruby environment..."
    brew install rbenv
    brew install ruby-build
    rbenv install 3.3.0
    rbenv global 3.3.0
    gem install rails -v 7.1.3.2
    gem install bundler
    rbenv rehash
    print_success "Ruby 3.3.0 installed and configured"
else
    print_info "Skipping Ruby installation"
    sed -i '' '19s/^/#/' ${dotfiledir}/.zshrc
    sed -i '' '31s/^/#/' ${dotfiledir}/.zshrc
    sed -i '' '32s/^/#/' ${dotfiledir}/.zshrc
fi

if [[ "$install_rust" =~ ^[Yy] ]]; then
    print_step "Installing Rust environment..."
    brew install rustup-init
    rustup-init -y
    print_success "Rust installed and configured"
else
    print_info "Skipping Rust installation"
    sed -i '' '39s/^/#/' ${dotfiledir}/.zshrc
    sed -i '' '40s/^/#/' ${dotfiledir}/.zshrc
fi

###############################################################################
# CLI Tools                                                                    #
###############################################################################

print_header "Installing CLI Tools"

print_step "Installing essential command line tools..."
brew install agg bat btop cmake coreutils duf eza fd fzf gh git gnu-sed \
    gnupg hopenpgp-tools hugo imagemagick jq lua mas ncdu neovim node openvpn \
    pinentry-mac pipx powerlevel10k progress rename ripgrep rsync sketchybar \
    skhd speedtest-cli stow tmux watch wget yabai ykman ykpers youtubedr

print_success "CLI tools installed successfully"

###############################################################################
# Shell Enhancements                                                          #
###############################################################################

print_header "Installing Shell Enhancements"

print_step "Installing Zsh and plugins..."
brew install zsh zsh-autosuggestions zsh-completions zsh-syntax-highlighting zsh-vi-mode
print_success "Zsh and plugins installed"

###############################################################################
# Applications                                                                 #
###############################################################################

print_header "Installing Applications"

print_step "Installing GUI applications..."
brew install --cask 1password 1password-cli chatgpt cursor docker drawio discord firefox \
    gimp gpg-suite iterm2 karabiner-elements \
    little-snitch macfuse micro-snitch microsoft-office microsoft-teams parallels \
    pdf-expert plex private-internet-access qlmarkdown qgis raycast rustdesk \
    sf-symbols signal tailscale tor-browser veracrypt
# Install fonts from main cask repository
brew install --cask font-hack-nerd-font font-jetbrains-mono
print_success "GUI applications installed"

###############################################################################
# Mac App Store Applications                                                   #
###############################################################################

print_header "Installing Mac App Store Applications"

print_step "Installing applications from Mac App Store..."
mas install 1569813296  # 1Password for Safari
mas install 1198176727  # Controller
mas install 424389933   # Final Cut Pro
mas install 837263884   # LogTen
mas install 1176895641  # Spark Email App
mas install 1521133201  # Speed Player
mas install 1630456052  # TopDrop
mas install 1480933944  # Vimari
mas install 1497506650  # Yubico Authenticator
print_success "Mac App Store applications installed"

###############################################################################
# Pentesting Tools (Optional)                                                 #
###############################################################################

if [[ "$install_pentest_tools" =~ ^[Yy] ]]; then
    print_header "Installing Pentesting Tools"
    
    print_step "Installing CLI pentesting tools..."
    brew install aircrack-ng bettercap binwalk crunch exiftool exploitdb ffuf \
        gobuster hashcat hydra ifstat john-jumbo netcat nikto nmap postgresql \
        proxychains-ng rlwrap samba snort sqlmap telnet theharvester volatility \
        wpscanteam/tap/wpscan
    print_success "CLI pentesting tools installed"

    print_step "Installing GUI pentesting tools..."
    brew install --cask burp-suite ghidra metasploit owasp-zap wireshark xquartz
    print_success "GUI pentesting tools installed"

    print_step "Installing additional pentesting tools..."
    # enum4linux
    git clone https://github.com/CiscoCXSecurity/enum4linux.git /opt/homebrew/Cellar/enum4linux && \
        sudo ln -s /opt/homebrew/Cellar/enum4linux/enum4linux.pl /usr/local/bin/enum4linux
    brew link enum4linux
    
    # smbmap
    git clone https://github.com/ShawnDEvans/smbmap.git /opt/homebrew/Cellar/smbmap && \
        python3 -m pip install -r /opt/homebrew/Cellar/smbmap/requirements.txt && \
        sudo ln -s /opt/homebrew/Cellar/smbmap/smbmap.py /usr/local/bin/smbmap
    brew link smbmap

    # crackmapexec and pwncat
    pipx install crackmapexec
    pipx install git+https://github.com/calebstewart/pwncat.git
    
    print_success "Additional pentesting tools installed"
else
    print_info "Skipping pentesting tools installation"
fi

###############################################################################
# Cleanup                                                                      #
###############################################################################

print_header "Cleaning Up"

print_step "Running cleanup..."
brew cleanup
print_success "Homebrew cleanup complete"

print_header "🎉 Homebrew Installation Complete! 🎉"
print_info "All requested packages have been installed"

# Start Services
echo "Starting Services (grant permissions)..."
skhd --start-service
yabai --start-service
brew services start sketchybar
