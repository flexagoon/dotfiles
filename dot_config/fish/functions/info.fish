function info --description 'Get information about a command'
  switch (type -t $argv[1])
    case 'function'
      set -l description (functions -D --verbose $argv[1] | sed -n '5p')

      if string match -q 'alias*' $description
        echo (set_color -ou cyan)Alias(set_color normal)
        echo $description | fish_indent --ansi
        return
      end

      echo (set_color -ou cyan)Function(set_color normal)
      if test -n $description
        echo (set_color green)Description: (set_color normal)$description
      end

      functions $argv[1] | tail -n +2 | fish_indent --ansi
    case 'builtin'
      echo (set_color -ou cyan)Builtin(set_color normal)
      tldr $argv[1] >/dev/null 2>&1
      if test $status -eq 0
        tldr -q $argv[1]
        return
      end
      $argv[1] --help
    case 'file'
      set -l path (which $argv[1])
      set -l real_path (realpath $path)

      echo (set_color -ou cyan)File(set_color normal)
      echo (set_color green)Path: (set_color normal)$path
      if test -n $real_path -a $real_path != $path
        echo (set_color green)Real path: (set_color normal)$real_path
      end

      set -l pkg (rpm -qf $path 2>/dev/null)
      if test $status -eq 0
          echo (set_color green)Provided by: (set_color normal)$pkg
      end

      tldr $argv[1] >/dev/null 2>&1
      if test $status -eq 0
        tldr -q $argv[1]
        return
      end
      $argv[1] --help
  end
end
