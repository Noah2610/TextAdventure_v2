class Verbs::Close < Verbs::Verb
	def initialize args = {}
		super
	end

	def action args = {}
		return nil               if (args[:line].nil? || args[:word].nil?)
		word = args[:line].next_word pos: args[:word].position, priority: :special, ignore: ignore
		return text 'not_found'  unless (word)
		if (instance = word.instance)
			if (instance.can_close?)
				unless (instance.is_closed?)
					return text 'closed', word  if (instance.close!)
				else
					return text 'already_closed', word
				end
			else
				return text 'cannot_close', word
			end
		else
			return text 'cannot_close', word
		end
	end
end
