class Terms::Take < Terms::Term
	def initialize args = {}
		super
	end

	def action args = {}
		return nil               if (args[:line].nil? || args[:word].nil?)
		## Get next special word
		word = args[:line].next_word pos: args[:word].position, priority: :special, ignore: ignore
		return text 'not_found'  unless (word)
		if (instance = word.instance)
			if (instance.is? :item)
				if (PLAYER.has_item? instance)
					if (PLAYER.give instance, @person)
						return text 'given', word
					else
						return text 'cannot_give', word
					end
				else
					return text 'doesnt_have', word
				end
			else
				return text 'not_special', word
			end
		else
			return text 'not_special', word
		end
	end
end
