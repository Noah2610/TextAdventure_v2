#!/bin/bash
## Start the game in a couple different ways

game="${HOME}/Projects/Ruby/TextAdventure_v2/TA.rb"
shell='bash'
terminal='termite'
role=
following_cmd='read -n1'
test_script='~/Projects/Ruby/TextAdventure_v2/bin/run-tests.sh'
env=
extra_args="${@:2}"
final_cmd=
floating_window=true

case "$1" in
	dev|development)
		env='dev'
		role='BORDERLESS-<LARGE-SMALL>'
		;;
	prod|production)
		env='production'
		role='BORDERLESS-FLOAT'
		;;
	dbg|debug)
		env='debug'
		role='BORDERLESS-<LARGE-SMALL>'
		following_cmd=
		;;
	test)
		env='test'
		role='BORDERLESS-<LARGE-XLARGE>'
		game_cmd="$test_script"
		;;
	custom)
		role='BORDERLESS-<LARGE-SMALL>'
		echo -en "Environment:\n\t> "
		read env
		echo -en "Arguments:\n\t> "
		read extra_args
		echo -en "Run in floating Window? [Y/n]\n\t> "
		read -n1 floating_window
		if [ -z "$floating_window" ]; then
			floating_window=true
		else
			case "$floating_window" in
				y*|Y*)
					floating_window=true ;;
				n*|N*)
					floating_window=     ;;
			esac
		fi
		;;
	*)
		floating_window=           ;;
esac

if [ -z "$game_cmd" ]; then
	if [ -n "$env" ]; then
		game_cmd="${game} -e ${env}"
	else
		game_cmd="$game"
	fi
fi

if [ -n "$extra_args" ]; then
	game_cmd="${game_cmd} ${extra_args}"
fi

if [ -n "$floating_window" ]; then
	if [ -n "$following_cmd" ]; then
		runrb run "$game_cmd" "$following_cmd" -r "$role" -t "$terminal" -s "$shell"
	else
		runrb run "$game_cmd" -r "$role" -t "$terminal" -s "$shell"
	fi
else
	$game_cmd
fi

