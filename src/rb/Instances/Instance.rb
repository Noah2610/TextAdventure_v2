
## Instances are:
# Items
# Persons
# Rooms

module Instances
	### Module Methods
	## Read all Instance data files and return them
	## Group by Instance type and classnames
	def self.load_data
		return ( [:Items, :Persons, :Rooms].map do |type|
			next [type, ( self.const_get(type).constants.map do |classname|
				data = read_data(File.join(DIR[:data][type.downcase], "#{classname.to_s}.yml"))
				next [classname, data]  unless (data.nil?)
				log "WARNING: #{type.match(/(\A.+)s\z/)[1]} '#{classname.to_s}' has no data file!"
				next nil
			end .reject { |x| !x } .to_h ) ]
		end .to_h )
	end

	def self.read_data file
		return nil  unless (File.file? file)
		return YAML.load_file file
	end

	## Return data for Instance class
	def self.data clazz
		classname = clazz.name.sub('Instances::','')                           if (clazz.is_a? Class)
		key_parent, key_child = classname.split('::').map &:to_sym
		## Return nil if Instance type / Instance data group (ex.: Items, Persons) doesn't exist
		return nil                                                             unless (DATA.keys.include? key_parent)
		## Return default data of Instance type (ex.: Item.yml, Person.yml)
		unless (DATA[key_parent].keys.include? key_child)
			ret = DATA[key_parent][key_parent.to_s.match(/(\A.+)s\z/)[1].to_sym].dup
			ret[:keywords] = [key_child.to_s.downcase]
			return ret
		end
		## Returned merged data of Instance type and actual class
		return DATA[key_parent][key_parent.to_s.match(/(\A.+)s\z/)[1].to_sym].merge(DATA[key_parent][key_child])
	end


	### Instance Class
	class Instance
		attr_reader :data

		def initialize args = {}
			@data = Instances.data self.class
		end

		## Check if Instance class is Instance type target_type and optionally is class target_class
		def self.is? target_type, target_class = nil
			target_type = target_type.downcase.to_sym
			target_class = target_class.downcase.to_sym  if (target_class)
			type, clazz = self.name.sub('Instances::','').split('::')
			type = type.match(/(\A.+)s\z/)[1].downcase.to_sym
			clazz = clazz.downcase.to_sym
			return (type == target_type)                 unless (target_class)
			return (type == target_type && clazz == target_class)
		end
		def is? target_type, target_class = nil
			self.class.is? target_type, target_class
		end

		## Name of Instance
		def name
			return @data['name']
		end

		## Description of Instance
		def description
			return @data['description']
		end

		## Keywords of Instance
		def keywords
			return @data['keywords']
		end

		## Check if string matches a keyword
		def keyword? string
			return @data['keywords'].any? do |kw|
				string =~ kw.to_regex(case_insensitive: true)
			end
		end
	end
end

## Require Items
require File.join DIR[:items], 'Item'
require_files File.join(DIR[:items]), except: 'Item'

## Require Persons
require File.join DIR[:persons], 'Person'
require_files File.join(DIR[:persons]), except: 'Person'

## Require Rooms
require File.join DIR[:rooms], 'Room'
require_files File.join(DIR[:rooms]), except: 'Room'

module Instances
	## Load all instance data files
	DATA = self.load_data

	#TODO:
	## Load Rooms specified in Player savefile
	#TODO:
	## Load Rooms dynamically; Current Room loads adjacent Rooms but not further
	## Load all Rooms for now
	Rooms::ROOMS = Rooms.init_rooms
end

