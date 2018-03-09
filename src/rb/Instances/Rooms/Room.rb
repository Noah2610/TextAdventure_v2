
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
				## Load all Items that Room is supposed to have
				@data['items'].each do |item|
					if (Instances::Items.constants.include? item)
					else
						## Item doesn't exist, display warning
						log "WARNING: Room '#{Windows::Color.process_attribute_codes(name)[0]}' tried to load Item '#{item.to_s}' which doesn't exist"
					end
				end
			end

			## Get all Items inside Room
			def items
				return @data['items']
			end

			## Check if Room has Item item inside
			def has_item? item
			end
		end
	end
end

