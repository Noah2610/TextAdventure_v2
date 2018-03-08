
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
				'keywords' => self.class.to_s.downcase
			}  unless (File.file? filepath)
			return YAML.load_file filepath
		end

		## Return array of valid keywords for this Verb
		def keywords
			return @data['keywords']
		end

		## Do what the verb is supposed to do
		def action
		end
	end
end

