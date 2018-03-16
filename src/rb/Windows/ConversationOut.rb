
## This output Window is only displayed when Player is in a conversation

class Windows::ConversationOut < Windows::Output
	def initialize args = {}
		super
		## Set position and hight relative to terminal window
		@pos = {
			x: 0.0,
			y: 0.35
		}
		@width  = 0.75
		@height = 0.35

		@border = [?#, ?#]
		@border_color = 'magenta'

		## Hidden by default
		@hidden = true

		@prompt = SETTINGS.output['prompt_conversation']
	end

	## Overwrite height to be half of PrimaryOut's height
	def height
		return ((screen_size(:h) - 5).to_f * 0.5).floor
	end

	## Overwrite pos_y to be half of PrimaryOut's height
	def pos_y
		return ((screen_size(:h) - 5).to_f * 0.5).ceil
	end

	## Overwrite print to include prompt if in conversation mode
	def print text, args = {}
		text = [text].flatten
		text[0] = "#{@prompt}#{text[0]}"
		super text, args
	end
end

