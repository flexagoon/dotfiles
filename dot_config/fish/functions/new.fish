function new --wraps='cookiecutter https://github.com/flexagoon/cookies --directory' --description 'Create a new project from a template'
  cookiecutter https://github.com/flexagoon/cookies --directory $argv
end
