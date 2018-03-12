
module ConversationKeywords
	## Load all ConversationKeyword data files and return them
	def self.load_data
		return self.constants.map do |constname|
			constant = self.const_get constname
			next nil                unless (constant.is_a? Class)
			data = read_data(File.join(DIR[:data][:conversation_keywords], "#{constname.to_s}.yml"))
			next [constname, data]  unless (data.nil?)
			log "WARNING: ConversationKeyword '#{constname.to_s}' has no data file!"
			next nil
		end .reject { |x| !x } .to_h
	end

	## Return data for Instance class
	def self.data clazz
		return nil                                                             if (!clazz.is_a?(Class) || clazz.is_not?(:person))
		classname = clazz.name.sub('Instances::Persons::','')
		key_parent, key_child = classname.split('::')[1 .. -1].map(&:to_sym)
		## Return nil if Instance type / Instance data group (ex.: Items, Persons) doesn't exist
		return nil                                                             unless (DATA.keys.include? key_parent)
		## Return default data of Instance type (ex.: Item.yml, Person.yml)
		unless (DATA[key_parent].keys.include? key_child)
			ret = DATA[key_parent][key_parent.to_s.match(/\A(.+)s\z/)[1].to_sym].dup
			ret[:keywords] = [key_child.to_s.downcase]
			return ret
		end
		## Returned merged data of Instance type and actual class
		return DATA[key_parent][key_parent.to_s.match(/\A(.+)s\z/)[1].to_sym].merge(DATA[key_parent][key_child])
	end

	def self.read_data file
		return nil  unless (File.file? file)
		return YAML.load_file file
	end

	class ConversationKeyword
		def initialize args = {}
		end
	end
end

## Require all ConversationKeywords
require_files DIR[:conversation_keywords], except: 'ConversationKeyword'
## Load all ConversationKeyword data files
ConversationKeywords::DATA = ConversationKeywords.load_data

