
## Status Output Window
## Show current Room name and Inventory Items

class Windows::Outputs::Status < Windows::Outputs::Output
	def initialize args = {}
		super

		@padding = 4
		@border = [?#, ?=]
	end

	def create_lines
		current_room_name = PLAYER.current_room ? PLAYER.current_room.name : '{ATTR:standout}NOWHERE{RESET}'
		@lines = [
			current_room_name,
			"{COLOR:red}#{(?- * ([size(:w) - (@padding * 2), 0].max))}"
		]

		if (PLAYER.any_items?)
			@lines << "{ATTR:bold}Items:"
			PLAYER.items.each { |i| @lines << i.name }
		end
	end

	def update
		if (shown?)
			create_lines
			redraw
		end
	end
end

