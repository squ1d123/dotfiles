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

# Bindkeys - Can use `cat` and then press key combos to get codes for here
# Ctrl + left/right to skip words
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Cool, but slows everything down :(
# antigen bundle zsh-users/zsh-autosuggestions
# bindkey '^ ' autosuggest-accept

# Highlight valid commands as green when they are typed
antigen bundle zsh-users/zsh-syntax-highlighting

antigen theme pygmalion

antigen bundle vi-mode

antigen apply

# Fix key bindings in vi-mode
source ~/.zshrc.vimode

####################################################
# exports

export EDITOR='nvim'
# Adding the below line lets emacsclient start emacs if it isn't already started
# ...Intuitive, right?
export ALTERNATE_EDITOR=''

# Make 777 stuff readable in ls
export LS_COLORS='ow=01;30;42'

export PATH="${PATH}:/${HOME}/bin:${HOME}/go/bin:${HOME}/.local/bin"

####################################################
# CUSTOM ALIASES

if command -v fd >/dev/null; then
    # fd is a program, so don't let common-aliases clobber it!
    # https://github.com/sharkdp/fd
    unalias fd
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
alias ec=$EDITOR

# Pull down a webpage as googlebot. Can often get around enforced registrations
alias googlebot='curl -L -A "Googlebot/2.1 (+http://www.google.com/bot.html)"'

# I like things simple :)
alias tree='tree --charset=ASCII'

alias psg='ps aux | grep -i'

# My git aliases
alias gac='git add -u && git commit -m'
alias gpush='git push'
alias gpull='git pull --rebase'
alias gs='git status'
alias gco='git checkout'

# Kubes
alias kb='kubectl'
alias dk='docker'
alias dc='docker-compose'

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

completions=( kubectl helm )
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

####################################################
# FUZZY FINDER
# This is installed via vim plugin.
#   https://github.com/junegunn/fzf

export FZF_DEFAULT_OPTS='--color 16'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
