# A simple project templating tool. Basic alternative to cookiecutter, copier, etc.
# I had to write this since Cookiecutter doesn't support XDG directories and puts
# shit in my $HOME, and Copier doesn't allow having multiple templates in the same
# repository.
function new  --description 'Create a new project from a template'
  if test (count $argv) -lt 2
    echo 'Usage: new <template> <name>'
    return 1
  end

  set -l cookies $XDG_DATA_HOME/cookies

  if test ! -d $cookies
    git clone https://github.com/flexagoon/cookies $XDG_DATA_HOME/cookies
  else
    env -C $cookies git pull > /dev/null
  end

  set -l template $argv[1]
  set -l name $argv[2]

  cp -r $cookies/$template $name
  cd $name

  git init > /dev/null
  git remote add origin https://github.com/(git config user.name)/$name

  if test -f _hooks.fish
    PROJECT_NAME=$name fish _hooks.fish && rm _hooks.fish
  end
end
