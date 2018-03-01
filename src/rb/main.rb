
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
			input:        Windows::Input.new,
			outputs: [
				Windows::PrimaryOut.new,
				Windows::SecondaryOut.new,
				Windows::TertiaryOut.new
			]
		}

		Curses.refresh
	end

	def handle_input input
		for_window = input.match(/[012]/).to_s.to_i
		@windows[:outputs][for_window].print "#{input.sub /[123]\s*/, ''}"
	end

	def running?
		true
	end

	def update
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

