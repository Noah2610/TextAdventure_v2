
module Instances
	module Persons
		class Person < Instances::Instance
			def initialize args = {}
				super
				## Load ConversationKeywords
				@conversation_keywords = ConversationKeywords.get_for @data['conversation']['keywords']  if (@data['conversation'] && @data['conversation']['keywords'])
				## Set person for every Keyword
				@conversation_keywords.values.each { |k| k.person = self }
			end

			## Return conversational text
			def conversation_text target
				target = target.to_s
				return @data['conversation']['text'][target]  if (@data['conversation'] && @data['conversation'][target])
				return nil
			end

			## Overwrite keywords method to handle conversation mode differently
			def keywords
				return super                          if (PLAYER.mode? :normal)
				return @conversation_keywords.values  if (PLAYER.mode? :conversation)
				return nil
			end
		end  # END - CLASS
	end  # END - MODULE
end

