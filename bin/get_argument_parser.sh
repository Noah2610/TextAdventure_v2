#!/bin/bash
## Download my Ruby ArgumentParser gem

gem_url="https://raw.githubusercontent.com/Noah2610/ArgumentParser/master/lib/argument_parser.rb"
gem_output="$1"

echo

if which curl &> /dev/null; then
	echo -e "$0:\n  Downloading ArgumentParser gem from:\n    $gem_url\n  to:\n    $gem_output"
	curl -s $gem_url > $gem_output
	echo -e "  Successfully downloaded file. Continuing TextAdventure."
	exit 0
else
	>&2 echo -e "$0: Error:\n  'curl' is not installed or not in PATH, couldn't download ArgumentParser gem from:\n    $gem_url\n  Please install 'curl' or manually download the file to:\n    $gem_output\n"
	exit 1
fi

