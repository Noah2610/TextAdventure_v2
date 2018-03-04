#!/bin/env ruby

require 'colorize'
require 'curses'
require 'pathname'
require 'yaml'

## Set root directory of this script
ROOT = File.dirname(Pathname.new(File.absolute_path(__FILE__)).realpath)

## Set DIR constant with relevant paths
DIR = {
	src:        File.join(ROOT, 'src'),
	rb:         File.join(ROOT, 'src/rb'),
	misc:       File.join(ROOT, 'src/rb/misc'),
	windows:    File.join(ROOT, 'src/rb/windows'),
	settings:   File.join(ROOT, 'src/settings.yml')  # Default Settings file
}

require File.join DIR[:misc], 'handle_argument_parser'

## Load Environment class and set Environment
require File.join DIR[:rb], 'Environment'
ENVT = Environment.new CL_ARGS[:options][:env] || ENV['TA_ENV'] || 'dev'

if (ENVT.dev?)
	## Require development gems
	require 'awesome_print'
	require 'byebug'
end

## Require game code
require File.join DIR[:rb], 'Settings'
## Load settings
SETTINGS = Settings.new DIR[:settings]

require File.join DIR[:misc], 'misc'
require File.join DIR[:rb], 'main'

