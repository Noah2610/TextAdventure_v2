
module Input::Words
	## Figure out what Word class to create for string
	def self.new_word text, args = {}
		return Word.new text, args
	end

	## Base Word, a lot of inherits below,
	## or if a word couldn't be categorized it will create a Word
	class Word
		def initialize text, args = {}
			@text = text
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

	## Input::Words::Verb are supposed to handle the user input.
	class Verb < Word
		def init args = {}
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

