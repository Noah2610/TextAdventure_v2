
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
				input.scan(/\b\S+\b/) do |w|
					@words << Words.new_word(w, self, pos: counter)
					counter += 1
				end

			when :conversation
				## Conversation mode
				return nil  unless (kws = PLAYER.conversation_keywords)
				## Instance Words
				counter = input.index /\b/
				words_words = []
				input.scan(/\b\S+\b/) do |w|
					counter = input.index(w, counter) + w.size + 1
					break  if (counter > input.size)
					words_words << Words.new_word(w, self, no_verbs: true, pos: counter)
				end
				## Conversation Words
				words_conversation = kws.map do |kw|
					if (positions = kw.keyword? input)
						next positions.map do |pos|
							next Words::Conversation.new self, keyword: kw, pos: pos
						end
					end
				end .flatten .reject { |x| !x }
				## Remove Words that are Conversation Words
				words_words.reject! do |ww|
					words_conversation.any? do |wc|
						next wc.position == ww.position
					end
				end
				## Concat Conversation Words and Words
				@words = words_conversation.concat words_words
				## Sort @words and set proper positions
				@words.sort! do |w1,w2|
					w1.position - w2.position
				end
				@words.each_with_index do |w, i|
					w.position = i
				end
				#log @words.map { |w| [w.class.name, w.position] }

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

