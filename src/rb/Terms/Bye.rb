
class Terms::Bye < Terms::Term
	def initialize args = {}
		super
	end

	## Exit conversation
	def action args = {}
		$game.queue 1, PLAYER, :conversation_end, { keep_window: true }
		return super
	end
end

