
class Verbs::Look < Verbs::Verb
	def initialize args = {}
		super
	end

	def action args = {}
		super
		if (args[:line])
			## Get next special word, or any word if none exist
			word = args[:line].next_word pos: args[:word].position, priority: :special
			if (word)
				return @data['texts']['look'] + word.text
			else
				return @data['texts']['not_found']
			end
		else
			return @data['texts']['not_found']
		end
	end
end

