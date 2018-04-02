
## This output Window is only displayed when Player is in a conversation

class Windows::Outputs::Conversation < Windows::Outputs::Output
	def initialize args = {}
		super

		@border = [?#, ?#]
		@border_color = 'magenta'

		## Hidden by default
		@hidden = true

		@prompt = SETTINGS.output['prompt_conversation']
	end

	## Overwrite print to include prompt if in conversation mode
	def print text, args = {}
		text = [text].flatten
		text[0] = "#{@prompt}#{text[0]}"
		super text, args
	end
end

