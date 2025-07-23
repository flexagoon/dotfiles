function esp --description 'Activate ESP environment'
  set IDF_PATH ~/Documents/Git/esp-idf

  set -gx IDF_TOOLCHAIN clang
  set -gx IDF_TARGET esp32c3

  source $IDF_PATH/export.fish
end
