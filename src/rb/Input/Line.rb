
## Input::Line is created upon every new user input.
## It contains Input::Words::* for all words in the Line.
## The Input::Words::Verb should then handle the line apropriately (maybe)

module Input
	## Perform substitution on text to replace occurences like '{ITEM}' with proper Word containing Instance, if given.
	def self.substitute text, *words
		words = [words].flatten
		text_new = text.dup
		words.each do |word|
			break  unless (text_new =~ /\[[A-Z]+\]/)
			text = text_new.dup
			text.scan /\[([A-z]+)\]/ do |matches|
				match = matches.first
				# Check if match is PLAYER
				if    (word.is?(match) && word.is?(:player))
					text_new.sub! /\[#{Regexp.quote match}\]/, PLAYER.name
					break
				elsif (word.is?(match) || match.upcase.to_sym == :WORD)
					if (instance = word.instance)
						text_new.sub! /\[#{Regexp.quote match}\]/, instance.name
						break
					else
						text_new.sub! /\[#{Regexp.quote match}\]/, word.text
						break
					end
				end
			end
		end
		return text_new
	end


	class Line
		def initialize input, args = {}
			@input_text = input
			@words = []
			case PLAYER.mode
			when :normal
				## Normal mode
				counter = 0
				input.scan(/[^ .,:;!"'$%&\/()=?+*#\-_<>|]+/) do |w|
					@words << Words.new_word(w, self, { pos: counter })
					counter += 1
				end

			when :conversation
				## Conversation mode
				return nil  unless (kws = PLAYER.conversation_keywords)
				@words = kws.map do |kw|
					if (kw.keyword? input)
						next Words::Conversation.new self, keyword: kw
					end
				end .reject { |x| !x }
				log @words.map { |w| w.keyword.class.name }

			end
		end

		## Do whatever the line is supposed to do, according to Player mode
		#   :normal       - Call action on Verbs
		#   :conversation - ???
		def process
			case PLAYER.mode
			when :normal
				## Process for normal mode
				return verbs.map do |verb|
					next verb.action
				end .reject { |x| !x }

			when :conversation
				## Process for conversation mode
				person = PLAYER.conversation_person
				return nil  if (person.nil?)
				return conversation_words.map do |x|
					next x.action
				end .reject { |x| !x }
			end
		end

		## Return all Verbs in @words
		def verbs
			return @words.map do |word|
				next word  if (word.is? :verb)
			end .reject { |x| !x }
		end

		## Return all conversational Words in @words
		def conversation_words
			return @words.map do |word|
				next word  if (word.is? :conversation)
			end .reject { |x| !x }
		end

		def text
			return @words.map { |w| w.text } .join ' '  unless (@words.empty? || @words.any? { |w| w.text.nil? })
			return @input_text
		end

		## Return word in line at position pos
		def word_at pos
			return @words[pos]
		end

		#TODO: Refactor this method
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
						next         if (args[:ignore] && !!(args[:ignore].any? { |i| word.text =~ i.to_regex }))
						return word  if (word.is_not? :word)
					end
					return next_word pos: args[:pos], ignore: args[:ignore]

					## Prioritze Words::Word
				when :word
					(@words.size - args[:pos] - 1).times do |n|
						word = word_at args[:pos] + n + 1
						next         if (args[:ignore] && !!(args[:ignore].any? { |i| word.text =~ i.to_regex }))
						return word  if (word.is? :word)
					end
					return next_word pos: args[:pos], ignore: args[:ignore]

					## No priority
				when nil
					(@words.size - args[:pos] - 1).times do |n|
						word = word_at args[:pos] + n + 1
						next         if (args[:ignore] && !!(args[:ignore].any? { |i| word.text =~ i.to_regex }))
						return word
					end
					return nil

					## Prioritze specific special word
				else
					(@words.size - args[:pos] - 1).times do |n|
						word = word_at args[:pos] + n
						next         if (args[:ignore] && !!(args[:ignore].any? { |i| word.text =~ i.to_regex }))
						return word  if (word.is? args[:priority])
					end
					return next_word pos: args[:pos], ignore: args[:ignore]
				end

			else
				return nil
			end
		end

		## Call next_word multiple times until it reaches the end of Line
		def next_words args = {}
			return nil  if (args.empty?)
			pos = args[:pos]
			ret = []
			new_args = args
			while (pos < @words.size)
				new_args[:pos] = pos
				next_w = next_word new_args
				break  if (next_w.nil?)
				ret << next_w
				pos = next_w.position
			end
			return ret
		end

	end
end

