
### Require Files
## Require all Game files (Verbs, Instances, etc.)
require File.join DIR[:misc], 'require_game_files'

## Verbs
# Initialize all Verbs
Verbs::VERBS = Verbs.init_verbs

## Player
# Initialize Player
PLAYER = Player.new
# Move Player to Room
PLAYER.goto! Instances::Rooms::ParsleysTruck.new

## Savefile
# Load development Savefile
SAVEFILE = Saves::Savefile.new 'development'
SAVEFILE.restore  unless (ENVT.test?)

### Game
class Game
	def initialize
		## Global game tick variable, increases by one every time #update is called
		@tick = 0

		## Method queue
		@queue = {}

		## Initialize Curses screen
		unless (ENVT.debug? || ENVT.test?)
			## Initialize Curses screen
			Curses.init_screen
			Curses.start_color
			## Initialize custom color-pairs
			Windows::Color.init
			## Set Escape delay
			Curses.ESCDELAY = SETTINGS.input['ESCDELAY']
		end
	end

	## Main menu
	def init_menu
		## Disable cursor for MainMenu
		Curses.curs_set 0  unless (ENVT.debug? || ENVT.test?)
		@window_manager = Windows::Managers::MainMenu.new
		@window_manager.init_curses
		update  if (running?)
	end

	## Initialize Curses Window Manager for Game
	def init_game
		## Enable cursor for Game
		Curses.curs_set 1  unless (ENVT.debug? || ENVT.test?)
		@window_manager = Windows::Managers::Game.new
		@window_manager.init_curses
		update  if (running?)
	end

	## Return current Curses screen size
	def self.screen_size target = :all
		ret = nil
		case target
		when :width, :w
			ret = Curses.cols
		when :height, :h
			ret = Curses.lines
		when :all
			ret = {
				w: self.class.screen_size(:w),
				h: self.class.screen_size(:h)
			}
		end
		return ret
	end

	def screen_size target = :all
		return self.class.screen_size target
	end

	## Handle submitted User input
	def handle_input input
		## Create Input::Line from user input
		line = Input::Line.new input
		return  unless (line)

		if (['dbg', 'debug'].include? line.text.downcase.strip)
			dbg.call
			return
		end

		## Print User's Input to UserOut output Window
		window(:user).print line.text
		## Process Line
		output = line.process

		unless (output.nil? || output.empty?)
			window(:primary).print output       if (PLAYER.mode? :normal)
			window(:conversation).print output  if (PLAYER.mode? :conversation)
		end
	end

	## Return target Window from @window_manager
	def window target
		return @window_manager.get_window target
	end

	## Add methods to queue; queueing system
	#  When to execute          On which object  The method to call;  Optional parameters
	#  according to tick        to call method   either Symbol        to be passed to
	#  (GAME.get_tick + at)          on          or String            method when called
	#         vv                     vv             vvvv                 vvvvv
	def queue at,                    on,            meth,                *args
		unless (on.methods.include? meth)
			log "WARNING: Tried to queue non-existent method '#{meth.to_s}'!"
			return false
		end
		tick = GAME.get_tick + at
		if (@queue[tick].is_a? Array)
			## Method has been set already, push to array
			@queue[tick] << [on, meth, args]
		else
			## No method set, create array with method
			@queue[tick] = [[on, meth, args]]
		end
	end

	## Check if method is ready for queue and execute
	def handle_queue
		if (meths = @queue[get_tick])
			return meths.map do |meth|
				next meth[0].method(meth[1]).call(*meth[2])
			end .all?
		end
		return nil
	end

	## Get current game tick
	def get_tick
		return @tick
	end

	## Increase game tick (by one)
	def tick_increase amount = 1
		@tick += amount
	end

	## Return true if game is running
	def running?
		return ENVT.prod? || ENVT.dev?
	end

	## Redraw all Windows and read user input
	def update
		## Handle method queue
		handle_queue

		Curses.clear
		Curses.refresh
		@window_manager.update

		## Increase game tick counter
		tick_increase
	end
end

### Start Game
GAME = Game.new
## Start main menu
unless (ENVT.debug? || ENVT.test?)
	GAME.init_menu
	#GAME.init_game
end
while (GAME.running?)
	GAME.update
end

### Exit Curses mode
Curses.close_screen  unless (ENVT.debug? || ENVT.test?)

### Start byebug then exit if in environment debug
if (ENVT.debug?)
	GAME.init_game
	debugger
	exit

	### Unit tests
elsif (ENVT.test?)
	GAME.init_game
	require File.join DIR[:test][:rb], 'Entry'
end

