# ex - archive extractor (macOS tar is libarchive: handles tar, zip, 7z, rar, xz, bz2...)
# usage: ex <file>
ex ()
{
    if [[ -z $1 ]]; then
        echo 'ex <file>'
        return 1
    fi
    if [[ ! -f $1 ]]; then
        echo "'$1' is not a valid file"
        return 1
    fi
    case $1 in
        *.tar.*|*.tar|*.tgz|*.tbz2|*.zip|*.7z|*.rar) tar -xf "$1" ;;
        *.gz)   gunzip "$1" ;;
        *.bz2)  bunzip2 "$1" ;;
        *.xz)   unxz "$1" ;;
        *.Z)    uncompress "$1" ;;
        *)      echo "'$1' cannot be extracted via ex()"; return 1 ;;
    esac
}

# Compress PDF file
# usage: pdfcompress <file>
pdfcompress ()
{
  if [ -z "$1" ]; then
    echo 'pdfcompress <file>';
    return 1;
  fi;

  local file="$1"
  local base="${file%.pdf}"
  local output="${base}-compressed.pdf"

  command gs -q -dNOPAUSE -dBATCH -dSAFER \
    -sDEVICE=pdfwrite -dCompatibilityLevel=1.3 -dPDFSETTINGS=/screen \
    -dEmbedAllFonts=true -dSubsetFonts=true \
    -dColorImageDownsampleType=/Bicubic -dColorImageResolution=144 \
    -dGrayImageDownsampleType=/Bicubic -dGrayImageResolution=144 \
    -dMonoImageDownsampleType=/Bicubic -dMonoImageResolution=144 \
    -sOutputFile="$output" "$file"
}

# Create new website post
# usage: hnp <title.md>
hnp ()
{
    if [ -z "$1" ]; then
        echo 'hnp <title>';
        return 1;
    fi;
    local year=$(date +%Y)
    cd ~/projects/website && hugo new content articles/$year/"$1".md --kind article && nvim content/articles/$year/"$1".md
}

# Find running processes by name (case-insensitive). Exact name first;
# if nothing matches exactly, any process whose name contains it.
# usage: pidof <process>
pidof() {
    if [[ -z $1 ]]; then
        echo 'pidof <process>'
        return 1
    fi
    pgrep -ilx "$1" || pgrep -il "$1"
}


# Aliases

# terminal
alias l='eza --icons=always'
alias ls='eza --icons=always'
alias ll='eza -alg --git --icons=always'
alias la='eza -a --icons=always'
alias c='clear'
alias df='duf'
alias du='ncdu'
alias tree='eza -aTI .git --git-ignore --icons=always'
alias vim='nvim'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- ~='cd ~'
alias -- /='cd /'
alias -- -='cd -'
alias listen='lsof -i TCP -n -P | grep LISTEN'
alias cat='bat -p'
alias ip='echo "Public IP: $(curl -s ifconfig.me)"; echo "Local IP:  $(ipconfig getifaddr en0)"'
update() {
	# yabai's sudoers rule pins its binary hash, so note it before upgrading
	local yabai_bin=$(command -v yabai) yabai_hash
	[[ -n $yabai_bin ]] && yabai_hash=$(shasum -a 256 "$yabai_bin" | cut -d ' ' -f 1)

	brew update && brew upgrade -y || return $?
	local -a casks
	# "${(@f)$(cmd)}" becomes a single empty element when nothing is outdated,
	# and `brew upgrade --cask --greedy ''` errors as Cask '.rb'.
	casks=(${(f)"$(brew outdated --cask --quiet)"})
	(( $#casks )) && brew upgrade --cask --greedy -- "${casks[@]}"
	brew cleanup -s && brew autoremove
	mas outdated
	mas upgrade
	local cache
	cache="$(brew --cache)"
	[[ -n $cache ]] && rm -rf "$cache"
	sketchybar --trigger brew_update

	# yabai was upgraded: refresh the sudoers hash (for --load-sa) and restart it
	if [[ -n $yabai_bin && $(shasum -a 256 "$yabai_bin" | cut -d ' ' -f 1) != "$yabai_hash" ]]; then
		echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 "$yabai_bin" | cut -d ' ' -f 1) $yabai_bin --load-sa" \
			| sudo tee /private/etc/sudoers.d/yabai >/dev/null
		yabai --restart-service
		echo "yabai upgraded: sudoers refreshed and service restarted"
	fi
}
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# editing
alias scratchpad='${=EDITOR} ~/.scratchpad' # Quick access to the ~/.scratchpad file
alias zshrc='${=EDITOR} ~/.zshrc' # Quick access to the ~/.zshrc file
alias record='asciinema rec -i 0.5 -t' # Start terminal recording #usage: record <filename>
alias lock='chflags uchg' #Lock file
alias unlock='chflags nouchg' #Unlock file

# searching
alias grep='grep --color'

alias ff="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'" # Find file recurssively using fzf
alias ef='vim "$(ff)"' # open file in vim
alias of='open "$(ff)"' # open file on desktop
alias pf='qlmanage -p "$(ff)"'
ql() { qlmanage -p "$@" >/dev/null 2>&1 }
alias jd='cd "$(find ~/Documents -type d -print | fzf)"'
alias od='open "$(find ~/Documents -type d -print | fzf)"'

alias h='history 1' # view history
alias hg='history 1 | grep' # search history

# git
alias gp='git push -v' # Push verbose
alias gs='git status' # Git Status
alias gc='git commit -v -S' # Commit all and sign
alias gl='git pull -v' # Pull verbose
alias lg='lazygit' # Opens lazygit in current directory

# Git Private Commit - private files are linked straight from ~/.dotfiles/private,
# so editing ~/.ssh/config (etc.) changes the private repo directly.
# usage: gpc                 show what changed in private
#        gpc "message"       commit + push all private changes, then record the
#                            new private commit in the public repo
#        gpc <file> "msg"    same, but only that file (path relative to ~)
gpc () {
    local root="$HOME/.dotfiles" priv="$HOME/.dotfiles/private"

    if [[ $# -eq 0 ]]; then
        if [[ -z "$(git -C "$priv" status --porcelain)" ]]; then
            print -P "%F{green}No private changes%f"
        else
            git -C "$priv" status --short
        fi
        return 0
    fi

    local msg="${@[-1]}" file=""
    (( $# >= 2 )) && file="$1"

    if [[ -n $file ]]; then
        git -C "$priv" add -- "${${file#$HOME/}#\~/}" || return 1
    else
        git -C "$priv" add -A || return 1
    fi
    git -C "$priv" commit -m "$msg" || return 1
    git -C "$priv" push || return 1

    # Record the new private commit in the public repo (only the pointer)
    git -C "$root" add private
    git -C "$root" commit -m "Update private submodule: $msg" -- private
    git -C "$root" push
}

# Git create repo: turn the current folder into a new GitHub repo and push it
# usage: gcr <name>            public repo
#        gcr <name> private    private repo
gcr() {
    if [[ -z $1 ]]; then
        echo 'gcr <name>            create a PUBLIC GitHub repo from this folder and push it'
        echo 'gcr <name> private    same, but PRIVATE'
        return 1
    fi
    local visibility=--public
    [[ $2 == (private|--private|-p) ]] && visibility=--private

    [[ -d .git ]] || git init -b main
    git add -A
    git commit -m "initial commit" || return 1
    gh repo create "$1" $visibility --source . --remote origin --push
}

# usage: gcg <filename> <description>
# create public gist
gcg ()
{
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo 'gcg <filename> <description>';
    return 1;
  fi;
  gh gist create --public "$1" -d "$2"
}

# usage: gcpg <filename> <description>
# create secret gist
gcpg ()
{
  if [ -z "$1" ] || [ -z "$2" ]; then
		echo 'gcpg <filename> <description>';
		return 1;
	fi;
    gh gist create "$1" -d "$2"
}


# gpg/encryption
alias gpge='gpg -e -s -a -r Matt\ Hammond' # Ecrypt file

# Decrypt file (secret.txt.asc -> secret.txt)
# usage: gpgd <file>
gpgd ()
{
    if [[ -z $1 ]]; then
        echo 'gpgd <file>'
        return 1
    fi
    local out="${1%.asc}"
    out="${out%.gpg}"
    [[ $out == "$1" ]] && out="$1.decrypted"
    gpg -o "$out" -d "$1"
}

# Encrypt directory
# usage: gpged <dir>
gpged ()
{
	if [ -z "$1" ]; then
		echo 'gpged <dir>';
		return 1;
	fi;
    local dir="${1%/}"
    gpgtar -e -s -r "Matt Hammond" "$dir" > "$dir.asc"
}

alias gpgdd='gpgtar -d' # Decrypt directory

# Load SSH key from USB (/Volumes/Keys), then eject. usage: load [hours] (default 1)
load() {
  local timeout=${1:-1}
  local timeout_seconds=$((timeout * 3600))
  local key_volume="/Volumes/Keys"
  local key_file="$key_volume/id_ed25519"

  print -P "%F{yellow}Waiting for USB drive with SSH key…%f"
  while [[ ! -d $key_volume ]]; do
    sleep 1
  done
  print -P "%F{green}USB drive detected%f"

  ssh-add -D
  ssh-add -t "$timeout_seconds" "$key_file" || return 1
  print -P "%F{green}SSH key loaded for ${timeout}h%f"

  diskutil eject "$key_volume"
  print -P "%F{green}USB drive ejected%f"
}

# ssh
alias vnc="ssh -f -o ExitOnForwardFailure=yes -L 15900:10.13.10.15:5900 voyager sleep 10; open vnc://127.0.0.1:15900"
alias VNC="open vnc://10.13.10.15"
alias burpON="networksetup -setwebproxy 'Wi-Fi' 127.0.0.1 8080 && networksetup -setsecurewebproxy 'Wi-Fi' 127.0.0.1 8080"
alias burpOFF="networksetup -setwebproxystate 'Wi-Fi' off && networksetup -setsecurewebproxystate 'Wi-Fi' off"

# launch commands
alias serve='nohup python3 -m http.server 80 &'
alias speedtest='cloudflare-speed-cli' # Internet speed test

# Move matching files into same-named folders. usage: f2f [globs…] (default: common video types)
f2f() {
  setopt local_options null_glob
  local patterns=("$@")
  local file folder
  (( $# )) || patterns=(*.avi *.AVI *.mp4 *.MP4 *.mkv *.MKV *.m4v *.M4V)
  for file in $patterns; do
    [[ -f $file ]] || continue
    folder=${file%.*}
    mkdir -p "$folder"
    mv "$file" "$folder/"
  done
}

# Thorough app uninstall helper
alias appclean='app-cleaner.sh'
