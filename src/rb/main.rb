
### Misc constants
AP_OPTIONS = {
	indent: 2,
	plain:  true
}

### Misc methods
## Get current Curses screen size
def screen_size target = :all
	ret = nil
	case target
	when :width, :w
		ret = Curses.cols
	when :height, :h
		ret = Curses.lines
	when :all
		ret = {
			w: screen_size(:w),
			h: screen_size(:h)
		}
	end
	return ret
end

## Log, debug output
def log msg = nil, mode = 'a'
	case Env
	when 'dev'
		filepath = File.join(DIR[:log], 'dev.log')
	else
		return nil
	end

	if (msg.nil?)
		file = File.new filepath, 'w'
		file.write ''
		file.close
		return msg
	end

	file = File.new filepath, mode
	msg = msg.ai AP_OPTIONS
	file.write msg + "\n"
	file.close
	return msg
end

## Clear log
log  if (Env == 'dev')

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

