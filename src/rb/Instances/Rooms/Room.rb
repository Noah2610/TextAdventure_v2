
module Instances
	module Rooms
		## Initialize / load all rooms and return them
		def self.init_rooms
			return self.constants.map do |constname|
				next nil  if     (constname == :Room)
				clazz = self.const_get(constname)
				next nil  unless (clazz.is_a? Class)
				next [constname, clazz.new]
			end .reject { |x| !x } .to_h
		end

		class Room < Instances::Instance
			def initialize args = {}
				super
			end

			# Default items method
			def items; nil; end

			def set_neighbors
				## Get all neighbors
				@neighbors = @data['neighbors'].map do |roomname|
					if (room = Instances::Rooms::ROOMS[roomname.to_sym])
						next [roomname.to_sym, room]
					else
						## Room doesn't exist, log warning
						classtype, clazz = get_instance_type_and_class
						log "WARNING: Room '#{clazz}'"
					end
				end .reject { |x| !x } .to_h
			end

			

			## Get all adjacent Rooms (neighbors)
			def get_neighbors
				return @neighbors.values
			end
		end
	end
end

