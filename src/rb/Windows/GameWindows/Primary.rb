
## Primary Output Window
## All regular text (Player's responses to actions) are printed here

class Windows::Outputs::Primary < Windows::Outputs::Output
	include Windows::Large
	def initialize args = {}
		super
		@border = [?|, ?=]
	end
end

