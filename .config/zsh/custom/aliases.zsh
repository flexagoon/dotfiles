alias sudo="doas"
alias vim="nvim"
alias pacman="sudo pacman"
alias quit="exit"
alias :q="exit"
alias apply="exec zsh"
alias acfg="vim $ZDOTDIR/custom/aliases.zsh"
alias cfg="vim $ZDOTDIR/.zshrc"
alias awcfg="vim ~/.config/awesome/rc.lua"
alias tcfg="vim ~/Documents/Suckless/st/config.def.h"
alias tmake="make clean install --directory ~/Documents/Suckless/st"
alias vimrc="vim ~/.config/nvim/init.vim"
alias pf="pfetch"
# alias nethack="sudo nethack"
alias nh="nethack"
alias mcs="~/Desktop/LocalMC/start"
alias rskill="killall -q rs2client.exe"
alias orphans="paru -Qtdq | paru -Rns -"
alias mine="xbacklight -set 1 && ethminer -U -P stratum1+ssl://0x4f6BBa6385F8D990c7AEB505E2C9372cBb8d88c2.flexagoon@eth-de.flexpool.io:5555"
alias clear="clear && echo && pfetch"
alias dl="curl -O"

alias v="f -e nvim"
alias o="a -e xdg-open"

alias make="sudo make"
alias gpasswd="sudo gpasswd"
alias grpck="sudo grpck"

alias pvim="vim -u ~/Documents/Practical\ Vim/code/essential.vim"

# Use replacements to system programs
alias grep="rg" # ripgrep
alias ls="exa"  # exa
alias cat="bat" # bat
alias ps="procs" # proc
alias top="procs --watch"

set -o kshglob
task () {
	case $1 in
		edit)   vim ~/todo                                  ;;
		list)   cat -n ~/todo                               ;;
		add)    echo ${@:2} >> ~/todo                       ;;
		random) grep -v + ~/todo | shuf -n 1                ;;
		remove)
			case $2 in
				(+([0-9])) sed -i $2'd' ~/todo      ;;
				*)         sed -i '/'$2'/d' ~/todo  ;;
			esac                                        ;;
	esac
}
