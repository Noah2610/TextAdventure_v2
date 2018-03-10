
### This is the main input window.
### All commands should be entered in this window.

module Windows
	class Input < Window
		include Color

		## Define valid input keys
		VALID_KEYS = [
			(65 .. 90) .to_a,
			(97 .. 125).to_a,
			(32 .. 64) .to_a,
			95
		].flatten
		## Max size of input history
		HISTORY_MAX_SIZE = SETTINGS.input['history_size'] || 10
		PROMPT = SETTINGS.input['prompt']

		def initialize args = {}
			super

			## Set position and hight relative to terminal window
			@pos = {
				x: 0.0,
				y: 0.90
			}
			@width  = 0.75
			@height = 0.1

			## Initialize Curses Window
			@window = Curses::Window.new(
				# height,  width
				height,  width,
				# top,     left
				pos(:y), pos(:x)
			)

			## Enable keypad, fixes curses' constants
			@window.keypad true

			## Set text instance variable
			@text = ''
			@text_tmp = ''

			## Cursor position for text
			@cursor = 0

			## Padding from left edge. Start text at column @padding
			@padding = 2

			## History of commands
			@history = []
			@history_selector = 0

			@border = [?|, ?-]

			redraw
		end

		## Overwrite height with fixed hight
		def height
			return 3
		end

		## Overwrite position y with fixed position
		def pos_y
			return screen_size(:h) - height
		end

		def clear_text
			@text.clear
			@cursor = 0
		end

		def handle_arrowkey dir
			case dir
			when :up
				# Temporarily save current text in case user doesn't choose from history and comes back to this text
				if (@history_selector == 0)
					@text_tmp = @text
				end
				unless (@history_selector >= @history.size)
					@history_selector += 1
					unless (@history_selector > @history.size)
						@text = @history[@history.size - @history_selector].dup
						@cursor = @text.size
					end
				end
			when :down
				unless (@history_selector <= 0)
					@history_selector -= 1
					unless (@history_selector <= 0)
						@text = @history[@history.size - @history_selector].dup
					else
						# Come back to temporarily saved text
						@text = @text_tmp
					end
					@cursor = @text.size
				end
			when :left
				@cursor -= 1     unless (@cursor <= 0)
			when :right
				@cursor += 1     unless (@cursor >= @text.size)
			end
		end

		def handle_submit
			@history_selector = 0
			## Remove some lines from history
			if (@history.size >= HISTORY_MAX_SIZE)
				diff = (@history.size - 1) - HISTORY_MAX_SIZE
				@history = @history[diff .. -1]
			end
			unless (@history.last == @text || @text.delete(' ').empty?)
				@history << @text.dup
			end
			## Send @text to game to process
			$game.handle_input @text
			clear_text
		end

		def redraw
			## Clear all text in window
			@window.clear
			## Move window to proper position on screen
			@window.move pos(:y), pos(:x)
			## Resize window in case of terminal resize
			@window.resize height, width
			## Create border for window
			#           vert,       hor
			@window.box @border[0], @border[1]
			## Set character position
			#              y, x
			@window.setpos 1, @padding
			@window.addstr PROMPT
			## Write text from @text variable to window
			## also process attribute-codes
			text, attr_stack = process_attribute_codes @text, show: true
			print_with_attributes text, attr_stack
			attr_reset
			## Set position to proper cursor position
			@window.setpos 1, @padding + @cursor + PROMPT.size
			@window.refresh
		end

		def read
			charid = @window.getch.ord
			char = Curses.keyname charid
			case charid
			when Curses::Key::BACKSPACE, 127
				# Backspace - Remove character before cursor
				@cursor -= 1          unless (@cursor <= 0)
				@text.slice! @cursor

			when Curses::Key::DC
				# Delete - Remove character under cursor
				@text.slice! @cursor  if (@cursor < @text.size)

			when 27
				# Escape - Clear text
				clear_text

			when Curses::Key::ENTER, 10
				# Enter - Submit text
				handle_submit

			when Curses::Key::UP
				# Arrow UP
				handle_arrowkey :up

			when Curses::Key::DOWN
				# Arrow DOWN
				handle_arrowkey :down

			when Curses::Key::LEFT
				# Arrow LEFT
				handle_arrowkey :left

			when Curses::Key::RIGHT
				# Arrow RIGHT
				handle_arrowkey :right

				# Print character
			else
				if (VALID_KEYS.include? charid)
					@text.insert @cursor, char
					@cursor += 1
				end
			end

		end

		def update
			redraw
			read    unless ($game_loop == 0)
		end
	end
end

