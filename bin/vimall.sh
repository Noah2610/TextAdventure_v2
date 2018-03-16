#!/bin/env bash

export TA_ENV="dev"

files=('./README.md' './TA.rb' './src/settings.yml' './bin/*' './vimrc' './Gemfile' './notes')
IFS=$'\n'
files_find=($( find ./src/ -type f -iname '*.rb' ))
vim '+source ./vimrc' '+b src/rb/Game.rb | vsp | b TA.rb | tabnew % | b src/rb/Player.rb' ${files[@]} ${files_find[@]}
