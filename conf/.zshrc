####################################################
# MACHINE SPECIFIC

if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi

####################################################
# ANTIGEN

source ~/.antigen/antigen.zsh

# Load oh-my-zsh's library.
antigen use oh-my-zsh

antigen bundle common-aliases

# Cool, but slows everything down :(
# antigen bundle zsh-users/zsh-autosuggestions
# bindkey '^ ' autosuggest-accept

# Highlight valid commands as green when they are typed
antigen bundle zsh-users/zsh-syntax-highlighting

antigen theme pygmalion

antigen bundle vi-mode

antigen bundle chisui/zsh-nix-shell

# Note that as soon as this line happens, a lot of stuff is lost (Old keybinds, etc)
antigen apply

####################################################
# KEYBINDS

# Fix key bindings in vi-mode
source ~/.zshrc.vimode

# Bindkeys - Can use `cat` and then press key combos to get codes for here
# Ctrl + left/right to skip words
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Ctrl + j/k to quickly go up/down (mimicks fzf controls)
bindkey '^K' up-line-or-search
bindkey '^J' down-line-or-search

# Where should I put you?
bindkey -s ^f "tmux-sessionizer^M"
bindkey -s ^g "open-in-gitlab^M"

####################################################
# exports
alias ec='nvim'

export EDITOR='nvim'
# Adding the below line lets emacsclient start emacs if it isn't already started
# ...Intuitive, right?
export ALTERNATE_EDITOR=''

# Make 777 stuff readable in ls
export LS_COLORS='ow=01;30;42'

export PATH="${HOME}/bin:${HOME}/go/bin:${HOME}/.local/bin:${PATH}"

####################################################
# CUSTOM ALIASES

if command -v fd >/dev/null; then
    # fd is a program, so don't let common-aliases clobber it!
    # https://github.com/sharkdp/fd
    unalias fd
fi

if command -v lt >/dev/null; then
    # lt is a program, so don't let common-aliases clobber it!
    # https://github.com/sharkdp/fd
    # unalias lt
fi

# Enable mass, easy renaming... Why isn't this a default
# http://www.mfasold.net/blog/2008/11/moving-or-renaming-multiple-files/
#   mmv *.dat *.dat_old
#   mmv foo.* bar.*
#   mmv **/*2008.mp3 **/*2009.mp3
autoload -U zmv
alias mmv='noglob zmv -W'

# Open the $EDITOR
# Named for legacy reasons from my emacs days - alias ec="emacsclient -t"
# Setting this above
# alias ec=$EDITOR

# Pull down a webpage as googlebot. Can often get around enforced registrations
alias googlebot='curl -L -A "Googlebot/2.1 (+http://www.google.com/bot.html)"'

# I like things simple :)
alias tree='tree --charset=ASCII'

alias psg='ps aux | grep -i'

# My git aliases

# Git checkout, but lowercases new branch names
function gco {
    command='git checkout'
    for ((i = 1; i <= $#; i++ )); do
        if [ "${argv[i]}" = "-b" ]; then
            ((i++))
            command+=" -b ${argv[i]:l}"
        else
            command+=" ${argv[i]}"
        fi
    done
    eval ${command}
}

alias gac='git add -u && git commit -m'
alias gpush='git push'
alias gpull='git pull --rebase'
alias gs='git status'
alias gamend='git commit --amend'
alias grebase='git fetch && git rebase -i origin/master'

# Kubes
alias kb='kubectl'
alias dk='docker'
alias dc='docker compose'

####################################################
# vi mode
# Notes from http://stratus3d.com/blog/2017/10/26/better-vi-mode-in-zshell/

# Make Vi mode transitions faster (KEYTIMEOUT is in hundredths of a second)
export KEYTIMEOUT=1

bindkey -M vicmd "^V" edit-command-line
bindkey -v

# Updates editor information when the keymap changes.
function zle-keymap-select() {
    zle reset-prompt
    zle -R
}

zle -N zle-keymap-select

function vi_mode_prompt_info() {
    echo "${${KEYMAP/vicmd/[% NORMAL]%}/(main|viins)/[% INSERT]%}"
}

# define right prompt, regardless of whether the theme defined it
RPS1='$(vi_mode_prompt_info)'
RPS2=$RPS1

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# kubectl auto completion
bindkey "^V" edit-command-line

####################################################
# AUTO COMPLETION
# Some software provides autocompletions for zsh.
# Lazy load as required.

completions=( kubectl )
for i in "${completions[@]}"
do
    if [ $commands[$i] ]; then

        # Placeholder 'kubectl' shell function:
        # Will only be executed on the first call to 'kubectl'
        $i() {
            # Remove this function, subsequent calls will execute 'kubectl' directly
            unfunction "$0"

            # Load auto-completion
            source <($0 completion zsh)

            # Execute 'kubectl' binary
            $0 "$@"
        }
    fi
done

# Start docker containers with different dev environments
# Avoids polluting whichever system you are working on
alias dknode='docker run --rm -it -u "$(id -u):$(id -g)" -v $(pwd):/tmp/workdir -w /tmp/workdir node:10.14.2-alpine sh'
alias dkrust='docker run --rm -it -u "$(id -u):$(id -g)" -v $(pwd):/tmp/workdir -w /tmp/workdir -e USER=$USER rust:1.32-slim bash'
alias dkpy3='docker run --rm -it -u "$(id -u):$(id -g)" -v $(pwd):/tmp/workdir -w /tmp/workdir python:3.7-stretch bash'
alias dkgroovy='docker run --rm -it -u "$(id -u):$(id -g)" -v $(pwd):/tmp/workdir -w /tmp/workdir groovy:2.5.7-jdk8 bash'
# Setting $HOME because nim likes to write cache files there
alias dknim='docker run --rm -it -u "$(id -u):$(id -g)" -v $(pwd):/tmp/workdir -w /tmp/workdir -e HOME=/tmp nimlang/nim:0.20.0-alpine'

####################################################
# FUZZY FINDER
# This is installed via vim plugin.
#   https://github.com/junegunn/fzf

export FZF_DEFAULT_OPTS='--color 16'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

# add asdf shims to path and install completions
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# append completions to fpath
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

. ~/.asdf/plugins/java/set-java-home.zsh

# Decorate prompt to know when inside a nix-shell env
nix_shell_active() {
  [[ -n "$IN_NIX_SHELL" ]]
}

current_prompt="$PROMPT"
PROMPT=$(nix_shell_active && echo "(nix)$PROMPT" || echo "$current_prompt")
