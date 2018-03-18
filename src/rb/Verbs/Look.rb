class Verbs::Look < Verbs::Verb
	def initialize args = {}
		super
	end

	def action args = {}
		return nil                              if (args[:line].nil? || args[:word].nil?)
		## Get next Instance Word, or any Word if none exist
		word = args[:line].next_word pos: args[:word].position, priority: :instance, ignore: ignore
		return PLAYER.current_room.description  if (word.nil?)
		if (instance = word.instance)
			return instance.description
		else
			return text 'not_special', word
		end
	end
end
