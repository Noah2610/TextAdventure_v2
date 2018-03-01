#!/bin/env bash

export TA_ENV="dev"

files=('./TA.rb' './bin/vimall.sh' './bin/get_argument_parser.sh' './vimrc' './Gemfile')
IFS=$'\n'
files_find=($( find ./src/rb/ -type f -iname '*.rb' ))
vim -c 'source ./vimrc' ${files[@]} ${files_find[@]}
