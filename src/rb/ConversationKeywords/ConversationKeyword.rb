
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
			if (DATA[target] && self.constants.map { |c| self.const_get c } .any? { |c| c.is_a?(Class) && c.name.sub('ConversationKeywords::','') == target })
				next [target, ConversationKeyword.new(DATA[target])]
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
		end

		## Return default keyword text
		def text
			return @data['text']
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

