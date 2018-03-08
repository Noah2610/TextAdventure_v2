
## Require curses windows
require File.join DIR[:windows], 'Windows'
require File.join DIR[:windows], 'Input'
require File.join DIR[:windows], 'Output'

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
		@windows[:outputs][0].print input
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

## Log the time to display new game
log Time.now.strftime("%H:%M:%S")  if (ENVT.dev?)

## Start game and enter game loop
$loop_counter = 0
$game = Game.new
while ($game.running?)
	$game.update
	$loop_counter += 1
end

