
## Input::Line is created upon every new user input.
## It contains Input::Words::* for all words in the Line.
## The Input::Words::Verb should then handle the line apropriately (maybe)

module Input
	class Line
		def initialize input, opts = {}
			@words = []
			#TODO: Don't check for attribute-codes, will be unnecessary,
			# user shouldn't be able to enter attribute-coded strings
			counter = 0
			input.scan(/{.+?}|[^ .,:;!"'$%&\/()=?+*#\-_<>|]+/) do |w|
				@words << Words.new_word(w, self, { pos: counter })
				counter += 1
			end
		end

		## Do whatever the line is supposed to do, usually call action on verb(s)
		def action
			verb = verbs.first
			return verb.action  unless (verb.nil?)
			return nil
		end

		def verbs
			return @words.map do |w|
				next w  if (w.is_verb?)
			end .reject { |x| !x }
		end

		def text
			return @words.map { |w| w.text } .join ' '
		end

		def word_at pos
			return @words[pos]
		end
	end
end

