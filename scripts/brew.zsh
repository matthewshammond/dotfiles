#!/usr/bin/env zsh

###############################################################################
# Homebrew Installation Script                                                #
# This script installs Homebrew and all necessary packages                    #
###############################################################################

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
if [ "$1" = "y" ]; then
    print_step "Installing Python environment..."
    
    # Install pyenv and pyenv-virtualenv
    brew install pyenv pyenv-virtualenv
    
    # Add pyenv to shell
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc
    
    # Source the updated shell configuration
    source ~/.zshrc
    
    # Install Python versions if they don't exist
    if ! pyenv versions | grep -q "3.12.2"; then
        print_step "Installing Python 3.12.2..."
        pyenv install 3.12.2
    else
        print_success "Python 3.12.2 is already installed"
    fi
    
    # Set global Python version
    pyenv global 3.12.2
    
    # Create and activate virtual environments
    print_step "Setting up virtual environments..."
    if [ ! -d "$HOME/.pyenv/versions/neovim" ]; then
        pyenv virtualenv 3.12.2 neovim
    fi
    if [ ! -d "$HOME/.pyenv/versions/global" ]; then
        pyenv virtualenv 3.12.2 global
    fi
    
    # Install pip packages in global environment
    print_step "Installing global pip packages..."
    pyenv activate global
    pip install --upgrade pip
    pip install ntfy
    pyenv deactivate
    
    print_success "Python environment configured"
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
    
    # Install Go version if it doesn't exist
    if ! goenv versions | grep -q "1.22.1"; then
        print_step "Installing Go 1.22.1..."
        goenv install 1.22.1
    else
        print_success "Go 1.22.1 is already installed"
    fi
    
    goenv global 1.22.1
    goenv rehash
    print_success "Go environment configured"
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
    
    # Install Ruby version if it doesn't exist
    if ! rbenv versions | grep -q "3.3.0"; then
        print_step "Installing Ruby 3.3.0..."
        rbenv install 3.3.0
    else
        print_success "Ruby 3.3.0 is already installed"
    fi
    
    rbenv global 3.3.0
    
    # Install gems if not already installed
    if ! gem list | grep -q "rails"; then
        print_step "Installing Rails..."
        gem install rails -v 7.1.3.2
    else
        print_success "Rails is already installed"
    fi
    
    if ! gem list | grep -q "bundler"; then
        print_step "Installing Bundler..."
        gem install bundler
    else
        print_success "Bundler is already installed"
    fi
    
    rbenv rehash
    print_success "Ruby environment configured"
else
    print_info "Skipping Ruby installation"
    sed -i '' '19s/^/#/' ${dotfiledir}/.zshrc
    sed -i '' '31s/^/#/' ${dotfiledir}/.zshrc
    sed -i '' '32s/^/#/' ${dotfiledir}/.zshrc
fi

if [[ "$install_rust" =~ ^[Yy] ]]; then
    print_step "Installing Rust environment..."
    
    # Check if rustup is already installed
    if ! command -v rustup &> /dev/null; then
        brew install rustup-init
        rustup-init -y
    else
        print_success "Rust is already installed"
    fi
    
    # Ensure the default toolchain is installed
    rustup default stable
    
    print_success "Rust environment configured"
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
# File operations
brew install coreutils  # GNU core utilities
brew install gnu-sed    # GNU sed
brew install rename     # Batch rename files
brew install rsync      # File synchronization
brew install stow       # Symlink manager

# System monitoring
brew install btop       # Resource monitor
brew install duf        # Disk usage
brew install ncdu       # Disk usage analyzer
brew install progress   # Progress bar for coreutils

# Search and navigation
brew install fd         # Find alternative
brew install fzf        # Fuzzy finder
brew install ripgrep    # Grep alternative
brew install autojump   # Directory navigation

# Text processing
brew install agg        # ASCII art generator
brew install bat        # Cat with syntax highlighting
brew install eza        # ls alternative
brew install jq         # JSON processor

# Network tools
brew install openvpn    # VPN client
brew install speedtest-cli  # Internet speed test
brew install wget       # Web downloader
brew install youtubedr  # YouTube downloader

# Development tools
brew install cmake      # Build system
brew install gh         # GitHub CLI
brew install git        # Version control
brew install hugo       # Static site generator
brew install lua        # Programming language
brew install neovim     # Text editor
brew install node       # JavaScript runtime
brew install tmux       # Terminal multiplexer
brew install watch      # Execute program periodically

# Security tools
brew install gnupg      # GNU Privacy Guard
brew install hopenpgp-tools  # OpenPGP tools
brew install pinentry-mac  # PIN entry
brew install ykman      # YubiKey manager
brew install ykpers     # YubiKey personalization

# macOS specific
brew install mas        # Mac App Store CLI

print_success "CLI tools installed successfully"

###############################################################################
# Shell Enhancements                                                          #
###############################################################################

print_header "Installing Shell Enhancements"

print_step "Installing Zsh and plugins..."
brew install zsh                    # Shell
brew install zsh-autosuggestions    # Auto-suggestions
brew install zsh-completions        # Completions
brew install zsh-syntax-highlighting  # Syntax highlighting
brew install zsh-vi-mode           # Vi mode
brew install powerlevel10k         # Theme
print_success "Zsh and plugins installed"

###############################################################################
# Window Management                                                           #
###############################################################################

print_header "Installing Window Management Tools"

print_step "Installing window management tools..."
brew install sketchybar  # Status bar
brew install skhd       # Hotkey daemon
brew install yabai      # Window manager
print_success "Window management tools installed"

###############################################################################
# Applications                                                                 #
###############################################################################

print_header "Installing Applications"

print_step "Installing GUI applications..."
# Security & Privacy
brew install --cask 1password        # Password manager
brew install --cask 1password-cli    # 1Password CLI
brew install --cask gpg-suite        # GPG tools
brew install --cask little-snitch    # Network monitor
brew install --cask micro-snitch     # Microphone monitor
brew install --cask private-internet-access  # VPN
brew install --cask tailscale        # VPN
brew install --cask tor-browser      # Privacy browser
brew install --cask veracrypt        # Disk encryption

# Development
brew install --cask cursor           # AI-powered IDE
brew install --cask docker           # Container platform
brew install --cask drawio           # Diagram editor
brew install --cask iterm2           # Terminal emulator
brew install --cask qgis             # GIS software
brew install --cask rustdesk         # Remote desktop

# Productivity
brew install --cask chatgpt          # AI assistant
brew install --cask discord          # Communication
brew install --cask firefox          # Web browser
brew install --cask microsoft-office # Office suite
brew install --cask microsoft-teams  # Team collaboration
brew install --cask parallels        # Virtualization
brew install --cask pdf-expert       # PDF editor
brew install --cask plex             # Media server
brew install --cask raycast          # Launcher
brew install --cask signal           # Messaging

# Utilities
brew install --cask gimp             # Image editor
brew install --cask karabiner-elements  # Keyboard customizer
brew install --cask macfuse          # File system extension
brew install --cask qlmarkdown       # QuickLook for Markdown
brew install --cask sf-symbols       # Apple SF Symbols

# Fonts
brew install --cask font-hack-nerd-font    # Hack Nerd Font
brew install --cask font-jetbrains-mono    # JetBrains Mono

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
    brew install aircrack-ng    # Wireless network security tool
    brew install bettercap      # Network attack and monitoring tool
    brew install binwalk        # Firmware analysis tool
    brew install crunch         # Wordlist generator
    brew install exiftool       # Metadata analysis tool
    brew install exploitdb      # Exploit database
    brew install ffuf           # Web fuzzer
    brew install gobuster       # Directory/file brute-forcer
    brew install hashcat        # Password cracker
    brew install hydra          # Network login cracker
    brew install ifstat         # Network interface statistics
    brew install john-jumbo     # Password cracker (John the Ripper)
    brew install netcat         # Network utility
    brew install nikto          # Web server scanner
    brew install nmap           # Network mapper
    brew install postgresql     # Database for tools
    brew install proxychains-ng # Proxy chains
    brew install rlwrap         # Readline wrapper
    brew install samba          # SMB/CIFS tools
    brew install snort          # Network intrusion detection
    brew install sqlmap         # SQL injection tool
    brew install telnet         # Network protocol
    brew install theharvester   # Email/domain recon tool
    brew install volatility     # Memory forensics
    brew install wpscanteam/tap/wpscan  # WordPress scanner
    print_success "CLI pentesting tools installed"

    print_step "Installing GUI pentesting tools..."
    brew install --cask burp-suite    # Web security testing
    brew install --cask ghidra        # Reverse engineering
    brew install --cask metasploit    # Exploitation framework
    brew install --cask owasp-zap     # Web app scanner
    brew install --cask wireshark     # Network protocol analyzer
    brew install --cask xquartz       # X11 server for GUI tools
    print_success "GUI pentesting tools installed"

    print_step "Installing additional pentesting tools..."
    # enum4linux - SMB enumeration tool
    git clone https://github.com/CiscoCXSecurity/enum4linux.git /opt/homebrew/Cellar/enum4linux && \
        sudo ln -s /opt/homebrew/Cellar/enum4linux/enum4linux.pl /usr/local/bin/enum4linux
    brew link enum4linux
    
    # smbmap - SMB share enumeration tool
    git clone https://github.com/ShawnDEvans/smbmap.git /opt/homebrew/Cellar/smbmap && \
        python3 -m pip install -r /opt/homebrew/Cellar/smbmap/requirements.txt && \
        sudo ln -s /opt/homebrew/Cellar/smbmap/smbmap.py /usr/local/bin/smbmap
    brew link smbmap

    # crackmapexec - Windows/Active Directory exploitation tool
    pipx install crackmapexec
    # pwncat - Post-exploitation framework
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
