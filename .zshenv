export EDITOR=nvim

export XDG_DATA_HOME=${XDG_DATA_HOME:="$HOME/.local/share"}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:="$HOME/.cache"}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:="$HOME/.config"}

export LESSHISTFILE=-

export ZDOTDIR=$HOME/.config/zsh
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export GOPATH="$XDG_DATA_HOME"/go

export HISTSIZE=10000000
export SAVEHIST=10000000
export HISTFILE="$XDG_DATA_HOME"/zsh/history

export PATH="$HOME/.emacs.d/bin:$PATH:$HOME/.local/bin"
