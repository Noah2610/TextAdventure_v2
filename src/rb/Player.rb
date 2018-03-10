
## The Player is supposed to have an Inventory
## and keep track of where the user is and what they can do
## Get available Instances, ...

class Player
	include Inventory

	def initialize args = {}
		## Init Inventory
		super

		#TODO:
		## Read savefile content

		## Current Room
		@room = Instances::Rooms::ROOMS[:ParsleysTruck]
	end

	## Return current Room
	def current_room
		return @room
	end

	## Add Item to Inventory; super actually adds it
	def item_add item
		ret = super
		item.known!  if (ret)
		return ret
	end

	## Goto other Room; Check if that's possible first
	def goto room
		return false  unless (current_room.can_goto? room)
		if    (room.is_a?(Symbol) || room.is_a?(String))
			@room = Instances::Rooms::ROOMS[room.to_sym]
		elsif (room.is_a? Class)
			@room = Instances::Rooms::ROOMS.values.map { |r| r  if (r.is_a? room) } .reject { |x| !x } .first
		elsif (room.is_a? Instances::Rooms::Room)
			@room = room
		end
		@room.went!  unless (@room.nil?)
		return @room
	end

	## Return all currently available Instances. These include:
	# ITEMS:
	#  inventory Items, Items in Room, Items in Person's inventory in Room
	# PERSONS:
	#  Persons in Room
	# ROOMS:
	#  current Room, adjacent Rooms (neighbors)
	def available_instances
		ret = {}
		## Items
		ret[:items] = [items, current_room.items].flatten
		## Rooms
		ret[:rooms] = [current_room, current_room.get_neighbors].flatten
		## Persons
		ret[:persons] = []
		return ret
	end
end

