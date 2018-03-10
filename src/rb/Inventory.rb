
## Inventory module
## Include with any class and initialize Inventory by calling super
## and they should have an Inventory with the methods below

module Inventory
	## Overwrite initialize method of object to set some Inventory stuff
	## Still call super though
	def initialize args = {}
		super  if (self.class.name =~ /\AInstances::.+?::.+\z/)
		## Initialize Inventory
		@inventory = Inventory.new
		## Load all Items that Room is supposed to have
		@data['items'].each do |itemstr|
			item = itemstr.to_sym
			if (Instances::Items.constants.include? item)
				@inventory.item_add Instances::Items.const_get(item).new
			else
				## Item doesn't exist, display warning
				classtype, clazz = get_instance_type_and_class
				log "WARNING: #{classtype} '#{clazz}' tried to load Item '#{itemstr}' which doesn't exist."
				next nil
			end
		end  if (@data && @data['items'])
	end

	class Inventory
		attr_reader :items
		def initialize args = {}
			@items = {}
		end

		def item_add item
			## Add Item by key of Item's classname as symbol
			@items[item.class.name.split('::').last.to_sym] = item
		end

		def has_item? item
			if    (item.is_a? Class)
				return @items.values.any? { |i| i.is_a? item }
			elsif (item.is_a?(Symbol) || item.is_a?(String))
				return @items.keys.include? item.to_sym
			end
			return false
		end
	end

	## Check if Inventory contains any Items
	def any_items?
		return @inventory.items.any?
	end

	## Return all Items from Inventory
	def items
		return @inventory.items.values
		return nil
	end

	## Add Item to Inventory
	def item_add item
		return false  unless (item.is? :item)
		return @inventory.item_add item
	end

	## Check if Inventory has Item item
	def has_item? item
		return @inventory.has_item? item
	end
end

