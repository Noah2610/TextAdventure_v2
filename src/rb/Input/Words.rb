
module Input
	module Words
		## Base Word, a lot of inherits below,
		## or if a word couldn't be categorized it will create a Word
		class Word
			attr_accessor :position
			attr_reader :instance

			def initialize text, line, args = {}
				@line = line
				@text = text
				@position = args[:pos] || args[:position]
				@instance = args[:instance]  if (args[:instance])
				init args  if (defined? init)
			end

			## Check Word or @instance type
			def is? type
				return !!(self.class.name.split('::').last.downcase.to_sym == type.downcase.to_sym)  if (@instance.nil?)
				return @instance.is? type
			end
			def is_not? type
				return !!(self.class.name.split('::').last.downcase.to_sym != type.downcase.to_sym)  if (@instance.nil?)
				return @instance.is_not? type
			end

			## Return initial user's text with which Word was created
			def text
				return @text
			end
		end

		# TODO:
		## Remove unnecessary classes!
		##  - Combine Verb, Term, and Event classes
		##  - Combine all Instance Word classes

		## Verb
		class Verb < Word
			def init args = {}
				@verb = args[:verb]
			end
			def action
				return @verb.action word: self, line: @line  if (@verb)
			end
		end

		## Instances
		class Item      < Word
		end
		class Component < Word
		end
		class Person    < Word
		end
		class Room      < Word
		end

		## Term
		class Term < Word
			attr_reader :keyword
			def init args = {}
				@term = args[:term]
			end
			def action
				return @term.action word: self, line: @line  if (@term)
				return nil
			end
		end

		## Event
		class Event < Word
			def init args = {}
				@event = args[:event]
			end
			def action
				return @event.action word: self, line: @line  if (@event)
				return nil
			end
		end
	end # END - MODULE Words
end # END - MODULE Input

