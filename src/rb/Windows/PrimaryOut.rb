
## Primary Output Window
## All regular text (Player's responses to actions) are printed here

class Windows::PrimaryOut < Windows::Output
	def initialize args = {}
		super

		## Set position and hight relative to terminal window
		@pos = {
			x: 0.0,
			y: 0.0
		}
		@width  = 0.75
		@height = 0.7

		@border = [?|, ?=]
	end
end

