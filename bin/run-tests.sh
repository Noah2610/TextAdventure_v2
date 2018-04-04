#!/bin/bash

amount=6
dir="$( dirname $0 )/.."
for (( i = 0; i < $amount; i++ )); do
	if TA_ENV='test' ${dir}/TA.rb --pride; then
		continue
	else
		break
	fi
done

