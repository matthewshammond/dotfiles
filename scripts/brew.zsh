#!/usr/bin/env zsh
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# If ARM, add brew path to .zprofile and eval
if [ $(uname -a | awk '{print $(NF)}') = 'arm64' ]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Turn off Analytics
brew analytics off

# Upgrade Brew
brew upgrade

install_python=$1
install_ruby=$2
install_go=$3
install_rust=$4
install_transmission=$5
install_pentest_tools=$6

# Taps
brew tap homebrew/cask-fonts
brew tap FelixKratz/formulae
brew tap koekeishiya/formulae

# Install Brew Packages
brew install agg              # Asciicast to GIF converter
brew install asciinema        # Record and share terminal sessions
brew install atomicparsley    # MPEG-4 command-line tool
brew install autojump         # Shell extension to jump to frequently used directories
brew install bash             # Latest version of Bourne-Again SHell
brew install bat              # Clone of cat with syntax highlighting and Git integration
brew install btop             # Resource monitor
brew install cmake            # Cross-platform make
brew install coreutils        # GNU File, Shell, and Text utilities
brew install docker           # Pack, ship and run any application as a lightweight container
brew install duf              # Disk Usage/Free Utility - a better 'df' alternative
brew install eza              # Modern, maintained replacement for ls
brew install fd               # Simple, fast and user-friendly alternative to find
brew install ffmpeg           # Play, record, convert, and stream audio and video
brew install fzf              # Command-line fuzzy finder written in Go
brew install gh               # GitHub command-line tool
brew install ghostscript      # Interpreter for PostScript and PDF
brew install git              # Distributed revision control system

case $install_go in
    y|Y|yes|Yes)
        echo "\nInstalling golang 1.19.1"
        brew install goenv --HEAD
        goenv install 1.22.1
        goenv global 1.22.1
        goenv rehash
        ;;
    *)
        sed -i '' '20s/^/#/' ${dotfiledir}/.zshrc
        sed -i '' '35s/^/#/' ${dotfiledir}/.zshrc
        sed -i '' '36s/^/#/' ${dotfiledir}/.zshrc
        ;;
esac

brew install gnupg                    # GNU Pretty Good Privacy (PGP) package
brew install gnu-sed                  # GNU implementation of the famous stream editor
brew install guumaster/tap/hostctl    # Manage hosts file
brew install hopenpgp-tools           # Command-line tools for OpenPGP-related operations
brew install hugo                     # Configurable static site generator
brew install imagemagick              # Tools and libraries to manipulate images in many formats
brew install jq                       # Lightweight and flexible command-line JSON processor
brew install lua                      # Powerful, lightweight programming language
brew install mas                      # Mac App Store command-line interface
brew install ncdu                     # NCurses Disk Usage
brew install neovim                   # Ambitious Vim-fork focused on extensibility and agility
brew install node                     # Platform built on V8 to build network applications
brew install openvpn                  # SSL/TLS VPN implementing OSI layer 2 or 3 secure network extension
brew install pinentry-mac             # Pinentry for GPG on Mac
brew install pipx                     # Execute binaries from Python packages in isolated environments
brew install powerlevel10k            # Theme for zsh
brew install progress                 # Coreutils progress viewer

# install python3 and packages
case $install_python in
    y|Y|yes|Yes)
        echo "\nInstalling python 3.12.2"
        brew install pyenv
        pyenv install 3.12.2
        pyenv global 3.12.2
        pip3 install ntfy
        pyenv rehash
        brew install pyenv-virtualenv
        ;;
    *)
        sed -i '' '17s/^/#/' ${dotfiledir}/.zshrc
        sed -i '' '18s/^/#/' ${dotfiledir}/.zshrc
        sed -i '' '23s/^/#/' ${dotfiledir}/.zshrc
        sed -i '' '24s/^/#/' ${dotfiledir}/.zshrc
        sed -i '' '27s/^/#/' ${dotfiledir}/.zshrc
        sed -i '' '28s/^/#/' ${dotfiledir}/.zshrc
        ;;
esac

brew install rename     # Perl-powered file rename script with many helpful built-ins
brew install ripgrep    # Search tool like grep and The Silver Searcher
brew install rsync      # Utility that provides fast incremental file transfer

case $install_ruby in
    y|Y|yes|Yes)
        echo "\nInstalling ruby 3.3.0"
        brew install rbenv
        brew install ruby-build
        rbenv install 3.3.0
        rbenv global 3.3.0
        gem install rails -v 7.1.3.2
        gem install bundler
        rbenv rehash
        ;;
    *)
        sed -i '' '19s/^/#/' ${dotfiledir}/.zshrc
        sed -i '' '31s/^/#/' ${dotfiledir}/.zshrc
        sed -i '' '32s/^/#/' ${dotfiledir}/.zshrc
        ;;
esac

case $install_rust in
    y|Y|yes|Yes)
        echo "\nInstalling rust"
        brew install rustup-init
        rustup-init
        ;;
    *)
        sed -i '' '39s/^/#/' ${dotfiledir}/.zshrc
        sed -i '' '40s/^/#/' ${dotfiledir}/.zshrc
        ;;
esac

brew install sketchybar
brew install skhd
brew install speedtest-cli            # Command-line interface for https://speedtest.net bandwidth tests
brew install stow                     # Organize software neatly under a single directory tree
brew install tmux                     # Terminal multiplexer
brew install watch                    # Executes a program periodically, showing output fullscreen
brew install wget                     # Internet file retriever
brew install yabai
brew install ykman                    # Tool for managing your YubiKey configuration
brew install ykpers                   # YubiKey personalization library and tool
brew install youtubedr                # Download Youtube Video in Golang
brew install zsh                      # Latest version of Zshell
brew install zsh-autosuggestions      # Fish-like fast/unobtrusive autosuggestions for zsh
brew install zsh-completions          # Additional completion definitions for zsh
brew install zsh-syntax-highlighting  # Fish shell like syntax highlighting for zsh
brew install zsh-vi-mode              # Better and friendly vi(vim) mode plugin for ZSH

# Install MacOS Applications
brew install --cask 1password                   # Password manager that keeps all passwords secure behind one password
brew install --cask 1password-cli               # Command-line interface for 1Password
brew install --cask chatgpt                     # OpenAI's official ChatGPT desktop app
brew install --cask cursor                      # Write, edit, and chat about your code with AI
brew install --cask docker                      # App to build and share containerised applications and microservices
brew install --cask drawio                      # Online diagram software
brew install --cask discord                     # Voice and text chat software
brew install --cask firefox                     # Web browser
brew install --cask font-hack-nerd-font         # Hack Nerd Font
brew install --cask font-jetbrains-mono         # JetBrains Mono
brew install --cask gimp                        # Free and open-source image editor
brew install --cask gpg-suite                   # Tools to protect your emails and files
brew install --cask iterm2                      # Terminal emulator as alternative to Apple's Terminal app
brew install --cask karabiner-elements          # Keyboard customizer
brew install --cask little-snitch               # Host-based application firewall
brew install --cask macfuse                     # File system integration
brew install --cask micro-snitch                # Monitors and reports any microphone and camera activity
brew install --cask microsoft-office            # Office suite
brew install --cask microsoft-teams             # Meet, chat, call, and collaborate in just one place
brew install --cask parallels                   # Desktop virtualization software
brew install --cask pdf-expert                  # PDF reader, editor and annotator
brew install --cask plex                        # Home media player
brew install --cask private-internet-access     # VPN client
brew install --cask qlmarkdown                  # Quick Look generator for Markdown files
brew install --cask qgis                        # Geographic Information System
brew install --cask raycast                     # Control your tools with a few keystrokes
brew install --cask rustdesk                    # Open source virtual/remote desktop application
brew install --cask sf-symbols                  # Tool that provides consistent, highly configurable symbols for apps
brew install --cask signal                      # Instant messaging application focusing on security
brew install --cask tailscale                   # Easiest, most secure way to use WireGuard and 2FA
brew install --cask tor-browser                 # Web browser focusing on security
brew install --cask veracrypt                   # Disk encryption software focusing on security based on TrueCrypt

# Install MacOS Applications from Mac App Store
mas install 1569813296  # 1Password for Safari
mas install 1198176727  # Controller
mas install 424389933   # Final Cut Pro
mas install 837263884   # LogTen
mas install 1176895641  # Spark Email App
mas install 1521133201  # Speed Player
mas install 1630456052  # TopDrop
mas install 1480933944  # Vimari
mas install 1497506650  # Yubico Authenticator

# Install Pentesting Tools
case $install_pentest_tools in
    y|Y|yes|Yes) 
        # formulae
        brew install aircrack-ng            # tools to assess WiFi network security
        brew install bettercap              # Swiss army knife for network attacks and monitoring
        brew install binwalk                # tool for analyzing, reverse engineering, and extracting firmware images
        brew install crunch                 # Wordlist generator
        brew install exiftool               # reading, writing and editing meta information
        brew install exploitdb              # Database of public exploits and corresponding vulnerable software
        brew install ffuf                   # Fast web fuzzer written in Go
        brew install gobuster               # tool for brute forcing Directory/file & DNS
        brew install hashcat                # fastest and most advanced password recovery utility
        brew install hydra                  # Network logon cracker
        brew install ifstat                 # Tool to report network interface bandwidth
        brew install john-jumbo             # password security auditing and password recovery tool
        brew install netcat                 # Utility for managing network connections
        brew install nikto                  # Web server scanner
        brew install nmap                   # Port scanning utility for large networks
        brew install postgresql             # Object-relational database system
        brew install proxychains-ng         # Hook preloader
        brew install rlwrap                 # adds readline support to tools that lack it
        brew install samba                  # SMB/CIFS file, print, and login server for UNIX
        brew install snort                  # Flexible Network Intrusion Detection System
        brew install sqlmap                 # Penetration testing for SQL injection and database servers
        brew install telnet                 # User interface to the TELNET protocol
        brew install theharvester           # Gather materials from public sources
        brew install volatility             # Advanced memory forensics framework
        brew install wpscanteam/tap/wpscan  # WordPress Security Scanner 

        # casks
        brew install --cask burp-suite  # Web security testing toolkit
        brew install --cask ghidra      # Software reverse engineering (SRE) suite of tools
        brew install --cask metasploit  # Penetration testing framework
        brew install --cask owasp-zap   # web app scanner
        brew install --cask wireshark   # Graphical network analyzer and capture tool
        brew install --cask xquartz     # Open-source version of the X.Org X Window System

        # tool for enumerating information from Windows and Samba systems
        git clone https://github.com/CiscoCXSecurity/enum4linux.git /opt/homebrew/Cellar/enum4linux && sudo ln -s /opt/homebrew/Cellar/enum4linux/enum4linux.pl /usr/local/bin/enum4linux
        brew link enum4linux
        
        # enumerate samba share drives across an entire domain
        git clone https://github.com/ShawnDEvans/smbmap.git /opt/homebrew/Cellar/smbmap && python3 -m pip install -r /opt/homebrew/Cellar/smbmap/requirements.txt && sudo ln -s /opt/homebrew/Cellar/smbmap/smbmap.py /usr/local/bin/smbmap
        brew link smbmap

        # swiss army knife for pentesting Windows/Active Directory environments
        pipx install crackmapexec

        # post-exploitation platform
        pipx install git+https://github.com/calebstewart/pwncat.git
        
        # cli script to analyze an E-Mail in the eml format for viewing the header, extracting attachments etc
        pip3 install eml-analyzer
        
        # Identify the different types of hashes used to encrypt data and especially passwords.
        pip3 install hashid
        
        # Linux Privilege Escalation Awesome Script
        curl -o /opt/homebrew/bin/linpeas.sh -L 'https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh' && chmod +x /opt/homebrew/bin/linpeas.sh

        # dictionaries/wordlists
        sudo mkdir -p /usr/local/share/wordlists
        sudo mkdir -p /usr/local/share/SecLists

        sudo git clone https://github.com/3ndG4me/KaliLists.git /usr/local/share/wordlists && sudo gzip -d /usr/local/share/wordlists/rockyou.txt.gz
        sudo git clone https://github.com/danielmiessler/SecLists.git /usr/local/share/SecLists
        
        # scripts
        ;;
    *) ;;
esac

# Start Services
echo "Starting Services (grant permissions)..."
skhd --start-service
yabai --start-service
brew services start sketchybar
