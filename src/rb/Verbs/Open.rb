class Verbs::Open < Verbs::Verb
	def initialize args = {}
		super
	end

	def action args = {}
		return nil               if (args[:line].nil? || args[:word].nil?)
		word = args[:line].next_word pos: args[:word].position, priority: :instance, ignore: ignore
		return text 'not_found'  unless (word)
		if (instance = word.instance)
			if (instance.can_open?)
				unless (instance.is_open?)
					return text 'opened', word  if (instance.open!)
				else
					return text 'already_open', word
				end
			else
				return text 'cannot_open', word
			end
		else
			return text 'cannot_open', word
		end
	end
end
