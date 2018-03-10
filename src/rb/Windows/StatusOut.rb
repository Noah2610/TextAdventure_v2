
## Status Output Window
## Show current Room name and Inventory Items

class Windows::StatusOut < Windows::Output
	def initialize args = {}
		super

		## Set position and hight relative to terminal window
		@pos = {
			x: 0.75,
			y: 0.0
		}
		@width  = 0.25
		@height = 1.0

		@padding = 4
		@border = [?#, ?=]
	end

	def create_lines
		@lines = [
			PLAYER.current_room.name,
			"{COLOR:red}#{(?- * (size(:w) - (@padding * 2)))}"
		]

		if (PLAYER.any_items?)
			@lines << "{ATTR:bold}Items:"
			PLAYER.items.each { |i| @lines << i.name }
		end
	end

	def update
		create_lines
		redraw
	end
end

