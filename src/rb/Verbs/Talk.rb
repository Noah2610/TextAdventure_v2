class Verbs::Talk < Verbs::Verb
	def initialize args = {}
		super
	end

	def action args = {}
		return nil               if (args[:line].nil? || args[:word].nil?)
		word = args[:line].next_word pos: args[:word].position, priority: :special, ignore: ignore
		return text 'not_found'  unless (word)
		if    (word.is? :word)
			# Word is not special - is Word
			return text 'not_found', word
		elsif (word.is_not? :person)
			# Word is not Person
			return text 'cannot_talk', word
		elsif (word.is?(:person) && instance = word.instance)
			# Word IS Person
			## Set to conversation-mode
			PLAYER.conversation_start instance
			return nil
		end
	end
end
