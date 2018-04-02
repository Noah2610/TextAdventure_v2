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
		def restore_savefile content
			# current_room
			restore_current_room content['current_room']
			# Inventory - Items
			restore_inventory content['Inventory']
		end

		def restore_current_room roomname
			room = restore_get_room roomname
			goto! room
		end

		def restore_get_room roomname
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

		def restore_inventory inventory_content
			@inventory.restore_savefile inventory_content
		end
	end # END - MODULE Player
end # END - MODULE Saves::Methods
