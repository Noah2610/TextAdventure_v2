class Verbs::Look < Verbs::Verb
	def initialize args = {}
		super
	end

	def action args = {}
		return text 'not_found'  if (args[:line].nil? || args[:word].nil?)
		## Get next special word, or any word if none exist
		word = args[:line].next_word pos: args[:word].position, priority: :special, ignore: ignore
		return text 'not_found'  unless (word)
		if (instance = word.instance)
			return instance.description
		else
			return Verbs::Verb.substitute text('not_special'), word
		end
	end
end
