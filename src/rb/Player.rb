
## The Player is supposed to have an Inventory
## and keep track of where the user is and what they can do
## Get available Instances, ...

module Player
	class Player
		def initialize
			#TODO:
			## Read savefile content

			## Inventory
			@inventory = Inventory.new
			## Current Room
			@room = Instances::Rooms::ROOMS[:ParsleysTruck]
		end

		## Return all Items from Inventory
		def items
			return @inventory.items
		end

		## Add Item to Inventory
		def item_add item
			return false  unless (item.is? :item)
			return @inventory.item_add item
		end

		## Return current Room
		def current_room
			return @room
		end
	end

	class Inventory
		attr_reader :items
		def initialize
			@items = []
		end

		def item_add item
			return false  unless (item.can_add_to_inventory?)
			@items << item
			return true
		end
	end
end

