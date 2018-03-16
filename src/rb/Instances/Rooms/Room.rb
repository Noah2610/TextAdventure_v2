
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
				@persons = load_persons
				@components = load_components
			end

			## Load and create Persons
			def load_persons
				return @data['persons'].map do |personstr|
					person = personstr.to_sym
					if (Instances::Persons.constants.include? person)
						next [person, Instances::Persons.const_get(person).new]
					else
						## Person doesn't exist, display warning
						classtype, clazz = get_instance_type_and_class
						log "WARNING: #{classtype} '#{clazz}' tried to load Person '#{personstr}' which doesn't exist."
						next nil
					end
				end .reject { |x| !x } .to_h  if (@data['persons'])
			end

			## Load and create Components
			def load_components
				return @data['components'].map do |componentstr|
					component = componentstr.to_sym
					if (Instances::Components.constants.include? component)
						next [component, Instances::Components.const_get(component).new]
					else
						## Component doesn't exist, display warning
						classtype, clazz = get_instance_type_and_class
						log "WARNING: #{classtype} '#{clazz}' tried to load Component '#{componentstr}' which doesn't exist."
						next nil
					end
				end .reject { |x| !x } .to_h  if (@data['components'])
			end

			## Default items method
			def items
				nil
			end

			## Return all Persons in Room
			def persons
				return @persons.values     unless (@persons.nil?)
				return nil
			end

			## Return all Components in Room
			def components
				return @components.values  unless (@components.nil?)
				return nil
			end

			## Overwrite keywords method to include keywords_self and custom keywords only available from current Room, example:
			#  from inside Room ParsleysTruck: $ go outside
			#  outside refers to Cornfield, but only from within ParsleysTruck
			def keywords
				return [
					super,
					@data['keywords_self'],
					PLAYER.current_room.keywords_neighbors(get_instance_type_and_class[1])
				].flatten.reject { |x| !x }
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

			## Get all adjacent Rooms (neighbors)
			def get_neighbors
				return @neighbors.values
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

			## This method is called everytime the Player goes to this Room
			def went!
				@known = true  unless (@known)
			end

			## Check if Player can go to Room from this Room
			def can_goto? room
				if    (room.is_a? Instances::Rooms::Room)
					return true  if (@neighbors.values.include? room)
				elsif (room.is_a? Class)
					return true  if (@neighbors.values.any? { |n| n.is_a? room })
				elsif (room.is_a?(Symbol) || room.is_a?(String))
					return true  if (@neighbors.keys.include? room.to_sym)
				end
				return false
			end

		end  # END - CLASS
	end  # END - MODULE
end

