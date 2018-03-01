
require File.join DIR[:misc], 'misc'
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

		## Initialize main curses windows
		@windows = {
			input:       Windows::Input.new,
			primary_out: Windows::PrimaryOut.new
		}

		Curses.refresh
	end

	def handle_input input
		@windows[:primary_out].print "Input: #{input}"
	end

	def running?
		true
	end

	def update
		Curses.refresh
		#Curses.clear
		# Update Primary Output Window
		@windows[:primary_out].update
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

