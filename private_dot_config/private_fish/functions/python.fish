function python --wraps=python3 --description 'Smart IPython alias'
  if test -z "$argv"
    ipython;
  else
    python3 $argv;
  end
end
