module Saves::Methods
	module Player
		## Data to save
		def to_save
			return {
				current_room: @current_room.get_classname,
				Inventory:    @inventory.to_save
			}
		end

		## Data to load
		def load_data content
			# current_room
			load_data_current_room content['current_room']
			# Inventory - Items
			load_data_inventory content['inventory']
		end

		def load_data_current_room roomname
			room = load_data_get_room roomname
			goto! room
		end

		def load_data_get_room roomname
			roomname = roomname.to_sym
			room = nil
			if    (Instances::Rooms::ROOMS.keys.include? roomname)
				room = Instances::Rooms::ROOMS[roomname]
			elsif (Instances::Rooms.constants.include? roomname)
				room = Instances::Rooms.const_get(roomname).new
			else
				log "WARNING: Player tried loading Room '#{roomname}' from savefile, which doesn't exist!"
			end
			return room
		end

		def load_data_inventory inventory_content
			@inventory.load_data inventory_content
		end
	end # END - MODULE Player
end # END - MODULE Saves::Methods
