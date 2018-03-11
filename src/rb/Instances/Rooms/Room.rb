
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

			## Default items method
			def items; nil; end

			## This method is called everytime the Player goes to this Room
			def went!
				@known = true  unless (@known)
			end

			## Overwrite keywords method to include keywords_self
			def keywords
				return [super, @data['keywords_self'] || []].flatten
			end

			## Get keywords_neighbors; keywords for neighbors only applicable from this Room
			def keywords_neighbors target = :all
				case target
				when :all
					return @data['keywords_neighbors']
				else
					return nil  unless (@data['keywords_neighbors'].keys.include? target)
					return @data['keywords_neighbors'][target]
				end
			end

			## Custom keyword? method, add keywords_neighbors to keywords
			def keyword? string
				kw_neighbors = PLAYER.current_room.keywords_neighbors(get_instance_type_and_class[1])
				return super || ( kw_neighbors ? kw_neighbors.any? do |kw|
					string =~ kw.to_regex
				end : false )
			end

			## Save neighbors as hash in instance variables
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

			## Check if Player can go to Room from this Room
			def can_goto? room
				if    (room.is_a?(Symbol) || room.is_a?(String))
					return true  if (@neighbors.keys.include? room.to_sym)
				elsif (room.is_a? Class)
					return true  if (@neighbors.values.any? { |n| n.is_a? room })
				elsif (room.is_a? Instances::Rooms::Room)
					return true  if (@neighbors.values.include? room)
				end
				return false
			end

		end  # END - CLASS
	end  # END - MODULE
end

