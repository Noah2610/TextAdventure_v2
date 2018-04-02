
## Primary Output Window
## All regular text (Player's responses to actions) are printed here

class Windows::Outputs::Primary < Windows::Outputs::Output
	def initialize args = {}
		super
		@border = [?|, ?=]
	end
end

