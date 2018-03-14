
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
			end  unless (args[:no_verbs])
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
			PLAYER.available_instances.each do |type, instances|
				instances.each do |instance|
					if (instance.keyword? text)
						args[:instance] = instance
						return Words.const_get(type.match(/\A(.+?)s?\z/)[1].capitalize).new text, line, args
					end
				end
			end

			return Word.new text, line, args  unless (args[:no_words])
			return nil
		end

		## Base Word, a lot of inherits below,
		## or if a word couldn't be categorized it will create a Word
		class Word
			attr_accessor :position
			attr_reader :instance

			def initialize text, line, args = {}
				@line = line
				@text = text
				@position = args[:pos] || args[:position]
				@instance = args[:instance]
				init args  if (defined? init)
			end

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

		class Verb < Word
			def init args = {}
				@verb = args[:verb]
			end

			def action
				return @verb.action word: self, line: @line
			end
		end

		## Instances
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

		## Conversational Word
		class Conversation < Word
			attr_reader :keyword
			def initialize line, args = {}
				@position = args[:pos] || args[:position]
				@line = line
				@keyword = args[:keyword]
			end

			def text
				return @keyword.keywords.first
			end

			def action
				return @keyword.action word: self, line: @line  if (@keyword)
				return nil
			end
		end
	end
end

