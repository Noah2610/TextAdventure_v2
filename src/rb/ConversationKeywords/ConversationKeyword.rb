
module ConversationKeywords
	## Load all ConversationKeyword data files and return them
	def self.load_data
		return self.constants.map do |constname|
			constant = self.const_get constname
			next nil                unless (constant.is_a? Class)
			data = read_data(File.join(DIR[:data][:conversation_keywords], "#{constname.to_s}.yml"))
			next [constname.to_s, data]  unless (data.nil?)
			log "WARNING: ConversationKeyword '#{constname.to_s}' has no data file!"
			next nil
		end .reject { |x| !x } .to_h
	end

	## Return data for Instance class
	def self.get_for targets
		targets = [targets].flatten
		return targets.map do |target|
			## Check if target ConversationKeyword exists
			if (DATA[target] && const = self.constants.map { |c| self.const_get c } .map { |c| c  if (c.is_a?(Class) && c.name.sub('ConversationKeywords::','') == target) } .reject { |x| !x } .first)
				next [target, const.new(DATA[target])]
			else
				log "WARNING: ConversationKeyword #{target} doesn't exist!"
				next nil
			end
		end .reject { |x| !x } .to_h
	end

	def self.read_data file
		return nil  unless (File.file? file)
		return YAML.load_file file
	end

	class ConversationKeyword
		def initialize data, args = {}
			@data = data
			@person = nil
		end

		## Assign person
		def person= person
			@person = person
		end

		## Do whatever logic Keyword is supposed to do and return text
		def action
			return text
		end

		## Return default keyword text and perform substitution if instances given
		def text *words
			words = [words, PLAYER].flatten
			txt = nil
			if    (@person.nil?)
				## No Person set
				txt = [@data['text']].flatten.sample
			elsif (@person.is? :person)
				## Has Person
				txt = [@person.conversation_text].flatten.sample
				txt = [@data['text']].flatten.sample  if (txt.nil?)
			end
			return nil                              if (txt.nil?)
			return Input.substitute txt, words  unless  (words.empty?)
			return txt
		end

		## Return keywords
		def keywords
			return @data['keywords']
		end

		## Return keyphrases
		def keyphrases
			return @data['keyphrases']
		end

		## Check if string matches a keyword
		def keyword? string
			return [keyphrases, keywords].reject { |x| !x } .flatten.any? do |kw|
				string =~ kw.to_regex(word: true)
			end
		end
	end
end

## Require all ConversationKeywords
require_files DIR[:conversation_keywords], except: 'ConversationKeyword'
## Load all ConversationKeyword data files
ConversationKeywords::DATA = ConversationKeywords.load_data

