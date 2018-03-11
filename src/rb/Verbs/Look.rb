class Verbs::Look < Verbs::Verb
	def initialize args = {}
		super
	end

	def action args = {}
		return nil                              if (args[:line].nil? || args[:word].nil?)
		## Get next special word, or any word if none exist
		word = args[:line].next_word pos: args[:word].position, priority: :special, ignore: ignore
		return PLAYER.current_room.description  if (word.nil?)
		if (instance = word.instance)
			return instance.description
		else
			return Verbs::Verb.substitute text('not_special'), word
		end
	end
end
