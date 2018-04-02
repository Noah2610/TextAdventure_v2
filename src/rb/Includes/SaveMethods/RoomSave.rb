module Saves::Methods
	module Room
		## Room data to save; includes Instances inside Room, such as Persons and Items
		def to_save
			return super.merge get_content_to_save
		end

		def get_content_to_save
			content = {
				Persons:    get_content_to_save_from_persons,
				Components: get_content_to_save_from_components,
				Events:     get_content_to_save_from_events
			}
			return content
		end

		def get_content_to_save_from_persons
			return persons.map do |person|
				next person.to_save
			end
		end

		def get_content_to_save_from_components
			return components.map do |component|
				next component.to_save
			end
		end

		def get_content_to_save_from_events
			return events.map do |event|
				next event.to_save
			end
		end

		## Load data
		def load_data content
		end
	end
end # END - MODULE Saves::Methods
