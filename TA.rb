#!/bin/env ruby

require 'json'
require 'pathname'
require 'yaml'

## Set root directory of this script
ROOT = File.dirname(Pathname.new(File.absolute_path(__FILE__)).realpath)

## Set DIR constant with relevant paths
DIR = {
	src:              File.join(ROOT, 'src'),
	rb:               File.join(ROOT, 'src/rb'),
	misc:             File.join(ROOT, 'src/rb/misc'),
	windows:          File.join(ROOT, 'src/rb/Windows'),
	window_managers:  File.join(ROOT, 'src/rb/Windows/Managers'),
	menu_options:     File.join(ROOT, 'src/rb/Windows/MenuOptions'),
	input:            File.join(ROOT, 'src/rb/Input'),
	verbs:            File.join(ROOT, 'src/rb/Verbs'),
	terms:            File.join(ROOT, 'src/rb/Terms'),
	instances:        File.join(ROOT, 'src/rb/Instances'),
	items:            File.join(ROOT, 'src/rb/Instances/Items'),
	components:       File.join(ROOT, 'src/rb/Instances/Components'),
	persons:          File.join(ROOT, 'src/rb/Instances/Persons'),
	rooms:            File.join(ROOT, 'src/rb/Instances/Rooms'),
	events:           File.join(ROOT, 'src/rb/Events'),
	data: {           # Text files, etc
		verbs:          File.join(ROOT, 'src/Data/Verbs'),
		terms:          File.join(ROOT, 'src/Data/Terms'),
		items:          File.join(ROOT, 'src/Data/Items'),
		components:     File.join(ROOT, 'src/Data/Components'),
		persons:        File.join(ROOT, 'src/Data/Persons'),
		rooms:          File.join(ROOT, 'src/Data/Rooms')
	},
	test: {           # For Unit Tests
		rb:             File.join(ROOT, 'src/Test/rb'),
		data: {
			# Currently   using same Instance data as in other environments
			verbs:        File.join(ROOT, 'src/Data/Verbs'),
			terms:        File.join(ROOT, 'src/Data/Terms'),
			items:        File.join(ROOT, 'src/Data/Items'),
			components:   File.join(ROOT, 'src/Data/Components'),
			persons:      File.join(ROOT, 'src/Data/Persons'),
			rooms:        File.join(ROOT, 'src/Data/Rooms')
		},
		saves:          File.join(ROOT, 'src/Test/saves')
	},
	includes:         File.join(ROOT, 'src/rb/Includes'),   # Modules that should be included to classes (Inventory, Keywords, Savable, ...)
	settings:         File.join(ROOT, 'src/settings.yml'),  # Default Settings file
	saves:            File.join(ROOT, 'saves')              # Savefiles directory
}

require File.join DIR[:misc], 'handle_argument_parser'

## Load Environment class and set Environment
require File.join DIR[:rb], 'Environment'
ENVT = Environment.new CL_ARGS[:options][:env] || ENV['TA_ENV'] || 'production'

## Require Curses library
require 'curses'  unless (ENVT.debug? || ENVT.test?)

## Require development gems
if (ENVT.dev? || ENVT.debug?)
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

