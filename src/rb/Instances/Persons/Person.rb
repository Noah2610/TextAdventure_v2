
module Instances
	module Persons
		class Person < Instances::Instance
			def initialize args = {}
				super
				## Load ConversationKeywords
				@conversation_keywords = ConversationKeywords.get_for @data['conversation']['keywords']  if (@data['conversation'] && @data['conversation']['keywords'])
				## Set person for every Keyword
				@conversation_keywords.values.each { |k| k.person = self }

				@can_take = []
			end

			## Return conversational text
			def conversation_text target
				target = target.to_s
				return @data['conversation']['text'][target]  if (@data['conversation'] && @data['conversation']['text'])
				return nil
			end

			## Return ConversationKeywords
			def conversation_keywords
				return @conversation_keywords.values
				return nil
			end

			## Can take Item
			def take? item
				return false
			end

			## Take Item - via conversation and ConversationKeyword Give
			def take item
				return false
			end
		end  # END - CLASS
	end  # END - MODULE
end

