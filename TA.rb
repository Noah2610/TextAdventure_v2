#!/bin/env ruby

require 'curses'
require 'colorize'
require 'pathname'

## Set root directory of this script
ROOT = File.dirname(Pathname.new(File.absolute_path(__FILE__)).realpath)

## Require my ArgumentParser gem or download if not installed
#  https://github.com/Noah2610/ArgumentParser
if (Gem::Specification.find_all_by_name('argument_parser').any? && false)
	require 'argument_parser'
else
	get_argumentparser_script = File.join ROOT, 'bin/get_argument_parser.sh'
	argumentparser_dir = File.join ROOT, 'lib'
	Dir.mkdir argumentparser_dir  unless (File.directory? argumentparser_dir)
	argumentparser_file = File.join argumentparser_dir, 'argument_parser.rb'
	# Output message to terminal
	puts [
		"#{__FILE__}:",
		"  Executing shell script #{get_argumentparser_script}."
	].join("\n")
	# Execute shell script
	ret = system "#{get_argumentparser_script} #{argumentparser_file}"
	if (!!ret)
		require argumentparser_file
	else
		abort "#{__FILE__}: Error:\n  Shell script exited with error; exitting."
	end
end

## Get project environment from environment variable or command-line
Env = ENV['ENV'] || 'dev'



