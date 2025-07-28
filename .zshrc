# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Cache brew prefix to avoid multiple slow calls (needed for paths)
export HOMEBREW_PREFIX=$(brew --prefix 2>/dev/null || echo "/opt/homebrew")

# Lazy load language managers
pyenv() {
  unset -f pyenv
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
  pyenv "$@"
}

rbenv() {
  unset -f rbenv
  eval "$(rbenv init -)"
  rbenv "$@"
}

goenv() {
  unset -f goenv
  eval "$(goenv init -)"
  goenv "$@"
}

# Add language manager paths (lazy loaded)
export PYENV_ROOT="$HOME/.pyenv"
export RBENV_ROOT="$HOME/.rbenv"
export GOENV_ROOT="$HOME/.goenv"
export CARGO_ROOT="$HOME/.cargo"
export PIPX_ROOT="$HOME/.local"

# Add paths efficiently (avoid slow regex checks)
export PATH="$PYENV_ROOT/bin:$RBENV_ROOT/bin:$GOENV_ROOT/bin:$CARGO_ROOT/bin:$PIPX_ROOT/bin:$HOMEBREW_PREFIX/sbin:$HOMEBREW_PREFIX/opt/fzf/bin:$HOME/.dotfiles/scripts:$PATH"

# Enable fzf settings
export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!.git"'

# Lazy load fzf completion functions
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    *)            fzf "$@" ;;
  esac
}

# Lazy load zsh completion
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
  compdump
else
  compinit -C
fi

# Lazy load 1Password completion
op() {
  unset -f op
  eval "$(op completion zsh)"
  compdef _op op
  op "$@"
}

# Set theme for bat
export BAT_THEME=Nord

# Save command history
HISTFILE=$HOME/.zsh_history
HISTSIZE=5000
SAVEHIST=2000
setopt HIST_VERIFY # show command history expansion to user before running it
setopt SHARE_HISTORY # share command history data
setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt HIST_IGNORE_DUPS # ignore history duplicated commands history list
setopt HIST_IGNORE_SPACE # ignore commands that start with space

# Lazy load GPG configuration and functions
gpgconf() {
  unset -f gpgconf resetcard
  export GPG_TTY=$(tty)
  export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
  gpgconf --launch gpg-agent
  gpgconf "$@"
}

resetcard() {
  unset -f gpgconf resetcard
  export GPG_TTY=$(tty)
  export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
  rm -r $HOME/.gnupg/private-keys-v1.d
  gpgconf --kill gpg-agent
  gpg --card-status
}

# Lazy load sudo with vim conversion
sudo() {
    unset -f sudo
    sudo() {
        if [[ "$1" = "vim" ]]; then
            shift
            command sudo nvim "$@"
        else
            command sudo "$@"
        fi
    }
    sudo "$@"
}

# General Settings
setopt autocd # Change dir by typing name

# Keybindings for ZSH-VI-MODE
ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
ZVM_VI_VISUAL_ESCAPE_BINDKEY=jj



# Load Powerlevel10k theme
source $HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load zsh-defer for clean lazy loading
source ~/.zsh-defer/zsh-defer.plugin.zsh

# Load essential plugins immediately (these are fast)
source $HOMEBREW_PREFIX/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Defer loading of heavier plugins and configurations
zsh-defer source $HOMEBREW_PREFIX/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
zsh-defer source $HOMEBREW_PREFIX/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
zsh-defer source $HOMEBREW_PREFIX/etc/profile.d/autojump.sh

# Defer loading of completion and key-bindings scripts
zsh-defer source $HOME/.dotfiles/scripts/completion.zsh
zsh-defer source $HOME/.dotfiles/scripts/key-bindings.zsh

# Defer loading of aliases (they're fast but can be deferred)
zsh-defer source "$HOME/.dotfiles/aliases.zsh"

# Defer loading of color configurations
zsh-defer -c 'export CLICOLOR=1; export LSCOLORS=GxFxCxDxBxegedabagaced; export LS_COLORS="di=1;36:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=34;43"'
