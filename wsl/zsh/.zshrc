#
# Aliases
#
#

alias emacs='emacs -nw'

alias cd="z"
alias docker="podman"

# Automatic Colouring
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias ip='ip -c'

# ls shortcuts
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Safe mv & cp
alias mv="mv -i"
alias cp="cp -i"

#
# Miscellaneous
#

# Fix tramp over zsh
# Source; https://wxchen.wordpress.com/2012/05/20/getting-tramp-in-emacs-to-work-with-zsh-as-default-shell/
if [[ "$TERM" == "dumb" ]]
then
    unsetopt zle
    unsetopt prompt_cr
    unsetopt prompt_subst
    unfunction precmd
    unfunction preexec
    PS1='$ '
fi

# Stop C-s (and C-q) from fucking things up
stty -ixon

# Use emacs keybindings
bindkey -e

# Bind emacs-style command to edit command line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Warn if expansions fail
setopt nomatch

# Disable lazy cd
unsetopt auto_cd

# Don't use #~^ as part of globbing
unsetopt extended_glob

# Allow commenting of commands like in bash
setopt interactive_comments

# Navigate words like bash
autoload -U select-word-style
select-word-style bash

#
# Exports
#

# Shell
export SHELL=$(which zsh)

# Editor
export EDITOR=emacs
export VISUAL="$EDITOR"

# vex / virtualenvwrapper
export WORKON_HOME=./

# Python
export PYTHONSTARTUP=~/.pythonrc

# Path to your oh-my-zsh installation.
#export ZSH="/home/adam/.oh-my-zsh"

# Yarn
#export YARN="yarn global bin"

#
# Plugins
#

#plugins=(
#	git
#	vscode
#  	z
#	zoxide
#)

#source $ZSH/oh-my-zsh.sh

#
# Completions
#

# Useful documentation
# - http://zsh.sourceforge.net/Doc/Release/Options.html
# - http://zsh.sourceforge.net/Doc/Release/Completion-System.html

# From the generator...
zstyle ':completion:*' completer _expand _complete _match _ignored
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list '' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' verbose true

# Show group description labels (bolded)
zstyle ':completion:*:descriptions' format '%B%d%b'

# Tune make completions to be more bash-like
# (SEE https://github.com/zsh-users/zsh-completions/issues/541)
# Allow calling make to get dynamically genreated targets (may have side-effects)
zstyle ':completion:*:make:*:targets' call-command true
zstyle ':completion:*:make:*' tag-order targets
zstyle ':completion:*:make:*' group-name ''

# Don't insert tabs
zstyle ':completion:*' insert-tab false

# Start completing immediately
unsetopt list_ambiguous

# Disable cycle/inserting of suggestions
unsetopt auto_menu

# Load completions
autoload bashcompinit
bashcompinit
autoload -Uz compinit
compinit

# Enable aws cli completions
complete -C aws_completer aws

#
# History Configuration
#
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# Allow multiple shells to write history, and do so immediately
setopt inc_append_history

# Clean duplicates first form history when saving
setopt hist_expire_dups_first

# Don't show duplicates when searching
setopt hist_find_no_dups

# Don't record contiguous duplicates in history
setopt hist_ignore_dups

# Remove unnecessary whitespace when saving history
setopt hist_reduce_blanks

# Don't save history for commands prefixed with a space
setopt hist_ignore_space

#
# pyenv Setup
#
FSH_PYENV_DIR="$HOME/.pyenv/bin"
if [[ -z "$PYENV_SHELL" && -d $FSH_PYENV_DIR ]]; then
    export PATH="$FSH_PYENV_DIR:$PATH"
    if [[ -z $VIRTUAL_ENV ]]; then
        eval "$(pyenv init -)"
    fi
fi


#
# WSL Compatability
#

# Detect if running in wsl...
if [[ $(grep -qE "(Microsoft|WSL)" /proc/version) -eq 0 ]]; then
    # Fix screen
    export SCREENDIR=$HOME/.screen
    if [[ -d $SCREENDIR ]]; then
        mkdir -p -m 700 $SCREENDIR
    fi
    # Fix umask
    umask 022
fi

#
# Prompt
#
autoload -U colors
colors

if [[ -z "$FSH_PROMPT_VENV" ]]; then
    # Only set configuration if it's not already set.
    # This allows subshells to carry a temporarily overidden value.
    export FSH_PROMPT_VENV="RELATIVE"
fi

prompt_f()
{
    setopt prompt_subst

    # Virtual Environment
    if [[ -n "$VIRTUAL_ENV" ]]; then
        # Allow different styles of environment to be configured...
        if [[ "$FSH_PROMPT_VENV" == "BASE" ]]; then
            # Use the basename (the last folder) as the name of the environment.
            p_venv='%F{red}($(basename ${VIRTUAL_ENV}))%f '
        elif [[ "$FSH_PROMPT_VENV" == "RELATIVE" ]]; then
            # Use relative path between the environment and the current directory.
            p_venv='%F{red}($(realpath --relative-to=. ${VIRTUAL_ENV}))%f '
        elif [[ "$FSH_PROMPT_VENV" == "ABSOLUTE" ]]; then
            # Use absolute path to the environment.
            p_venv='%F{red}(${VIRTUAL_ENV})%f '
        else
            # Default to basename style.
            p_venv='%F{red}($(basename ${VIRTUAL_ENV}))%f '
        fi
    else
        p_venv=''
    fi

    # User
    if [[ $UID == 0 || $EUID == 0 ]]; then
        p_user='%F{red}%n%f'
    else
        p_user='%F{green}%n%f'
    fi

    # Hostname
    if [[ -n "$STY" ]]; then
        p_host='%F{cyan}%M%f'
    elif [[ -n "$SSH_CLIENT" || -n "$SSH2_CLIENT" ]]; then
        p_host='%F{yellow}%M%f'
    else
        p_host='%F{green}%M%f'
    fi

    # Directory
    p_dir='%F{blue}%~%f'

    # Build Prompt
    PROMPT='%B'${p_venv}${p_user}@${p_host}:${p_dir}'%b$ '
}

prompt_f

#
# Title
#
autoload -Uz add-zsh-hook

# References
# - Printing
#   - http://zsh.sourceforge.net/Doc/Release/Shell-Builtin-Commands.html
#   - http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
#   - http://tldp.org/HOWTO/Xterm-Title-3.html
# - Hooks
#   - http://zsh.sourceforge.net/Doc/Release/User-Contributions.html
#   - http://zsh.sourceforge.net/Doc/Release/Functions.html#Functions

title_f()
{
    # Virtual Environment
    if [[ -n "$VIRTUAL_ENV" ]]; then
        # Allow different styles of environment to be configured...
        if [[ "$FSH_PROMPT_VENV" == "BASE" ]]; then
            # Use the basename (the last folder) as the name of the environment.
            t_venv='($(basename ${VIRTUAL_ENV})) '
        elif [[ "$FSH_PROMPT_VENV" == "RELATIVE" ]]; then
            # Use relative path between the environment and the current directory.
            t_venv='($(realpath --relative-to=. ${VIRTUAL_ENV})) '
        elif [[ "$FSH_PROMPT_VENV" == "ABSOLUTE" ]]; then
            # Use absolute path to the environment.
            t_venv='(${VIRTUAL_ENV}) '
        else
            # Default to basename style.
            t_venv='($(basename ${VIRTUAL_ENV})) '
        fi
    else
        t_venv=''
    fi

    # User
    if [[ $UID == 0 || $EUID == 0 ]]; then
        t_user='%n'
    else
        t_user='%n'
    fi

    # Connection Method
    if [[ -n "$STY" ]]; then
        t_method='[screen '${STY##*.}'] '
    elif [[ -n "$SSH_CLIENT" || -n "$SSH2_CLIENT" ]]; then
        t_method='[ssh] '
    else
        t_method=''
    fi

    # Hostname
    t_host='%M'

    # Directory
    t_dir='%~'

    # Command
    if [[ -n "$1" ]]; then
        t_cmd='$ '${1}
    else
        t_cmd=''
    fi

    # Display title
    TITLE='\e]2;'${t_method}${t_venv}${t_user}@${t_host}:${t_dir}${t_cmd}'\a'
    print -Pn $TITLE
}


title_precmd () {
    title_f
}

title_preexec () {
    title_f "${(q)1}"
}

# Only attempt to register the function if the terminal supports titles
if [[ "$TERM" == (screen*|xterm*|rxvt*) ]]; then
    add-zsh-hook -Uz precmd title_precmd
    add-zsh-hook -Uz preexec title_preexec
fi


#
# Convenience functions
#
function start {
    explorer.exe `wslpath -w $1`
}
compdef _files start
alias cygstart=start


function enable-x {
    export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0
    export XCURSOR_SIZE=4
}

function disable-x {
    unset DISPLAY
    unset XCURSOR_SIZE
}

if [ -d "$HOME/.local/bin" ] ; then
	PATH="$HOME/.local/bin:$PATH"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export COLORTERM=truecolor

eval "$(zoxide init zsh)"