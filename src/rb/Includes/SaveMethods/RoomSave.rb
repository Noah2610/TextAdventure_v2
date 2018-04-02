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
		def restore_savefile content
			# super takes care of known, Inventory, Openable
			super
			restore_persons    content['Persons']     if (content['Persons'])
			restore_components content['Components']  if (content['Components'])
			restore_events     content['Events']      if (content['Events'])
		end

		def restore_persons person_contents
			@persons = {}
			person_contents.each do |person_content|
				restore_person person_content
			end
		end

		def restore_person content
			personname = content['classname'].to_sym
			person     = load_person personname
			if (person)
				person.restore_savefile content
				@persons[personname] = person
			end
		end

		def restore_components component_contents
			@components = {}
			component_contents.each do |component_content|
				restore_component component_content
			end
		end

		def restore_component content
			componentname = content['classname'].to_sym
			component     = load_component componentname
			if (component)
				component.restore_savefile content
				@components[componentname] = component
			end
		end

		def restore_events event_contents
			@events = {}
			event_contents.each do |event_content|
				restore_event event_content
			end
		end

		def restore_event content
			eventname = content['classname'].to_sym
			event     = load_event eventname, @data['events'][eventname.to_s]
			if (event)
				event.restore_savefile content
				@events[eventname] = event
			end
		end

	end # END - MODULE Room
end # END - MODULE Saves::Methods
