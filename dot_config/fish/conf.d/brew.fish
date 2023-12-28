set -gx HOMEBREW_PREFIX /home/linuxbrew/.linuxbrew
set -gx HOMEBREW_CELLAR $HOMEBREW_PREFIX/Cellar
set -gx HOMEBREW_REPOSITORY $HOMEBREW_PREFIX/Homebrew

fish_add_path $HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin
set -gx MANPATH $HOMEBREW_PREFIX/share/man
set -gx INFOPATH $HOMEBREW_PREFIX/share/info

if test -d (brew --prefix)"/share/fish/completions"
    set -p fish_complete_path (brew --prefix)/share/fish/completions
end

if test -d (brew --prefix)"/share/fish/vendor_completions.d"
    set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end 

set -gx HOMEBREW_NO_ENV_HINTS 1
