#!/bin/env bash

export ENV="dev"

files=('./TA.rb' './bin/vimall.sh' './vimrc')
IFS=$'\n'
files_find=($( find ./src/rb/ -type f -iname '*.rb' ))
vim -c 'source ./vimrc' ${files[@]} ${files_find[@]}
