
## Verbs::* are supposed to handle the user input.

module Verbs
	## Create all verbs and return array of them
	def self.init_verbs
		return (self.constants.map do |clazz|
			next nil  if (clazz == :Verb)
			next [clazz, self.const_get(clazz).new]
		end .reject { |x| !x }) .to_h
	end

	class Verb
		include Keywords
		def initialize args = {}
			## Read data (text) from file
			unless (ENVT.test?)
				@data = read_data
			else
				@data = read_data DIR[:test][:data][:verbs]
			end
		end

		## Read extra data from yaml file
		def read_data dir = DIR[:data][:verbs]
			filepath = File.join dir, "#{self.class.name.sub('Verbs::','')}.yml"
			return {
				'keywords' => [self.class.to_s.downcase]
			}  unless (File.file? filepath)
			return YAML.load_file filepath
		end

		## Return array of valid keywords for this Verb
		def keywords
			return @data['keywords']
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

