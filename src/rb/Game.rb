
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
require_files DIR[:verbs], except: 'Verb'
# Initialize all verbs
Verbs::VERBS = Verbs.init_verbs

## Inventory
require File.join DIR[:rb], 'Inventory'

## Terms
require File.join DIR[:terms], 'Term'

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
		## Method queue
		@queue = {}

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
		## Create Input::Line from user input
		line = Input::Line.new input
		return  unless (line)

		## Print User's Input to UserOut output Window
		window(:user).print line.text
		## Process Line
		output = line.process

		unless (output.nil? || output.empty?)
			window(:primary).print output       if (PLAYER.mode? :normal)
			window(:conversation).print output  if (PLAYER.mode? :conversation)
		end
	end

	## Return Window
	def window target
		return @windows[target]            if (@windows[target])
		return @windows[:outputs][target]  if (@windows[:outputs][target])
		return nil
	end

	## Add methods to queue; queueing system
	#  When to execute          On which object  The method to call;  Optional parameters
	#  according to $game_loop  to call method   either Symbol        to be passed to
	#  ($game_loop + at)             on          or String            method when called
	#         vv                     vv             vvvv                 vvvvv
	def queue at,                    on,            meth,                *args
		unless (on.methods.include? meth)
			log "WARNING: Tried to queue non-existent method '#{meth.to_s}'!"
			return false
		end
		tick = $game_loop + at
		if (@queue[tick])
			log "WARNING: Overwriting method '#{@queue[tick][0].class.name}.#{@queue[tick][1].to_s}(#{@queue[tick][2].join(', ')})' with method '#{on.class.name}.#{meth.to_s}(#{args.join(', ')})' in queue!"
		end
		@queue[tick] = [on, meth, args]
	end

	## Check if method is ready for queue and execute
	def handle_queue
		if (meth = @queue[$game_loop])
			return meth[0].method(meth[1]).call(*meth[2])
		end
		return nil
	end

	def running?
		true
	end

	def update
		## Handle method queue
		handle_queue

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

