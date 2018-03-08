
## Require curses windows
require File.join DIR[:windows], 'Windows'
require File.join DIR[:windows], 'Input'
require File.join DIR[:windows], 'Output'

## Require Input stuff
require File.join DIR[:input], 'Input'
require File.join DIR[:input], 'Line'
require File.join DIR[:input], 'Words'

## Require Verbs
require File.join DIR[:verbs], 'Verb'
require_files File.join(DIR[:verbs]), except: 'Verb'
## Initialize all verbs
Verbs::VERBS = Verbs.init_verbs

## Require Instance
require File.join DIR[:instances], 'Instance'

## Require Items
require File.join DIR[:items], 'Item'
require_files File.join(DIR[:items]), except: 'Item'
## Initialize a part of all Items, so we can recognize their keywords
Instances::Items::ITEM_DATA = Instances::Items.load_item_data
Instances::Items::Apple.new

class Game
	def initialize
		## Last player input
		@input = nil

		## Initialize Curses screen
		Curses.init_screen
		Curses.start_color
		## Initialize custom color-pairs
		Windows::Color.init
		## Set Escape delay
		Curses.ESCDELAY = SETTINGS.input['ESCDELAY']

		## Initialize main curses windows
		@windows = {
			input:        Windows::Input.new,
			outputs: [
				Windows::PrimaryOut.new,
				#Windows::SecondaryOut.new,
				#Windows::TertiaryOut.new
			]
		}

		Curses.refresh
	end

	def handle_input input
		#@windows[:outputs][0].print input

		## Create Input::Line from user input
		line = Input::Line.new input

		@windows[:outputs][0].print line.action || ''
	end

	def running?
		true
	end

	def update
		## Reset Curses attributes
		# Color-pair
		#Curses.attrset Curses.color_pair(1)

		Curses.refresh
		Curses.clear
		# Update Primary Output Window
		@windows[:outputs].each &:update
		# Update Input Window - Should be called last because it reads input
		@windows[:input].update
	end
end

## Start game and enter game loop
$loop_counter = 0
$game = Game.new
while ($game.running?)
	$game.update
	$loop_counter += 1
end

