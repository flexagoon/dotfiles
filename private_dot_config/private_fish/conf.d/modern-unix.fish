if status is-interactive
    alias cat="bat"
    alias grep="rg"
    alias ls="lsd"
    alias tree="lsd --tree"
    zoxide init fish | source
    alias cd="z"
end
