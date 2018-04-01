
## Events are Room specific Keywords

module Events
	class Event
		include Keywords

		## Data to save
		def to_save
			return get_content_to_save
		end

		def get_content_to_save
			return {
				classname: self.class.name
			}
		end

		def initialize data
			@data = data
		end

		def keywords
			return @data['keywords']
		end

		## Method to be called when an Event Keyword is used
		def action args = {}
		end
	end
end

## Require all Events
require_files DIR[:events], except: 'Event'

