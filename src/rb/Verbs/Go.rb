class Verbs::Go < Verbs::Verb
	def initialize args = {}
		super
	end

	def action args = {}
		return nil                  if (args[:line].nil? || args[:word].nil?)
		word = args[:line].next_word pos: args[:word].position, priority: :room, ignore: ignore
		return text 'not_found'     unless (word)
		if (word.is?(:room) && room = word.instance)
			return text 'went', word  if (PLAYER.goto room)
			return text 'cannot_go', word
		else
			return text 'cannot_go', word
		end

	end
end
