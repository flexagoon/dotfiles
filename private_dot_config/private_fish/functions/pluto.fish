function pluto --wraps='julia -e "import Pluto; Pluto.run()"' --description 'alias pluto julia -e "import Pluto; Pluto.run()"'
  julia -e "import Pluto; Pluto.run()" $argv
        
end
