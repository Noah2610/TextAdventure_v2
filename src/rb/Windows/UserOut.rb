
## This output Window echos User's Input

class Windows::UserOut < Windows::Output
	def initialize args = {}
		super

		## Set position and hight relative to terminal window
		@pos = {
			x: 0.0,
			y: 0.7
		}
		@width  = 0.75
		@height = 0.2

		@padding_h = 1
		@padding = 4
		@border = [?|, ?-]
		@border_color = SETTINGS.input['border_color']
		@border_attr = SETTINGS.input['border_attr']
	end

	## Overwrite height
	def height
		#return screen_size(:h) - pos(:y) - 3
		return 3
	end

	## Overwrite position y
	## because overwritten height method calls pos and pos normally calls height, avoid infinite recursion
	def pos_y
		#return (screen_size(:h) * @pos[:y]).round
		return (screen_size(:h) - 2 - height)
	end
end

