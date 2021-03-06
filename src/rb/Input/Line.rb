
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
			@words = create_words input, args
			#log @words.map { |w| [w.text, w.class.name, w.position] }
		end

		## Parse input and create proper Words::* from it
		def create_words input, args = {}
			words = []                 # Created Words, will be returned
			input_remains = input.dup  # Words::Word will be created from all remaining words (separated by word boundaries)
			positions = []             # Save all positions to check for duplicate matches
			prev_positions_size = -1   # Set to new position.size after each loop to check when to end
			input_tmp = input.dup      # Input string which's words will be removed when matched to avoid matching same word twice
			replchar = ?^              # Character to replace words as they are being matched, should be character unavailable to user

			## Loop indefinitely until no new Words are being created
			while (positions.size > prev_positions_size)
				prev_positions_size = positions.size
				case PLAYER.mode
					## NORMAL mode
				when :normal
					## EVENTS
					next  if ( PLAYER.available_events.map do |event|
						if (txt, pos = event.keyword? input_tmp)
							next true  if (positions.include? pos)  # By doing this, we don't create duplicate Words
							wargs = args.merge({
								pos:  pos,
								event: event
							})
							words << Words::Event.new(txt, self, wargs)
							input_tmp.sub! txt, (replchar * txt.size)
							input_remains.sub! txt, ''
							positions << pos
							next true
						end
					end ).any?

					## VERBS
					next  if ( PLAYER.available_verbs.map do |verb|
						if (txt, pos = verb.keyword? input_tmp)
							next true  if (positions.include? pos)
							wargs = args.merge({
								pos:  pos,
								verb: verb
							})
							words << Words::Verb.new(txt, self, wargs)
							input_tmp.sub! txt, (replchar * txt.size)
							input_remains.sub! txt, ''
							positions << pos
							next true
						end
					end ).any?

					## CONVERSATION mode
				when :conversation
					## TERMS
					next  if ( PLAYER.available_terms.map do |term|
						if (txt, pos = term.keyword? input_tmp)
							next true  if (positions.include? pos)
							wargs = args.merge({
								pos:  pos,
								term: term
							})
							words << Words::Term.new(txt, self, wargs)
							input_tmp.sub! txt, (replchar * txt.size)
							input_remains.sub! txt, ''
							positions << pos
							next true
						end
					end ).any?
				end

				## INSTANCES
				next  if ( PLAYER.available_instances.map do |type, instances|
					next (instances.map do |instance|
						if (txt, pos = instance.keyword? input_tmp)
							next true  if (positions.include? pos)
							wargs = args.merge({
								pos:      pos,
								instance: instance
							})
							words << Words.const_get(type.match(/\A(.+?)s?\z/)[1].capitalize).new(txt, self, wargs)
							input_tmp.sub! txt, (replchar * txt.size)
							input_remains.sub! txt, ''
							positions << pos
							next true
						end
					end ).any?
				end ).any?
			end # END - LOOP

			## Create Words::Word (multiple) from remaining input
			input_remains.scan /\b\S+\b/ do |w|
				wargs = args.merge({
					pos: input_tmp.index(w)
				})
				words << Words::Word.new(w, self, wargs)
				input_tmp.sub! w, (replchar * w.size)
			end

			return adjust_words words
		end # END - METHOD

		## Sort Words and set proper positions
		def adjust_words words
			return words.sort do |w1,w2|
				w1.position - w2.position
			end .each_with_index do |w, i|
				w.position = i
			end
		end

		## Do whatever the line is supposed to do, according to Player mode
		#   :normal       - Call action on Verbs
		#   :conversation - Call action on Terms
		def process
			case PLAYER.mode
			when :normal
				return process_normal
			when :conversation
				return process_conversation
			end
		end

		## Process for normal mode
		def process_normal
			return [verbs, events].flatten.sort do |w1, w2|
				next w1.position - w2.position
			end .map do |word|
				next word.action
			end .reject { |x| !x }
		end

		## Process for conversation mode
		def process_conversation
			person = PLAYER.conversation_person
			return nil  if (person.nil?)
			return terms.map do |x|
				next x.action
			end .reject { |x| !x }
		end

		## Return all Verbs in @words
		def verbs
			return @words.map do |word|
				next word  if (word.is? :verb)
			end .reject { |x| !x }
		end

		## Return all Events in @words
		def events
			return @words.map do |word|
				next word  if (word.is? :event)
			end .reject { |x| !x }
		end

		## Return all Terms in @words
		def terms
			return @words.map do |word|
				next word  if (word.is? :term)
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

		## Get next_word according to parameter args
		#   pos      : position pos + 1 to start searching for Word
		#   priority : which Word type to prioritize (:special, :word, :item, :component, :person, :room, :term)
		#   ignore   : Word texts to ignore
		#TODO: Split into smaller methods
		def next_word args = {}
			return nil  if (args.empty?)
			pos      = args[:pos]
			priority = args[:priority]
			ignore   = args[:ignore] || []
			return nil  if (pos.nil?)

			ret = nil

			@words[(pos + 1) .. -1].each do |word|
				## Skip Word if it should be ignored
				next  if (ignore.any? { |i| word.text =~ i.to_regex })
				## Break out of loop if it hits another Verb or a chain_keyword
				if (word.is?(:verb) || !!SETTINGS.chain_keyword?(word.text))
					break
				end

				case priority
					## No priority
				when nil
					ret = word
					break

					## Any special Word - No Words::Word
				when :special
					if (word.is_not? :word)
						ret = word
						break
					end

					## Any Instance Words
				when :instance
					if (word.is_not?(:word) && word.is_not?(:verb))
						ret = word
						break
					end

					## Only Words::Word
				when :word
					if (word.is? :word)
						ret = word
						break
					end

					## Specific Words::* type
				else
					if (word.is? priority)
						ret = word
						break
					end
				end # END - CASE

			end # END - LOOP

			## Call method again with different priority depending on priority if no word was found
			if (ret.nil?)
				case priority
				when nil
					return ret
				when :instance
					args[:priority] = :special
					return next_word args
				when :special
					args[:priority] = :word
					return next_word args
				when :word
					args[:priority] = nil
					return next_word args
				else
					args[:priority] = :special
					return next_word args
				end
			end

			return ret
		end # END - METHOD

		#TODO: Cleanup, deprecated
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

