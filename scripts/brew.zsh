#!/usr/bin/env zsh

###############################################################################
# Homebrew Installation Script                                                #
# Installs Homebrew, everything in ~/.dotfiles/Brewfile, and language         #
# versions. Sourced by install.zsh, which sets INSTALL_PYTHON/RUBY/GO/RUST.  #
# Can also be run on its own:  INSTALL_PYTHON=y zsh scripts/brew.zsh          #
###############################################################################

# print_* helpers come from install.zsh; define fallbacks for standalone runs
if (( ! $+functions[print_step] )); then
  print_header()  { printf "\n\033[0;34m⭐ %s ⭐\033[0m\n" "$1" }
  print_step()    { printf "\033[0;36m→ %s\033[0m\n" "$1" }
  print_success() { printf "\033[0;32m✓ %s\033[0m\n" "$1" }
  print_warning() { printf "\033[1;33m⚠️ %s\033[0m\n" "$1" }
  print_info()    { printf "\033[0;35mℹ️ %s\033[0m\n" "$1" }
fi
(( $+functions[fail] )) || fail() { print_warning "$1" }

dotfiledir="${dotfiledir:-$HOME/.dotfiles}"
brewfile="$dotfiledir/Brewfile"

print_header "Homebrew 🍺"

# Install Homebrew
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  print_step "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  print_success "Homebrew installed"
else
  print_info "Homebrew already installed"
fi

# Put brew on PATH for this script and future login shells (only add the line once)
eval "$(/opt/homebrew/bin/brew shellenv)"
if ! grep -qs 'brew shellenv' ~/.zprofile; then
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
fi

brew analytics off
print_step "Updating Homebrew..."
brew update

###############################################################################
# Brewfile                                                                    #
###############################################################################

print_header "Installing packages from Brewfile"
print_info "App Store apps need you signed in to the App Store app first."
print -n "\033[0;36m⚙️ Sign in to the App Store now if needed, then press Enter... \033[0m"
read -r

# brew bundle keeps going when one package fails and reports at the end,
# so a single bad package can't abort the whole install
if brew bundle --file="$brewfile"; then
  print_success "All Brewfile packages installed"
else
  # List exactly what's still missing, e.g. "Cask foo needs to be installed."
  missing=(${(f)"$(brew bundle check --verbose --no-upgrade --file="$brewfile" 2>/dev/null | sed -n 's/^→ //p')"})
  for item in $missing; do
    fail "Homebrew: $item"
  done
  print_warning "Re-run just the packages later with: brew bundle --file=$brewfile"
fi

###############################################################################
# Language versions (only when chosen in install.zsh)                         #
###############################################################################

if [[ $INSTALL_PYTHON == y ]]; then
  print_step "Setting up Python 3.14 via pyenv..."
  export PYENV_ROOT="$HOME/.pyenv"
  eval "$(pyenv init -)"
  pyenv versions --bare | grep -q '^3\.14' || pyenv install 3.14
  pyenv global 3.14
  pyenv rehash
  pip install --upgrade pip
  pip install ntfy
  print_success "Python ready"
fi

if [[ $INSTALL_GO == y ]]; then
  print_step "Setting up Go 1.25.4 via goenv..."
  export GOENV_ROOT="$HOME/.goenv"
  eval "$(goenv init -)"
  goenv versions --bare | grep -q '^1\.25\.4$' || goenv install 1.25.4
  goenv global 1.25.4
  print_success "Go ready"
fi

if [[ $INSTALL_RUBY == y ]]; then
  print_step "Setting up Ruby 3.4.7 via rbenv..."
  eval "$(rbenv init -)"
  rbenv versions --bare | grep -q '^3\.4\.7$' || rbenv install 3.4.7
  rbenv global 3.4.7
  gem list -i rails >/dev/null || gem install rails
  gem list -i bundler >/dev/null || gem install bundler
  print_success "Ruby ready"
fi

if [[ $INSTALL_RUST == y ]]; then
  print_step "Setting up Rust via rustup..."
  command -v rustc >/dev/null || rustup-init -y --no-modify-path
  "$HOME/.cargo/bin/rustup" default stable
  print_success "Rust ready"
fi

###############################################################################
# Services                                                                    #
###############################################################################

print_header "Starting window management services"
print_info "macOS will ask for Accessibility / Screen Recording permissions."
skhd --start-service 2>/dev/null || skhd --restart-service || true
yabai --start-service 2>/dev/null || yabai --restart-service || true
brew services restart sketchybar || true
print_success "skhd, yabai and sketchybar started"
