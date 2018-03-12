
module Instances
	module Persons
		class Person < Instances::Instance
			attr_reader :data
			def initialize args = {}
				super
				## Load ConversationKeywords
				@data['conversation_keywords'] = ConversationKeywords.data self.class
			end

			## Return all available conversational verbs
			def conversation_verbs
				return @data['conversation']['verbs']
			end
			## Return all available conversational keywords
			def conversation_keywords
				return @data['conversation']['keywords']
			end
			## Return all available conversational keyphrases
			def conversation_keyphrases
				return @data['conversation']['keyphrases']
			end

			## Check if string is verb, and return verb
			def conversation_keyword? string
			end
			## Check if string is keyword
			## Check if string is keyphrase

			## Return type and name of keyword, if any matches (verbs, keywords, keyphrases)
			def conversation_word? string
				## Check verbs

				## Check keyphrases
				## Check keywords
			end
		end  # END - CLASS
	end  # END - MODULE
end

