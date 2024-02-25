# Base directories
set -gx XDG_CACHE_HOME ~/.cache
set -gx XDG_DATA_HOME ~/.local/share
set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_STATE_HOME ~/.local/state

# Android
set -gx ANDROID_HOME $ANDROID_USER_HOME/sdk
set -gx ANDROID_USER_HOME $XDG_DATA_HOME/android
alias adb "HOME=$ANDROID_USER_HOME command adb"

# Bash
set -gx HISTFILE $XDG_STATE_HOME/bash/history

# Fly
set -gx FLY_CONFIG_DIR $XDG_STATE_HOME/fly

# GnuPG
set -gx GNUPGHOME $XDG_DATA_HOME/gnupg

# Go
set -gx GOPATH $XDG_DATA_HOME/go
set -gx GOMODCACHE $XDG_CACHE_HOME/go/mod

# Cuda
set -gx CUDA_CACHE_PATH $XDG_CACHE_PATH/nv

# GDB
set -gx GDBHISTFILE $XDG_CONFIG_HOME/gdb/gdb_history

# GnuPG
set -gx GNUPGHOME $XDG_DATA_HOME/gnupg

# Java
set -gx GRADLE_USER_HOME $XDG_DATA_HOME/gradle
set -gx _JAVA_OPTIONS -Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java

# Julia
set -gx JULIA_DEPOT_PATH $XDG_DATA_HOME/julia
set -gx JULIAUP_DEPOT_PATH $XDG_DATA_HOME/julia

# Mathematica
set -gx MATHEMATICA_USERBASE $XDG_CONFIG_HOME/mathematica

# NPM
set -gx NPM_CONFIG_USERCONFIG $XDG_CONFIG_HOME/npm/npmrc

# Python
set -gx PYTHONSTARTUP $XDG_CONFIG_HOME/pythonrc
set -gx IPYTHONDIR $XDG_CONFIG_HOME/ipython

# Rust
set -gx CARGO_HOME $XDG_DATA_HOME/cargo
set -gx RUSTUP_HOME $XDG_DATA_HOME/rustup

# SSH
alias ssh "ssh -o UserKnownHostsFile=$XDG_DATA_HOME/ssh/known_hosts"

# SQLite
set -gx SQLITE_HISTORY $XDG_CACHE_HOME/sqlite_history

# Wakatime
set -gx WAKATIME_HOME $XDG_CONFIG_HOME/wakatime

# Wget
alias wget "wget --hsts-file=$XDG_DATA_HOME/wget-hsts"

# Wine
set -gx WINEPREFIX $XDG_DATA_HOME/wine
