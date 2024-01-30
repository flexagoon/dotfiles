if status is-interactive
    alias cat="bat"
    alias grep="rg"
    alias ls="lsd"
    alias tree="lsd --tree"
    alias diff="nvim -d"
    zoxide init fish --cmd n | source
    alias cd="n"
end
