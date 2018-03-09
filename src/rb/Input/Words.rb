
module Input
	module Words
		## Determine what Word class to create for string
		def self.new_word text, line, args = {}
			## VERBS
			Verbs::VERBS.each do |v|
				if (v.keyword? text)
					args[:verb] = v
					return Words::Verb.new text, line, args
				end
			end
			## INSTANCES
			## The way to get instances here is to somehow figure out and get
			## a list of all currently available Items/Persons/Rooms
			## Examples:
			# ITEMS:
			#  inventory Items, Items in Room, Items in Person's inventory in Room
			# PERSONS:
			#  Persons in Room
			# ROOMS:
			#  current Room, adjacent Rooms (neighbors)
			## Probably get this list through a new Player class
=begin
			Instances.constants.each do |constname|
				constant = Instances.const_get constname
				next    unless (constant.is_a? Module)
				## Loop through all Items/Persons/Rooms
				constant.constants.each do |instancename|
					instance = constant.const_get instancename
					next  unless (instance.is_a? Class)
				end
			end
=end

			return Word.new text, line, args
		end

		## Base Word, a lot of inherits below,
		## or if a word couldn't be categorized it will create a Word
		class Word
			attr_reader :position

			def initialize text, line, args = {}
				@line = line
				@text = text
				@position = args[:pos]
				init args  if (defined? init)
			end

			def is? type
				return !!(self.class.name.split('::').last.downcase.to_sym == type.downcase.to_sym)
			end

			def is_not? type
				return !!(self.class.name.split('::').last.downcase.to_sym != type.downcase.to_sym)
			end

			def is_word?
				return !!(self.class == Input::Words::Word)
			end
			def is_verb?
				return !!(self.class == Input::Words::Verb)
			end
			def is_item?
				return !!(self.class == Input::Words::Item)
			end
			def is_person?
				return !!(self.class == Input::Words::Person)
			end
			def is_room?
				return !!(self.class == Input::Words::Room)
			end

			def text
				return @text
			end
		end

		class Verb < Word
			def init args = {}
				@verb = args[:verb]
			end

			def action
				return @verb.action word: self, line: @line
			end
		end

		class Item < Word
			def init args = {}
			end
		end

		class Person < Word
			def init args = {}
			end
		end

		class Room < Word
			def init args = {}
			end
		end
	end
end

