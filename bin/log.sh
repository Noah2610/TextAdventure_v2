#!/bin/bash
## Just execute tail and follow changes to log file

file="$1"
if [ -z "$file" ]; then
	file="./log/development.log"
fi

tail -f $file

