
class Verbs::Look < Verbs::Verb
	def initialize args = {}
		super
	end

	def action args = {}
		super
		if (args[:line])
			## Get next special word, or any word if none exist
			word = args[:line].next_word pos: args[:word].position, priority: :special, ignore: ignore
			if (word)
				if (instance = word.instance)
					return instance.description
				else
					return Verbs::Verb.substitute text('not_special'), word
				end
			else
				return text 'look_at_what'
			end
		else
			return text 'look_at_what'
		end
	end
end

