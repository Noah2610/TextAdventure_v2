
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
			return verbs.map do |verb|
				next verb.action
			end .reject { |x| !x }
		end

		def verbs
			return @words.map do |word|
				next word  if (word.is_verb?)
			end .reject { |x| !x }
		end

		def text
			return @words.map { |word| word.text } .join ' '
		end

		## Return word in line at position pos
		def word_at pos
			return @words[pos]
		end

		## Return next word at and with some options
		def next_word args = {}
			return @words.first  if (args.empty?)
			## Return next word after position pos
			if (args[:pos])
				## Check for additional options, like priority of word type
				case args[:priority]
				## Prioritze special words (all words except Words::Word)
				when :special
					(@words.size - args[:pos] - 1).times do |n|
						word = word_at args[:pos] + n + 1
						return word  if (word.is_not? :word)
					end
					return next_word pos: args[:pos]

				## Prioritze Words::Word
				when :word
					(@words.size - args[:pos] - 1).times do |n|
						word = word_at args[:pos] + n
					end

				## No priority
				when nil
					return word_at args[:pos] + 1

				## Prioritze specific special word
				else
					(@words.size - args[:pos] - 1).times do |n|
						word = word_at args[:pos] + n
						return word  if (word.is? args[:priority])
					end
					return next_word pos: args[:pos]
				end

			else
				return nil
			end
		end

	end
end

