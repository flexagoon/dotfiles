function idf.py --description 'Run idf.py for the first time'
  set IDF_PATH ~/Documents/Git/esp-idf

  set -gx IDF_TOOLCHAIN clang
  set -gx IDF_TARGET esp32c3

  source $IDF_PATH/export.fish

	functions -e idf.py
	idf.py $argv
end
