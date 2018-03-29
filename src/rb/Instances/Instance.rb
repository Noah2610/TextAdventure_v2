
## Instances are:
#   Items
#   Persons
#   Rooms
#   Components

module Instances
	### Module Methods
	## Read all Instance data files and return them
	## Group by Instance type and classnames
	def self.load_data dir = DIR[:data]
		return ( [:Items, :Components, :Persons, :Rooms].map do |instance_type|
			instance = self.const_get(instance_type)
			next [
				instance_type,
				instance.constants.map do |classname|
					next nil  unless (instance.const_get(classname).is_a? Class)
					filepath = File.join dir[instance_type.downcase], "#{classname.to_s}.yml"
					data = read_yaml filepath
					next [classname, data]  unless (data.nil?)
					log "WARNING: #{instance_type.match(/\A(.+)s\z/)[1]} '#{classname.to_s}' has no data file!"
					next nil
				end .reject { |x| !x } .to_h
			]
		end .to_h )
	end

	## Return data for Instance class
	def self.data clazz
		classname = clazz.name.sub('Instances::','')                           if (clazz.is_a? Class)
		key_parent, key_child = classname.split('::').map &:to_sym
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


	### Instance Class
	class Instance
		include Keywords
		def initialize args = {}
			@data = Instances.data self.class
			@known = @data['known']
		end

		## Check if Instance class is Instance type target_type and optionally is class target_class
		def self.is? target_type, target_class = nil
			target_type  = target_type.downcase.to_sym
			target_class = target_class.downcase.to_sym  if (target_class)
			type, clazz  = self.name.sub('Instances::','').split('::')
			type         = type.match(/\A(.+)s\z/)[1].downcase.to_sym
			clazz        = clazz.downcase.to_sym
			return (type == target_type)                 unless (target_class)
			return (type == target_type && clazz == target_class)
		end
		def self.is_not? target_type, target_class = nil
			target_type  = target_type.downcase.to_sym
			target_class = target_class.downcase.to_sym  if (target_class)
			type, clazz  = self.name.sub('Instances::','').split('::')
			type         = type.match(/\A(.+)s\z/)[1].downcase.to_sym
			clazz        = clazz.downcase.to_sym
			return (type != target_type)                 unless (target_class)
			return (type != target_type && clazz != target_class)
		end
		def is? target_type, target_class = nil
			self.class.is? target_type, target_class
		end
		def is_not? target_type, target_class = nil
			self.class.is_not? target_type, target_class
		end

		## Return Instance type's classname
		def get_instance_type_classname
			return self.class.name.match(/\AInstances::(.+?)s::.+\z/).to_a[1]
		end

		## Return Instance's classname
		def get_classname
			return self.class.name.match(/\AInstances::.+?s::(.+)\z/).to_a[1]
		end

		## Check if Instance is known or unknown
		def known?
			return !!@known
		end
		def unknown?
			return !@known
		end

		## Mark Instance as known or unknown
		def known!
			return @known = true
		end
		def unknown!
			return @known = false
		end

		## Name of Instance
		def name
			return [@data['name']].flatten.sample                 if (known?)
			return [@data['name_unknown']].flatten.sample         if (unknown?)
		end

		## Description of Instance
		def description
			return [@data['description']].flatten.sample          if (known?)
			return [@data['description_unknown']].flatten.sample  if (unknown?)
		end

		## Keywords of Instance
		def keywords
			return @data['keywords']                              if (known?)
			return @data['keywords_unknown']                      if (unknown?)
		end

		## Return text(s) defined in config and perform substitution if instances given
		def text target, *words
			words = [words].flatten
			txt = [@data['text'][target]].flatten.sample
			return nil                          if     (txt.nil?)
			return Input.substitute txt, words  unless (words.empty?)
			return txt
		end

		## Check if Instance has an Inventory (fallback methods, will be overwritten when necessary)
		def has_inventory?
			return false
		end

		## Check if Instance can be opened and closed (fallback methods, will be overwritten when necessary)
		def can_open?
			return false
		end
		def can_close?
			return false
		end

	end # END - CLASS
end # END - MODULE

## Require Items
require File.join DIR[:items], 'Item'
require_files DIR[:items], except: 'Item'

## Require Components
require File.join DIR[:components], 'Component'
require_files DIR[:components], except: 'Component'

## Require Persons
require File.join DIR[:persons], 'Person'
require_files DIR[:persons], except: 'Person'

## Require Rooms
require File.join DIR[:rooms], 'Room'
require_files DIR[:rooms], except: 'Room'

module Instances
	## Load all Instance data files
	unless (ENVT.test?)
		DATA = self.load_data
	else
		DATA = self.load_data DIR[:test][:data]
	end

	# CLEANUP
	#TODO:
	## Load Rooms specified in Player savefile
	#TODO:
	## Load Rooms dynamically; Current Room loads adjacent Rooms but not further
	## Load all Rooms for now
	#Rooms::ROOMS = Rooms.init_rooms
	#Rooms::ROOMS.values.each &:set_neighbors
end

