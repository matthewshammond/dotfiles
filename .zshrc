# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Cache brew prefix to avoid multiple slow calls
export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix 2>/dev/null || echo /opt/homebrew)}"

# Language manager roots (shims lazy-loaded below)
export PYENV_ROOT="$HOME/.pyenv"
export RBENV_ROOT="$HOME/.rbenv"
export GOENV_ROOT="$HOME/.goenv"
export CARGO_ROOT="$HOME/.cargo"
export PIPX_ROOT="$HOME/.local"

export PATH="$PYENV_ROOT/bin:$RBENV_ROOT/bin:$GOENV_ROOT/bin:$CARGO_ROOT/bin:$PIPX_ROOT/bin:$HOMEBREW_PREFIX/sbin:$HOME/.dotfiles/scripts:$PATH"

# Lazy-load language managers
pyenv() {
  unset -f pyenv
  eval "$(command pyenv init -)"
  eval "$(command pyenv virtualenv-init -)"
  pyenv "$@"
}

rbenv() {
  unset -f rbenv
  eval "$(command rbenv init -)"
  rbenv "$@"
}

goenv() {
  unset -f goenv
  eval "$(command goenv init -)"
  goenv "$@"
}

# fzf: env + custom generators (must exist before completion.zsh is sourced)
export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!.git"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

_fzf_compgen_path() {
  fd --hidden --follow --exclude .git . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude .git . "$1"
}

_fzf_comprun() {
  local command=$1
  shift
  case "$command" in
    cd) fzf "$@" --preview 'tree -C {} | head -200' ;;
    *)  fzf "$@" ;;
  esac
}

# Completions — rebuild dump if missing or older than 24h
autoload -Uz compinit
() {
  setopt local_options extended_glob
  local zcd="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ ! -e $zcd || -n $zcd(#qN.mh+24) ]]; then
    compinit
  else
    compinit -C
  fi
}

# Lazy-load 1Password completion
op() {
  unset -f op
  eval "$(command op completion zsh)"
  compdef _op op
  op "$@"
}

export BAT_THEME=Nord
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export LS_COLORS='di=1;36:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=34;43'

# History
HISTFILE=$HOME/.zsh_history
HISTSIZE=5000
SAVEHIST=2000
setopt HIST_VERIFY SHARE_HISTORY APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_SPACE
setopt autocd

# GPG / 1Password SSH agent — shared setup for wrappers below
_gpg_env() {
  export GPG_TTY=$(tty)
  export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
}

gpgconf() {
  unset -f gpgconf
  _gpg_env
  command gpgconf --launch gpg-agent
  command gpgconf "$@"
}

resetcard() {
  unset -f gpgconf resetcard
  _gpg_env
  rm -r "$HOME/.gnupg/private-keys-v1.d"
  command gpgconf --kill gpg-agent
  gpg --card-status
}

# Atuin (shell history sync). Ctrl-R is rebound by fzf after vi-mode init.
eval "$(atuin init zsh)"

# Use nvim whenever `sudo vim` is called
sudo() {
  if [[ $1 == vim ]]; then
    shift
    command sudo nvim "$@"
  else
    command sudo "$@"
  fi
}

# zsh-vi-mode options (must be set before the plugin loads)
ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
ZVM_VI_VISUAL_ESCAPE_BINDKEY=jj
# Init on source (not precmd) so deferred load still runs zvm_after_init immediately
ZVM_INIT_MODE=sourcing

# Powerlevel10k
source "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# zsh-defer for non-critical plugins
source ~/.zsh-defer/zsh-defer.plugin.zsh

# Autosuggestions are cheap and useful immediately
source "$HOMEBREW_PREFIX/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# fzf must bind keys after zsh-vi-mode rebuilds keymaps
zvm_after_init() {
  local fzf_shell="$HOMEBREW_PREFIX/opt/fzf/shell"
  source "$fzf_shell/completion.zsh"
  source "$fzf_shell/key-bindings.zsh"
}

# Defer heavier plugins (order matters: vi-mode before syntax-highlighting)
zsh-defer source "$HOMEBREW_PREFIX/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
zsh-defer source "$HOMEBREW_PREFIX/etc/profile.d/autojump.sh"
zsh-defer source "$HOME/.dotfiles/aliases.zsh"
zsh-defer source "$HOMEBREW_PREFIX/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
