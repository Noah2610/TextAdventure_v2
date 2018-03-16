class Verbs::Open < Verbs::Verb
	def initialize args = {}
		super
	end

	def action args = {}
		return nil               if (args[:line].nil? || args[:word].nil?)
		word = args[:line].next_word pos: args[:word].position, priority: :special, ignore: ignore
		return text 'not_found'  unless (word)
		if (instance = word.instance)
			if (instance.can_open? && instance.open!)
				return text 'opened', word
			else
				return text 'cannot_open', word
			end
		else
			return text 'cannot_open', word
		end
	end
end
