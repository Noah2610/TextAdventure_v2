
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

		## Define some color pairs
		# WHITE on BLACK
=begin
		Curses.init_pair 1, Curses::COLOR_WHITE, Curses::COLOR_BLACK
		# RED on BLACK
		Curses.init_pair 2, Curses::COLOR_RED, Curses::COLOR_BLACK
		# GREEN on BLACK
		Curses.init_pair 3, Curses::COLOR_GREEN, Curses::COLOR_BLACK
		# BLUE on BLACK
		Curses.init_pair 4, Curses::COLOR_BLUE, Curses::COLOR_BLACK
=end

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
		#Curses.attrset Curses.color_pair 2
		@windows[:outputs][0].print input #, attr: Curses.color_pair(2) | Curses::A_BOLD
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

