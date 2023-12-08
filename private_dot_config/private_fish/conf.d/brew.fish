eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)

if test -d (brew --prefix)"/share/fish/completions"
    set -p fish_complete_path (brew --prefix)/share/fish/completions
end

if test -d (brew --prefix)"/share/fish/vendor_completions.d"
    set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end 

set -gx HOMEBREW_NO_ENV_HINTS 1
