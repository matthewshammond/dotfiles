# Load aliases and shortcuts if existent.
[ -f "$HOME/.dotfiles/aliases.zsh" ] && source "$HOME/.dotfiles/aliases.zsh"

# Enable colors and change prompt:
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export LS_COLORS="di=1;36:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=34;43"

# Enable shims and autocompletion
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
eval "$(rbenv init -)"
eval "$(goenv init -)"

# Add pyenv to $PATH
export PYENV_ROOT="$HOME/.pyenv"
[[ ":$PATH:" =~ ":$PYENV_ROOT/bin:" ]] || export PATH="$PYENV_ROOT/bin:$PATH"

# Add pipx to $PATH
export PIPX_ROOT="$HOME/.local"
[[ ":$PATH:" =~ ":$PIPX_ROOT/bin:" ]] || export PATH="$PIPX_ROOT/bin:$PATH"

# Add rbenv to $PATH
export RBENV_ROOT="$HOME/.rbenv"
[[ ":$PATH:" =~ ":$RBENV_ROOT/bin:" ]] || export PATH="$RBENV_ROOT/bin:$PATH"

# Add go to $PATH
export GOENV_ROOT="$HOME/.goenv"
[[ ":$PATH:" =~ ":$GOENV_ROOT/bin:" ]] || export PATH="$GOENV_ROOT/bin:$PATH"

# Add rust to $PATH
export CARGO_ROOT="$HOME/.cargo"
[[ ":$PATH:" =~ ":$CARGO_ROOT/bin:" ]] || export PATH="$CARGO_ROOT/bin:$PATH"

# Enable Homebrew required path
[[ ":$PATH:" =~ ":$(brew --prefix)/sbin:" ]] || export PATH="$(brew --prefix)/sbin:$PATH"

# Enable fzf required path
[[ ":$PATH:" =~ ":$(brew --prefix)/opt/fzf/bin:" ]] || export PATH="$(brew --prefix)/opt/fzf/bin:$PATH"

# Enable personal scripts from anywhere
[[ ":$PATH:" =~ ":$HOME/.dotfiles/scripts:" ]] || export PATH="$HOME/.dotfiles/scripts:$PATH"

# Enable hidden files in FZF
export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!.git"'

# Enable fzf autocompletion
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

# Enable zsh autocompletion
[[ ":$FPATH:" =~ ":$(brew --prefix)/share/zsh-completions:" ]] || export FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
autoload -Uz compinit
compinit -i

# Enable 1Password autocompletion
eval "$(op completion zsh)"; compdef _op op

# Enable ntfy for long tasks
# eval "$(ntfy shell-integration)"

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

# Set GPG for SSH
export GPG_TTY=$(tty)
# export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket) # use GPG for SSH
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock # use 1Password for SSH
gpgconf --launch gpg-agent

resetcard() {
  rm -r $HOME/.gnupg/private-keys-v1.d
  gpgconf --kill gpg-agent
  gpg --card-status
}

# Convert vim to nvim
sudo() {
    if [[ "$1" = "vim" ]]; then
        shift
        command sudo nvim "$@"
    else
        command sudo "$@"
    fi
}

# General Settings
setopt autocd # Change dir by typing name

# Keybindings for ZSH-VI-MODE
ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
ZVM_VI_VISUAL_ESCAPE_BINDKEY=jj

# Load plugins; should be last
source $(brew --prefix)/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source $(brew --prefix)/etc/profile.d/autojump.sh
source $HOME/.dotfiles/scripts/completion.zsh
source $HOME/.dotfiles/scripts/key-bindings.zsh

# Initialize Starship prompt (should be at the end of ~/.zshrc)
eval "$(starship init zsh)"
