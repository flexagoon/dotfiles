set -gx EDITOR nvim
set -gx MANPAGER 'nvim +Man!'
if status is-interactive
    alias diff="nvim -d"
end
