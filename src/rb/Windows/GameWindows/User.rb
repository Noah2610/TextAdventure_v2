
## This output Window echos User's Input

class Windows::Outputs::User < Windows::Outputs::Output
	def initialize args = {}
		super

		@padding_default = 4
		@padding_h = 1
		@padding = @padding_default
		@border = [?|, ?-]
		@border_color = SETTINGS.input['border_color']
		@border_attr = SETTINGS.input['border_attr']
	end

	## Overwrite print to include prompt if in conversation mode
	def print text, args = {}
		text = [text].flatten
		if (PLAYER.mode? :conversation)
			prompt = SETTINGS.input['prompt_conversation']
			text[0] = "#{prompt}#{text[0]}"
			@padding = GAME.window(:input).padding
		else
			@padding = @padding_default  unless (@padding == @padding_default)
		end
		super text, args
	end
end

