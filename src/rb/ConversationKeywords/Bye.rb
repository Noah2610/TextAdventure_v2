
class ConversationKeywords::Bye < ConversationKeywords::ConversationKeyword
	def initialize args = {}
		super
	end

	## Exit conversation
	def action
		$game.queue 1, PLAYER, :conversation_end, { keep_window: true }
		$game.queue 2, $game.window(:conversation), :hide
		return super
	end
end

