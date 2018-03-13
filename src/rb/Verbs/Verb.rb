
## Verbs::* are supposed to handle the user input.

module Verbs
	## Create all verbs and return array of them
	def self.init_verbs
		return (self.constants.map do |clazz|
			next nil  if (clazz == :Verb)
			next self.const_get(clazz).new
		end .reject { |x| !x })
	end

	class Verb
		def initialize args = {}
			## Read data (text) from file
			@data = read_data
		end

		## Read extra data from yaml file
		def read_data
			filepath = File.join DIR[:data][:verbs], "#{self.class.name.sub('Verbs::','')}.yml"
			return {
				'keywords' => [self.class.to_s.downcase]
			}  unless (File.file? filepath)
			return YAML.load_file filepath
		end

		## Return array of valid keywords for this Verb
		def keywords
			return @data['keywords']
		end

		## Check if string matches a keyword
		def keyword? string
			return @data['keywords'].any? do |kw|
				string =~ kw.to_regex
			end
		end

		## Do what the verb is supposed to do
		def action args = {}
		end

		## Return text(s) defined in config and perform substitution if instances given
		def text target, *instances
			instances = [instances].flatten
			txt = [@data['text'][target]].flatten.sample
			return nil                              if (txt.nil?)
			return Input.substitute txt, instances  unless  (instances.empty?)
			return txt
		end

		## Return words to ignore in Line
		def ignore
			return @data['ignore']
		end
	end
end

