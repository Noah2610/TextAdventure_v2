
module Terms
	## Load all Term data files and return them
	def self.load_data
		return self.constants.map do |constname|
			constant = self.const_get constname
			next nil                unless (constant.is_a? Class)
			data = read_yaml(File.join(DIR[:data][:terms], "#{constname.to_s}.yml"))
			next [constname.to_s, data]  unless (data.nil?)
			log "WARNING: Term '#{constname.to_s}' has no data file!"
			next nil
		end .reject { |x| !x } .to_h
	end

	## Return data for Instance class
	def self.get_for targets
		targets = [targets].flatten
		return targets.map do |target|
			## Check if target Term exists
			if (DATA[target] && const = self.constants.map { |c| self.const_get c } .map { |c| c  if (c.is_a?(Class) && c.name.sub('Terms::','') == target) } .reject { |x| !x } .first)
				next [target, const.new(DATA[target])]
			else
				log "WARNING: Term #{target} doesn't exist!"
				next nil
			end
		end .reject { |x| !x } .to_h
	end

	class Term
		include Keywords
		def initialize data, args = {}
			@data = data
			@person = nil
		end

		## Assign person
		def person= person
			@person = person
		end

		## Do whatever logic Keyword is supposed to do and return text
		def action args = {}
			return text
		end

		## Return default keyword text and perform substitution if instances given
		def text target = :default, *words
			target = target.to_s
			words = [words, PLAYER].flatten
			txt = nil
			if    (@person.nil?)
				## No Person set
				txt = [@data['text'][target]].flatten.sample  if (@data['text'])
			elsif (@person.is? :person)
				## Has Person
				ptxt = @person.conversation_text(self.class.name.split('::')[-1])
				txt = [ptxt[target]].flatten.sample           unless (ptxt.nil?)
				txt = [@data['text'][target]].flatten.sample  if (@data['text'] && txt.nil?)
			end
			return nil                          if (txt.nil?)
			return Input.substitute txt, words  unless  (words.empty?)
			return txt
		end

		## Return words to ignore in Line
		def ignore
			return @data['ignore']
		end

		## Return keywords
		def keywords
			return @data['keywords']
		end

		## Check if string matches a keyword
=begin
		def keyword? string
			return [keywords].reject { |x| !x } .flatten.map do |kw|
				next string =~ kw.to_regex(word: true)
			end .reject { |x| !x }
		end
=end
	end
end

## Require all Terms
require_files DIR[:terms], except: 'Term'
## Load all Term data files
Terms::DATA = Terms.load_data

