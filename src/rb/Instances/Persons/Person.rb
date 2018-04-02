
module Instances
	module Persons
		class Person < Instances::Instance
			include Saves::Methods::Person

			def initialize args = {}
				super
				## Load Terms
				@terms = Terms.get_for @data['conversation']['terms']  if (@data['conversation'] && @data['conversation']['terms'])
				## Set person for every Term
				@terms.values.each { |k| k.person = self }
			end

			## Return text when Player starts conversation (optional)
			def conversation_start_text
				return nil
			end

			## Return conversational text
			def conversation_text target
				target = target.to_s
				return @data['conversation']['text'][target]  if (@data['conversation'] && @data['conversation']['text'])
				return nil
			end

			## Is called when conversation ends
			def conversation_end
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

