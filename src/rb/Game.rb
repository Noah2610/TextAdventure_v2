
### Require Files
## curses windows
require File.join DIR[:windows], 'Window'
require File.join DIR[:windows], 'Input'
require File.join DIR[:windows], 'Output'
require File.join DIR[:windows], 'PrimaryOut'
require File.join DIR[:windows], 'ConversationOut'
require File.join DIR[:windows], 'UserOut'
require File.join DIR[:windows], 'StatusOut'

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
# Move Player to Room
PLAYER.goto! Instances::Rooms::ROOMS[:ParsleysTruck]

### Start byebug then exit if in environment debug
if (ENVT.debug?)
	debugger
	exit
end

### Game
class Game
	def initialize
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
			outputs: {
				primary:      Windows::PrimaryOut.new,
				conversation: Windows::ConversationOut.new,
				user:         Windows::UserOut.new,
				status:       Windows::StatusOut.new
			}
		}

		Curses.refresh
	end

	def handle_input input
		#@windows[:outputs][0].print input

		## Create Input::Line from user input
		line = Input::Line.new input

		@windows[:outputs][:user].print line.text

		output = line.action
		@windows[:outputs][:primary].print output  unless (output.nil? || output.empty?)
	end

	## Return Window
	def window target
		return @windows[target]            if (@windows[target])
		return @windows[:outputs][target]  if (@windows[:outputs][target])
		return nil
	end

	def running?
		true
	end

	def update
		## Reset Curses attributes
		# Color-pair
		#Curses.attrset Curses.color_pair(1)

		Curses.clear
		Curses.refresh
		# Update Output Windows
		@windows[:outputs].values.each &:update
		# Update Input Window - Should be called last because it reads input
		@windows[:input].update
	end
end

### Start Game
$game_loop = 0
$game = Game.new
while ($game.running?)
	$game.update
	$game_loop += 1
end

