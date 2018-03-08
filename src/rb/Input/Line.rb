
## Input::Line is created upon every new user input.
## It contains Input::Words::* for all words in the Line.
## The Input::Words::Verb should then handle the line apropriately (maybe)

class Input::Line
	def initialize input, opts = {}
		@words = []
		#TODO: Don't check for attribute-codes, will be unnecessary,
		# user shouldn't be able to enter attribute-coded strings
		input.scan(/{.+?}|[^ .,:;!"'$%&\/()=?+*#\-_<>|]+/) do |w|
			@words << Input::Words.new_word(w)
		end
	end

	def text
		return @words.map { |w| w.text } .join ' '
	end
end

