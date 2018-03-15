#!/bin/env ruby

require 'curses'
require 'pathname'
require 'yaml'

## Set root directory of this script
ROOT = File.dirname(Pathname.new(File.absolute_path(__FILE__)).realpath)

## Set DIR constant with relevant paths
DIR = {
	src:                     File.join(ROOT, 'src'),
	rb:                      File.join(ROOT, 'src/rb'),
	misc:                    File.join(ROOT, 'src/rb/misc'),
	windows:                 File.join(ROOT, 'src/rb/Windows'),
	input:                   File.join(ROOT, 'src/rb/Input'),
	verbs:                   File.join(ROOT, 'src/rb/Verbs'),
	instances:               File.join(ROOT, 'src/rb/Instances'),
	items:                   File.join(ROOT, 'src/rb/Instances/Items'),
	persons:                 File.join(ROOT, 'src/rb/Instances/Persons'),
	rooms:                   File.join(ROOT, 'src/rb/Instances/Rooms'),
	terms:   File.join(ROOT, 'src/rb/Terms'),
	data: {                  # Text files, etc
		verbs:                 File.join(ROOT, 'src/Data/Verbs'),
		items:                 File.join(ROOT, 'src/Data/Items'),
		persons:               File.join(ROOT, 'src/Data/Persons'),
		rooms:                 File.join(ROOT, 'src/Data/Rooms'),
		terms: File.join(ROOT, 'src/Data/Terms')
	},
	settings:                File.join(ROOT, 'src/settings.yml')  # Default Settings file
}

require File.join DIR[:misc], 'handle_argument_parser'

## Load Environment class and set Environment
require File.join DIR[:rb], 'Environment'
ENVT = Environment.new CL_ARGS[:options][:env] || ENV['TA_ENV'] || 'dev'

if (ENVT.dev? || ENVT.debug?)
	## Require development gems
	require 'awesome_print'
	require 'byebug'
end

require File.join DIR[:misc], 'extensions'
require File.join DIR[:misc], 'constants'
require File.join DIR[:rb], 'Settings'
SETTINGS = Settings.new DIR[:settings]
require File.join DIR[:misc], 'misc'

## Log the time to display new game
log Time.now.strftime("%H:%M:%S"), ENVT.env  unless (ENVT.prod?)
require File.join DIR[:rb], 'Game'

