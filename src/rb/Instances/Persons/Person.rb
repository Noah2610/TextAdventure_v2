
module Instances
	module Persons
		class Person < Instances::Instance
			def initialize args = {}
				super
				## Load Terms
				@terms = Terms.get_for @data['conversation']['keywords']  if (@data['conversation'] && @data['conversation']['keywords'])
				## Set person for every Keyword
				@terms.values.each { |k| k.person = self }

				@can_take = []
			end

			## Return conversational text
			def conversation_text target
				target = target.to_s
				return @data['conversation']['text'][target]  if (@data['conversation'] && @data['conversation']['text'])
				return nil
			end

			## Return Terms
			def terms
				return @terms.values
				return nil
			end

			## Can take Item
			def take? item
				return false
			end

			## Take Item - via conversation and Term Give
			def take item
				return false
			end
		end  # END - CLASS
	end  # END - MODULE
end

