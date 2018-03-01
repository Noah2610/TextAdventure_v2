
require File.join DIR[:misc], 'misc'
## Require curses windows
require File.join DIR[:windows], 'Windows'
require File.join DIR[:windows], 'Input'
require File.join DIR[:windows], 'PrimaryOut'

class Game
	def initialize
		## Last player input
		@input = nil

		## Initialize Curses screen
		Curses.init_screen

		## Initialize main curses windows
		@windows = {
			input: Windows::Input.new
		}

		Curses.refresh
	end

	def running?
		true
	end

	def get_input
		@windows[:input].read
	end

	def update
		Curses.clear
		Curses.refresh
		get_input
	end
end

## Start game and enter game loop
$loop_counter = 0
game = Game.new
while (game.running?)
	game.update
	$loop_counter += 1
end

