
module Instances
	module Rooms
		## ROOMS constant in which all loaded Rooms will be stored
		ROOMS = {}

		## Initialize / load all rooms and return them
		def self.init_rooms
			return self.constants.map do |constname|
				room = self.init_room(constname)
				next [constname, room]  unless (room.nil?)
				next nil
			end .reject { |x| !x } .to_h
		end

		## Initialize a single Room by their classname
		def self.init_room classname
			return nil  if     ([:Room, :ROOMS].include? classname)
			return nil  unless (self.constants.include?(classname))
			clazz = self.const_get(classname)
			return nil  unless (clazz.is_a? Class)
			return clazz.new
		end

		class Room < Instances::Instance
			include Saves::Savable
			include Saves::Methods::Room

			def initialize args = {}
				super
				@persons    = load_persons
				@components = load_components
				@events     = load_events
			end

			## Load and create Persons
			def load_persons
				if (@data['persons'])
					return @data['persons'].map do |personstr|
						personname = personstr.to_sym
						person = load_person personname
						next [personname, person]  if (person)
						next nil
					end .reject { |x| !x } .to_h
				else
					return {}
				end
			end

			def load_person personname
				personname = personname.to_sym
				if (Instances::Persons.constants.include? personname)
					return Instances::Persons.const_get(personname).new
				else
					## Person doesn't exist, display warning
					instance_type = get_instance_type_classname
					classname     = get_classname
					log "WARNING: #{instance_type} '#{classname}' tried to load Person '#{personname.to_s}' which doesn't exist."
					return nil
				end
			end

			## Load and create Components
			def load_components
				if (@data['components'])
					return @data['components'].map do |componentstr|
						componentname = componentstr.to_sym
						component = load_component(componentname)
						next [componentname, component]  if (component)
						next nil
					end .reject { |x| !x } .to_h
				else
					return {}
				end
			end

			def load_component componentname
				componentname = componentname.to_sym
				if (Instances::Components.constants.include? componentname)
					return Instances::Components.const_get(componentname).new
				else
					## Component doesn't exist, display warning
					instance_type = get_instance_type_classname
					classname     = get_classname
					log "WARNING: #{instance_type} '#{classname}' tried to load Component '#{componentname.to_s}' which doesn't exist."
					return nil
				end
			end

			## Load and create Events
			def load_events
				if (@data['events'])
					return @data['events'].map do |eventstr, eventdata|
						eventname = eventstr.to_sym
						event = load_event eventname, eventdata
						next [eventname, event]  if (event)
						next nil
					end .reject { |x| !x } .to_h
				else
					return {}
				end
			end

			def load_event eventname, eventdata
				eventname = eventname.to_sym
				if (Events.constants.include? eventname)
					return Events.const_get(eventname).new(eventdata)
				else
					## Event doesn't exist, display warning
					instance_type = get_instance_type_classname
					classname     = get_classname
					log "WARNING: #{instance_type} '#{classname}' tried to load Event '#{eventname}' which doesn't exist."
					return nil
				end
			end

			## Default items method (fallback)
			def items
				nil
			end

			## Return all Persons in Room
			def persons
				return @persons.values     unless (@persons.nil?)
				return []
			end

			## Return all Components in Room
			def components
				return @components.values  unless (@components.nil?)
				return []
			end

			## Return all Room Events
			def events
				return @events.values      unless (@events.nil?)
				return []
			end

			## Overwrite keywords method to include keywords_self and custom keywords only available from current Room, example:
			#  from inside Room ParsleysTruck: $ go outside
			#  outside refers to Cornfield, but only from within ParsleysTruck
			def keywords
				return [
					super,
					@data['keywords_self'],
					PLAYER.current_room.keywords_neighbors(get_classname)
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
				dbg.call  unless @neighbors
				return @neighbors.values
			end

			#TODO:
			## Method not used anymore, cleanup!
			## Save neighbors as hash in instance variables
			def set_neighbors
				## Get all neighbors
				@neighbors = @data['neighbors'].map do |roomstr|
					roomname = roomstr.to_sym
					if (room = Instances::Rooms::ROOMS[roomname])
						next [roomname, room]
					else
						## Room doesn't exist, log warning
						classname = get_classname
						log "WARNING: Room '#{classname}' tried to set Room '#{roomname}' as neighbor which doesn't exist!"
						next nil
					end
				end .reject { |x| !x } .to_h
			end

			## Load / create neighboring Rooms
			def load_neighbors
				return @neighbors  unless (@neighbors.nil?)
				@neighbors = @data['neighbors'].map do |roomstr|
					roomname = roomstr.to_sym
					## Don't create new Room but get already created Room from constant
					next [roomname, Instances::Rooms::ROOMS[roomname]]  if (Instances::Rooms::ROOMS.keys.include?(roomname))
					## Create new Room
					if (room = Instances::Rooms.init_room(roomname))
						Instances::Rooms::ROOMS[roomname] = room
						next [roomname, room]
					else
						## Room doesn't exist, log warning
						classname = get_classname
						log "WARNING: Room '#{classname}' tried to set Room '#{roomname}' as neighbor which doesn't exist!"
						next nil
					end
				end .reject { |x| !x } .to_h
				return @neighbors
			end

			## This method is called everytime the Player goes to this Room
			def went!
				## Load all neighboring Rooms when going to the Room the first time
				load_neighbors
				known!  if (unknown?)
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

