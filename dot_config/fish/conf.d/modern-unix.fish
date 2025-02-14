if status is-interactive
    alias cat="bat"
    alias grep="rg"
    alias ls="lsd"
    alias tree="lsd --tree"
    alias diff="nvim -d"
    set -x MANPAGER 'nvim +Man!'
    zoxide init fish --cmd n | source
    alias cd="n"
    if test ! -e /run/.toolboxenv
        alias sudo="run0"
    end
end
