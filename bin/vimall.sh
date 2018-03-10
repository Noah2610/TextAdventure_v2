#!/bin/env bash

export TA_ENV="dev"

files=('./README.md' './TA.rb' './src/settings.yml' './bin/*' './vimrc' './Gemfile' './notes')
IFS=$'\n'
files_find=($( find ./src/rb/ -type f -iname '*.rb' ))
vim -c 'source ./vimrc' ${files[@]} ${files_find[@]}
