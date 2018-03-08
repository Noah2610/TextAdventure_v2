
module Input
	module Words
		## Determine what Word class to create for string
		def self.new_word text, line, args = {}
			## VERBS
			Verbs::VERBS.each do |v|
				if (v.keywords.any? { |k| text =~ k.to_regex })
					args[:verb] = v
					return Words::Verb.new text, line, args
				end
			end
			return Word.new text, line, args
		end

		## Base Word, a lot of inherits below,
		## or if a word couldn't be categorized it will create a Word
		class Word
			def initialize text, line, args = {}
				@line = line
				@text = text
				@position = args[:pos]
				init args  if (defined? init)
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
				return @verb.action + ' ' + @line.word_at(@position + 1).text
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

