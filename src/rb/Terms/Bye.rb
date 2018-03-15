
class Terms::Bye < Terms::Term
	def initialize args = {}
		super
	end

	## Exit conversation
	def action args = {}
		$game.queue 1, PLAYER, :conversation_end, { keep_window: true }
		$game.queue 2, $game.window(:conversation), :hide
		return super
	end
end

