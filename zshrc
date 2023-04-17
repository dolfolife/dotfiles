main() {
  setup_aliases() {
    alias vim=nvim
    alias vi=nvim
    alias ll="ls -al"
    alias drm='docker rm $(docker ps -a -q)'
    alias drmi='docker rmi $(docker images -q)'

    alias h\?="history | grep"

    alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
    alias localip="ipconfig getifaddr en0"
    alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
    alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"

    # Empty the Trash on all mounted volumes and the main HDD.
    # Also, clear Apple’s System Logs to improve shell startup speed.
    # Finally, clear download history from quarantine. https://mths.be/bum
    alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"

    # Intuitive map function
    # For example, to list all directories that contain a certain file:
    # find . -name .gitattributes | map dirname
    alias map="xargs -n1"

    # Lock the screen (when going AFK)
    alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

    # Print each PATH entry on a separate line
    alias path='echo -e ${PATH//:/\\n}'

    # kubernetes alias
    alias k=kubectl
  }

  setup_environment() {
    export CLICOLOR=1
    export LSCOLORS exfxcxdxbxegedabagacad

    # go environment
    export GOPATH=$HOME/go

    # setup path
    export PATH=$GOPATH/bin:$PATH:/usr/local/go/bin:$HOME/scripts:/usr/local/opt/apr/bin:/usr/local/opt/apr-util/bin
    export EDITOR=nvim
    export FZF_COMPLETION_TRIGGER='~~'
    export FZF_COMPLETION_OPTS='+c -x'
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'
    export PATH=/usr/local/sbin:$PATH
    export PATH=/usr/local/opt/gnu-tar/libexec/gnubin:$PATH
    export PATH=/usr/local/opt/grep/libexec/gnubin:$PATH
    export PATH=/usr/local/opt/gnu-sed/libexec/gnubin:$PATH
    export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
  }

  setup_fzf() {
    _fzf_compgen_path() {
      fd --hidden --follow --exclude ".git" . "$1"
    }

    # Use fd to generate the list for directory completion
    _fzf_compgen_dir() {
      fd --type d --hidden --follow --exclude ".git" . "$1"
    }
  }

  setup_fasd() {
    local fasd_cache
    fasd_cache="$HOME/.fasd-init-zsh"

    if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
      fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install >| "$fasd_cache"
    fi

    source "$fasd_cache"
    unset fasd_cache
    eval "$(fasd --init auto)"
  }

  setup_direnv() {
    eval "$(direnv hook zsh)"
  }

  setup_ssh_agent() {
    if [[ ! -e ~/.ssh_agent ]]; then
      if [[ -n ${SSH_AUTH_SOCK} ]]; then
        ln -sf $SSH_AUTH_SOCK ~/.ssh_agent
      fi
    fi

    export SSH_AUTH_SOCK=~/.ssh_agent
  }

  setup_colors() {
    local colorscheme
    colorscheme="${HOME}/.config/colorschemes/scripts/base16-monokai.sh"
    [[ -s "${colorscheme}" ]] && source "${colorscheme}"
  }

  setup_starship() {
    ln -sf $HOME/dolfolife/dotfiles/starship.toml ~/.config/starship.toml

    eval "$(starship init zsh)"
  }

  setup_nvm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  }

  setup_pyenv() {
    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
  }
  local dependencies
    dependencies=(
        aliases
        colors
        direnv
        environment
        fasd
        fzf
        nvm
        pyenv
        ssh_agent
        starship
      )

  for dependency in "${dependencies[@]}"; do
    eval "setup_${dependency}"
    unset -f "setup_${dependency}"
  done

	# Autocorrect typos in path names when using `cd`
  setopt autocd;
}

mainpath="$0:A"
main
unset -f main

# FUNCTIONS

function reload() {
  source "${HOME}/.zshrc"
}


pullify() {
  git config --add remote.origin.fetch '+refs/pull/*/head:refs/remotes/origin/pr/*'
  git fetch origin
}

default_hours() {
  local current_hour=$(date +%H | sed 's/^0//')
  local result=$((17 - current_hour))
  if [[ ${result} -lt 1 ]]; then
    result=1
  fi
  echo -n ${result}
}

function current_branch() { # Gets current branch
  git rev-parse --abbrev-ref HEAD
}


function parse_branch() { # Gets current branch with parens around it for some legacy things
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

function gh_remote_path() { # Parses the 'remote path' of the repo: username/repo
  REMOTE=${1:-origin}

  GH_PATH=`git remote -v | tr ':' ' ' | tr '.' ' ' | grep $REMOTE | awk '/push/ {print $4}'`
  echo ${GH_PATH#com/}
}

function gh() { # Opens current branch on Github, works for all repos
  REMOTE=${1:-origin}

  echo 'Opening branch on Github...'
  open "https://github.com/$(gh_remote_path $REMOTE)/tree/$(current_branch)"
}

function newpr() { # Opens current branch on Github in the "Open a pull request" compare view
  echo 'Opening compare on Github...'
  open "https://github.com/$(gh_remote_path)/compare/$(current_branch)?expand=1"
}

function gpu() { # Push upstream
  git push --set-upstream origin `current_branch`
}

function mkd() { # Create a new directory and enter it
  mkdir -p "$@" && cd "$_";
}

function loop() { # Repeats a given command forever
  local i=2 t=1 cond

  [ -z ${1//[0-9]/} ] && i=$1 && shift
  [ -z ${1//[0-9]/} ] && t=$1 && shift && cond=1
  while [ $t -gt 0 ]; do
    sleep $i
    [ $cond ] && : $[--t]
    $@
  done
}

function nuke() { # Straight up murders all processes matching first arg
  ps ax | grep $1 | awk '{print $1}' | xargs kill -9
}

function politely_nuke() { # As above but nicely
  ps ax | grep $1 | awk '{print $1}' | xargs kill
}

function clear_port() { # Finds whatever is using a given port (except chrome) and kills it
  lsof -t -i tcp:$1 | ag -v "$(ps aux|ag Chrome|tr -s ' '|cut -d ' ' -f 2|fmt -1024|tr ' ' '|')"| xargs kill -9
}

function v() { # Use fasd to open a file in vim from anywhere
  nvim `f "$1" | awk "{print $2}"`
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
alias python=/usr/bin/python3

# Created by `pipx` on 2022-08-02 00:02:00
export PATH="$PATH:/Users/srodolfo/.local/bin"
