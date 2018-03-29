module TestInputHelpers
	def setup
		reset
	end

	def reset args = {}
		@rooms = Instances::Rooms::ROOMS
		@rooms[:ParsleysTruck] = Instances::Rooms::ParsleysTruck.new
		@rooms[:Cornfield]     = Instances::Rooms::Cornfield.new
		[:ParsleysTruck, :Cornfield].each do |name|
			@rooms[name].set_neighbors
		end
		@items = {
			Apple:            @rooms[:ParsleysTruck].items.first
		}
		@components = {
			GloveCompartment: @rooms[:ParsleysTruck].components.first
		}
		@persons = {
			Parsley:          @rooms[:ParsleysTruck].persons.first
		}
		PLAYER.conversation_end
		PLAYER.goto! @rooms[:ParsleysTruck]
		PLAYER.items_clear
	end

	def process_line input
		line = Input::Line.new input
		return line.process
	end
end
