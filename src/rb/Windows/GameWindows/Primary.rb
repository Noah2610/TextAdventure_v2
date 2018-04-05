
## Primary Output Window
## All regular text (Player's responses to actions) are printed here

class Windows::Outputs::Primary < Windows::Outputs::Output
	include Windows::Large  #TODO: Remove this!
	def initialize args = {}
		super
		@border = [?|, ?=]
	end
end

