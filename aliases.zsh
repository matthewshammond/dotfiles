# ex - archive extractor
# usage: ex <file>
ex ()
{
    if [ -z "$1" ]; then
        echo 'ex <file>';
        return 1;
    fi;
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1   ;;
            *.tar.gz)    tar xzf $1   ;;
            *.tar.xz)    tar xJf $1   ;;
            *.bz2)       bunzip2 $1   ;;
            *.rar)       unrar x $1   ;;
            *.gz)        gunzip $1    ;;
            *.tar)       tar xf $1    ;;
            *.tbz2)      tar xjf $1   ;;
            *.tgz)       tar xzf $1   ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1;;
            *.7z)        7z x $1      ;;
            *)           echo "'$1' cannot be extracted via ex()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
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
    cd /Users/matthammond/projects/website && hugo new content articles/2025/"$1".md --kind article && vim content/articles/2025/"$1".md
}

# Download youtube video
# usage: youtube <url>
youtube ()
{
    if [ -z "$1" ]; then
        echo 'youtube <url>';
        return 1;
    fi;
    youtubedr download -d ~/Downloads/ -m mp4 -q hd1080 "$1"
}

# Get PID of process
# usage: pidof <process>
 pidof()
 {
	if [ -z "$1" ]; then
		echo 'pidof PROCESS';
		return 1;
	fi;
	ps aux | grep -v grep | grep "$1" | awk '{print $2}';
}

# Expose Postgresql to pgadmin4
# usage: pgproxy on <CHANGEME> <port:5433>
# usage: pgproxy off <CHANGEME>
pgproxy() {
  local action=$1
  local id=$2
  local port=${3:-5433}  # Default to 5433 if no port is provided
  local container="aerostatus_db-$id"
  local proxy_name="pgproxy-$id"
  local network="aerostatus_app-network"

  if [[ -z "$action" || -z "$id" ]]; then
    echo "Usage: pgproxy on|off <instance-id> [local-port]"
    return 1
  fi

  if [[ "$action" == "on" ]]; then
    echo "Starting pgproxy for $container as $proxy_name on localhost:$port..."
    docker run -d \
      --name "$proxy_name" \
      --network "$network" \
      -p "$port":5432 \
      alpine/socat \
      TCP-LISTEN:5432,fork,reuseaddr TCP:"$container":5432
  elif [[ "$action" == "off" ]]; then
    echo "Stopping pgproxy container $proxy_name..."
    docker rm -f "$proxy_name" >/dev/null 2>&1 || echo "No running proxy found for $id"
  else
    echo "Invalid action: $action (use 'on' or 'off')"
    return 1
  fi
}


export EDITOR=nvim

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
alias -g ..='cd ..'
alias -g ...='cd ../..'
alias -g ....='cd ../../..'
alias -- ~='cd ~'
alias -- /='cd /'
alias -- -='cd -'
alias listen='lsof -i TCP -n -P | grep LISTEN'
alias cat='bat -p'
alias ip='[ $(piactl get connectionstate) = "Connected" ] && echo "VPN IP:" $(piactl get vpnip) || echo "PUB IP:" $(curl -s ifconfig.me)'
alias mac="printf '%s\n' 'Spoofed MAC address of en0 interface to $(ifconfig en0 | grep ether | awk '{print $2}')'; printf '%s\n' 'Hardware MAC address of en0 interface is $(networksetup -listallhardwareports | awk -v RS= '/en0/{print $NF}')'"
alias update='brew update && brew upgrade && brew cleanup -s && brew autoremove && mas outdated && mas upgrade && rm -rf $(brew --cache) && sketchybar --trigger forced --set widgets.brew'
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"'

# editing
alias scratchpad='${=EDITOR} ~/.scratchpad' # Quick access to the ~/.scratchpad file
alias zshrc='${=EDITOR} ~/.zshrc' # Quick access to the ~/.zshrc file
alias backup='rsync -av --exclude={".DS_Store",".git*","Icon?"} ~/Documents/Maps/AUG/ /Volumes/Go\ Drive/AU\ Health/AUG/' # Sync AUG map files to USB
alias bu='rsync -av --exclude={".DS_Store",".git*","Icon?"} ~/Documents/Maps/AUG/ ~/Documents/Maps/AUG\ Backup/' # Sync AUG map files to backup dir
alias record='asciinema rec -i 0.5 -t' # Start terminal recording #usage: record <filename>
alias lock='chflags uchg' #Lock file
alias unlock='chflags nouchg' #Unlock file

# searching
alias grep='grep --color'
alias exploitdb='cd /opt/homebrew/opt/exploitdb/share/exploitdb && ls'

alias ff="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'" # Find file recurssively using fzf
alias ef='vim "$(ff)"' # open file in vim
alias of='open "$(ff)"' # open file on desktop
alias pf='qlmanage -p "$(ff)"'
alias ql='qlmanage -p $1 2>/dev/null'
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

# Git Private Commit
# usage: gpc <name> <message>
gpc () {
    if [ -z "$1" ] && [ -z "$2" ]
    then
        # If no arguments, check for changes in private files
        echo "🔍 Checking for changes in private files..."
        # Check root level private files
        for file in .gitconfig .gnupg/* .ntfy.yml .ssh/* hosts*; do
            if [ -f "$file" ] && [ -f "private/$file" ]; then
                if ! cmp -s "$file" "private/$file"; then
                    echo "Modified: $file"
                fi
            fi
        done
        # Check .config directories
        for dir in "asciinema" "gh"; do
            if [ -d ".config/$dir" ] && [ -d "private/.config/$dir" ]; then
                # Using diff to check directory differences
                if ! diff -r ".config/$dir" "private/.config/$dir" >/dev/null 2>&1; then
                    echo "Modified: .config/$dir"
                fi
            fi
        done
        return 0
    fi

    if [ -z "$1" ] || [ -z "$2" ]
    then
        echo 'gpc <file> <message>'
        return 1
    fi

    # Check if we're in a private clone
    if [ ! -d "private" ]; then
        echo "Error: This is not a private clone. Use regular git commands instead."
        return 1
    fi
    
    # Handle .config directories specially
    if [[ "$1" == .config/* ]]; then
        # Extract the directory name after .config/
        config_dir=$(echo "$1" | cut -d'/' -f2)
        if [[ "$config_dir" == "asciinema" || "$config_dir" == "gh" ]]; then
            # Create .config directory in private if it doesn't exist
            mkdir -p "private/.config"
            # Copy the entire directory
            cp -R ".config/$config_dir" "private/.config/"
            
            # Then commit in the private repository (submodule)
            cd "$(git rev-parse --show-toplevel)"
            git -C private add -f ".config/$config_dir"
            git -C private commit -m "$2"
            git -C private push
            
            # Then update the submodule reference in the main repository
            git add private
            git commit -m "Update private submodule: $2"
            git push
            return 0
        fi
    fi
    
    # Handle regular private files (existing logic)
    cp -f "$1" "private/$1"
    
    # Then commit in the private repository (submodule)
    cd "$(git rev-parse --show-toplevel)"
    git -C private add -f "$1"
    git -C private commit -m "$2"
    git -C private push
    
    # Then update the submodule reference in the main repository
    git add private
    git commit -m "Update private submodule: $2"
    git push
}

# Create git repository
# usage: gcr <name>
gcr()
{
	if [ -z "$1" ]; then
		echo 'gcr <name>';
		return 1;
	fi;
    gh repo create "$1" --public
    git init
    git add .
    git commit -m "initial commit"
    git branch -M main
    git remote add origin git@github.com:matthewshammond/"$1".git
    git push -u origin main
}

# Create private git repository
# usage: gcpr <name>
gcpr()
{
	if [ -z "$1" ]; then
		echo 'gcpr <name>';
		return 1;
	fi;
    gh repo create "$1" --private
    git init
    git add .
    git commit -m "initial commit"
    git branch -M main
    git remote add origin git@github.com:matthewshammond/"$1".git
    git push -u origin main
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

# Decrypt file
# usage: gpgd <file>
gpgd ()
{
	if [ -z "$1" ]; then
		echo 'gpgd <file>';
		return 1;
	fi;
    file=$1
    decrypted_file=${file/\.asc/}
    gpg -d "$1" > "$decrypted_file"
}

# Encrypt directory
# usage: gpged <dir>
gpged ()
{
	if [ -z "$1" ]; then
		echo 'gpged <dir>';
		return 1;
	fi;
    gpgtar -e -s -r Matt\ Hammond "$1" > "$1".asc
}

alias gpgdd='gpgtar -d' # Decrypt directory
alias load='load-ssh.sh'

# ssh
# alias gemini="ssh -J voyager Gemini -t '/usr/local/bin/tmux -CC attach || /usr/local/bin/tmux -CC'"
# alias Gemini="ssh Gemini -t '/usr/local/bin/tmux -CC attach || /usr/local/bin/tmux -CC'"
# alias voyager="ssh voyager -t '/opt/homebrew/bin/tmux -CC attach || /opt/homebrew/bin/tmux -CC'"
alias voyager="ssh voyager -t '/opt/homebrew/bin/tmux attach || /opt/homebrew/bin/tmux new'"
# alias Voyager="ssh Voyager -t '/opt/homebrew/bin/tmux -CC attach || /opt/homebrew/bin/tmux -CC'"
# alias magellan="ssh -J voyager Magellan -t 'tmux -CC attach || tmux -CC'"
# alias Magellan="ssh Magellan -t 'tmux -CC attach || tmux -CC'"
# alias artemis="ssh -J voyager Artemis"
# alias Artemis="ssh Artemis"
# alias apollo="ssh -J voyager Apollo -t 'tmux -CC attach || tmux -CC'"
alias apollo="tailscale ssh apollo -t 'tmux attach || tmux new'"
# alias Apollo="ssh Apollo -t 'tmux -CC attach || tmux -CC'"
# alias atlas="ssh -J voyager Atlas -t 'tmux -CC attach || tmux -CC'"
alias atlas="tailscale ssh atlas -t 'tmux attach || tmux new'"
# alias Atlas="ssh Atlas -t 'tmux -CC attach || tmux -CC'"
# alias aeropoint="ssh aeropoint -t '/usr/bin/tmux -CC attach || /usr/bin/tmux -CC'"
alias aeropoint="ssh aeropoint -t 'tmux attach || tmux new'"
alias vnc="ssh -f -o ExitOnForwardFailure=yes -L 15900:10.13.10.15:5900 voyager sleep 10; open vnc://127.0.0.1:15900"
alias VNC="open vnc://10.13.10.15"
alias proxy="nohup /Applications/ProxyToggle.app/Contents/MacOS/ProxyToggle > /dev/null 2>&1 &"
alias burpON="networksetup -setwebproxy 'Wi-Fi' 127.0.0.1 8080 && networksetup -setsecurewebproxy 'Wi-Fi' 127.0.0.1 8080"
alias burpOFF="networksetup -setwebproxystate 'Wi-Fi' off && networksetup -setsecurewebproxystate 'Wi-Fi' off"

# launch commands
alias serve='nohup python3 -m http.server 80 &'
alias pgstart='pg_ctl -D /opt/homebrew/var/postgresql@14 start'
alias pgstop='pg_ctl -D /opt/homebrew/var/postgresql@14 stop'
