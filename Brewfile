# =============================================================================
# Brewfile - everything installed on my Macs
# =============================================================================
# Rule: Homebrew first, then the Mac App Store (mas), then the developer's
# website (listed at the bottom and in the README).
#
#   brew bundle --file ~/.dotfiles/Brewfile            install anything missing
#   brew bundle check --file ~/.dotfiles/Brewfile      what's missing?
#   brew bundle cleanup --file ~/.dotfiles/Brewfile    what's installed but NOT listed here
#                                                      (add --force to uninstall it)
# =============================================================================

# ---- Taps (extra package sources) -------------------------------------------
tap "felixkratz/formulae"                              # sketchybar, SbarLua
tap "asmvik/formulae"                                  # yabai
tap "jackielii/tap"                                    # skhd-zig

# =============================================================================
# Command-line tools
# =============================================================================

# ---- Shell ------------------------------------------------------------------
brew "zsh"                                             # Shell
brew "bash"                                            # Newer bash than macOS ships (for scripts that need it)
brew "powerlevel10k"                                   # Prompt theme
brew "zsh-autosuggestions"                             # Fish-like suggestions as you type
brew "zsh-completions"                                 # Extra completion definitions
brew "zsh-syntax-highlighting"                         # Highlights commands as you type
brew "zsh-vi-mode"                                     # Vi mode for the command line
brew "atuin"                                           # Shell history search and sync
brew "autojump"                                        # Jump to frequently used directories (j)
brew "fzf"                                             # Fuzzy finder

# ---- Core utilities -----------------------------------------------------------
brew "coreutils"                                       # GNU core utilities
brew "gnu-sed"                                         # GNU sed
brew "grep"                                            # GNU grep
brew "ghostscript"                                     # PDF engine for the pdfcompress function in aliases.zsh
brew "jq"                                              # JSON processor
brew "progress"                                        # Progress for cp/mv/dd
brew "rename"                                          # Batch rename files
brew "rsync"                                           # File sync (newer than macOS's)
brew "stow"                                            # Symlinks the dotfiles into place
brew "watch"                                           # Run a command periodically
brew "wget"                                            # File downloader

# ---- Files, search & system ---------------------------------------------------
brew "bat"                                             # cat with syntax highlighting
brew "eza"                                             # Modern ls
brew "fd"                                              # Modern find
brew "ripgrep"                                         # Modern grep (rg)
brew "btop"                                            # Resource monitor
brew "duf"                                             # Disk usage (better df)
brew "ncdu"                                            # Disk usage analyzer

# ---- Network ------------------------------------------------------------------
brew "cloudflare-speed-cli"                            # Speed test (alias: speedtest)

# ---- Development --------------------------------------------------------------
brew "git"                                             # Version control
brew "gh"                                              # GitHub CLI
brew "lazygit"                                         # Terminal UI for git
brew "neovim"                                          # Editor (LazyVim config lives in .config/nvim)
brew "tree-sitter-cli"                                 # Needed by LazyVim to build syntax parsers
brew "node"                                            # Needed by Mason (LazyVim) to install language servers; website repo
brew "lua"                                             # Runs sketchybarrc (#!/usr/bin/env lua)
brew "cmake"                                           # Build system
brew "hugo"                                            # Static site generator (website)
brew "asciinema"                                       # Record terminal sessions
brew "agg"                                             # Turn asciinema recordings into GIFs

# ---- Python (venvs via pyenv-virtualenv; no global packages) ------------------
brew "pyenv"                                           # Python version manager
brew "pyenv-virtualenv"                                # Named virtualenvs (pyenv virtualenv 3.14 myproject)
brew "xz"                                              # Needed for pyenv to build Python's lzma module

# ---- Security -----------------------------------------------------------------
brew "gnupg"                                           # gpg (keys live on the YubiKey)
brew "pinentry-mac"                                    # PIN prompt for the YubiKey
brew "ykman"                                           # YubiKey manager

# ---- Window management --------------------------------------------------------
brew "felixkratz/formulae/sketchybar"                  # Status bar
brew "jackielii/tap/skhd-zig"                          # Hotkey daemon
brew "asmvik/formulae/yabai"                           # Tiling window manager

# ---- macOS --------------------------------------------------------------------
brew "mas"                                             # Mac App Store CLI (installs the mas lines below)

# =============================================================================
# Apps
# =============================================================================

# ---- Security & privacy -------------------------------------------------------
cask "1password"                                       # Password manager + SSH agent
cask "1password-cli"                                   # op command
cask "little-snitch"                                   # Outbound firewall
cask "micro-snitch"                                    # Mic/camera activity monitor
cask "tailscale-app"                                   # Mesh VPN (on every device)
cask "veracrypt"                                       # Encrypted volumes (SSH key USB)
cask "macfuse"                                         # File system support (VeraCrypt needs it)
cask "yubico-authenticator"                            # YubiKey OTP/TOTP codes

# ---- Development ---------------------------------------------------------------
cask "burp-suite"                                      # Web testing proxy (development)
cask "claude"                                          # Claude desktop app
cask "claude-code"                                     # Claude Code CLI
cask "cursor"                                          # AI code editor
cask "docker-desktop"                                  # Containers
cask "drawio"                                          # Diagrams (Claude can write .drawio files)
cask "ghostty"                                         # Quick drop-down terminal (Rex is the main terminal)
cask "grok-bot"                                        # Grok Bot
cask "grok-build"                                      # Grok coding agent CLI (grok)
cask "pgadmin4"                                        # PostgreSQL GUI - incl. Docker DBs on remote servers via SSH tunnel
cask "rustdesk"                                        # Remote desktop

# ---- Productivity -------------------------------------------------------------
cask "dropbox"                                         # Cloud storage
cask "firefox"                                         # Browser
cask "google-chrome"                                   # Browser
cask "fluidvoice"                                      # Voice-to-text dictation
cask "microsoft-excel"                                 # Spreadsheets
cask "microsoft-outlook"                               # Email
cask "microsoft-powerpoint"                            # Presentations
cask "microsoft-teams"                                 # Teams (desktop 3)
cask "microsoft-word"                                  # Documents
cask "pdf-expert"                                      # PDF editor - website version; sign in to unlock the Apple subscription
cask "raycast"                                         # Launcher (Cmd+Space)
cask "signal"                                          # Messaging

# ---- Media & graphics ---------------------------------------------------------
cask "gimp"                                            # Image editor
cask "google-earth-pro"                                # Virtual globe
cask "obs"                                             # Streaming / screen recording
cask "plex"                                            # Media player
cask "qgis"                                            # GIS

# ---- Hardware & system --------------------------------------------------------
cask "betterdisplay"                                   # Display management
cask "blackhole-2ch"                                   # Virtual audio driver
cask "displaylink"                                     # DisplayLink driver (Prompter XL monitor)
cask "elgato-camera-hub"                               # Elgato camera hub (Prompter XL)
cask "karabiner-elements"                              # Keyboard remapping
cask "parallels"                                       # Virtual machines
cask "qlmarkdown"                                      # Quick Look for Markdown
cask "sf-symbols"                                      # Apple SF Symbols (sketchybar icons)
cask "ubersicht"                                       # Desktop widgets (flip clock)

# ---- Fonts --------------------------------------------------------------------
cask "font-jetbrains-mono"                             # Rex terminal font
cask "font-jetbrains-mono-nerd-font"                   # Sketchybar font (JetBrains Mono + icons)
cask "font-hack-nerd-font"                             # Hack Nerd Font
cask "font-sketchybar-app-font"                        # App icons in sketchybar

# =============================================================================
# Mac App Store (not available on Homebrew)
# =============================================================================
mas "1Password for Safari", id: 1569813296             # 1Password Safari extension
mas "LogTen", id: 837263884                            # Pilot logbook
mas "Vimari", id: 1480933944                           # Vim keys for Safari
mas "Xcode", id: 497799835                             # Uplink iOS app (~15 GB)

# =============================================================================
# Downloaded from the developer's website (not installable from here)
# =============================================================================
#   Rex            - beta; moves to Homebrew once it's out of beta
#   IPMIView       - Supermicro server management
#   Parallels Toolbox - comes with Parallels
