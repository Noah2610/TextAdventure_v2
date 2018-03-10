
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

