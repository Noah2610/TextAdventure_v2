
## Inventory module
## Include with any class and initialize Inventory by calling super
## and they should have an Inventory with the methods below

module Inventory
	## Overwrite initialize method of object to set some Inventory stuff
	## Still call super though
	def initialize args = {}
		super  # if (self.class.name =~ /\AInstances::.+?::.+\z/)
		## Initialize Inventory
		@inventory = Inventory.new
		## Load and create all Items that Room is supposed to have
		load_items_from_data  if (@data && @data['items'])
	end

	def load_items_from_data
		@data['items'].each do |itemstr|
			item = itemstr.to_sym
			if (Instances::Items.constants.include? item)
				@inventory.item_add Instances::Items.const_get(item).new(belongs_to: self)
			else
				## Item doesn't exist, display warning
				log_warning_item_doesnt_exist itemstr
			end
		end
	end

	def log_warning_item_doesnt_exist itemname
		instance_type = get_instance_type_classname
		classname     = get_classname
		log "WARNING: #{instance_type} '#{classname}' tried to load Item '#{itemname}' which doesn't exist."
	end

	def has_inventory?
		return true
	end

	### INVENTORY CLASS
	class Inventory
		attr_reader :can_take
		include Saves::Methods::Inventory

		def initialize args = {}
			@items = {}
			@can_take = []
		end

		## Return items
		def items
			return @items.values
		end

		## Add Item from Inventory
		def item_add item
			## Add Item by key of Item's classname as symbol
			item.belongs_to = self
			return (@items[item.class.name.split('::').last.to_sym] = item)
		end

		## Remove Item from Inventory
		def item_remove item
			return false  unless (has_item? item)
			return @items.delete item.class.name.split('::').last.to_sym
		end

		## Remove ALL Items from Inventory
		def items_clear
			return @items.clear
		end

		def has_item? item
			if    (item.is_a? Instances::Items::Item)
				return items.any? { |i| i.is_a? item.class }
			elsif (item.is_a? Class)
				return items.any? { |i| i.is_a? item }
			elsif (item.is_a?(Symbol) || item.is_a?(String))
				return @items.keys.include? item.to_sym
			end
			return false
		end

		def can_take= itemnames
			itemnames = itemnames.map do |itemname|
				next itemname.to_sym
			end
			@can_take.concat itemnames
		end

		def can_take? item
			return @can_take.include? item.get_classname.to_sym
		end

		def clear_can_take
			@can_take.clear
		end
	end # END - CLASS


	## Check if Inventory contains any Items
	def any_items?
		return @inventory.items.any?
	end

	## Return all Items from Inventory
	def items
		return @inventory.items
		return nil
	end

	## Add Item to Inventory
	def item_add item
		return false  unless (item.is? :item)
		return @inventory.item_add item
	end

	## Remove Item from Inventory
	def item_remove item
		return false  unless (item.is? :item)
		return @inventory.item_remove item
	end

	## Remove ALL Items from Inventory
	def items_clear
		return @inventory.items_clear
	end

	## Check if Inventory has Item item
	def has_item? item
		return @inventory.has_item? item
	end

	## Can give Item?
	def give? item, person = nil
		return true  if (person.nil?)
		return true && (person.has_inventory? && person.take?)
	end

	## Can take Item?
	def take? item
		if (is?(:player) || (defined?(can_take?) && can_take?(item)))
			return true
		end
		return false
	end

	## Set can_take items as Symbols
	def can_take= items
		@inventory.can_take = [items].flatten
	end

	def can_take? item
		return @inventory.can_take? item
	end

	## Give Item to Person
	def give item, person
		if (has_item?(item) && give?(item))
			if (person.take? item)
				person.take item
				return true
			end
		end
		return false
	end

	def take item
		item.owner.item_remove item  if (item.owner)
		item_add item
	end
end # END - MODULE

