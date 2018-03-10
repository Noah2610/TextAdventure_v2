
### Require Files
## curses windows
require File.join DIR[:windows], 'Windows'
require File.join DIR[:windows], 'Input'
require File.join DIR[:windows], 'Output'

## Input stuff
require File.join DIR[:input], 'Input'
require File.join DIR[:input], 'Line'
require File.join DIR[:input], 'Words'

## Verbs
require File.join DIR[:verbs], 'Verb'
require_files File.join(DIR[:verbs]), except: 'Verb'
# Initialize all verbs
Verbs::VERBS = Verbs.init_verbs

## Inventory
require File.join DIR[:rb], 'Inventory'

## Instances (Items, Persons, Rooms)
require File.join DIR[:instances], 'Instance'

## Player
require File.join DIR[:rb], 'Player'
# Initialize Player
PLAYER = Player.new

### Start byebug then exit if in environment debug
if (ENVT.debug?)
	debugger
	exit
end

### Game
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

		output = line.action
		output = ''  if (output.nil? || output.empty?)
		@windows[:outputs][0].print output
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

### Start Game
$loop_counter = 0
$game = Game.new
while ($game.running?)
	$game.update
	$loop_counter += 1
end

