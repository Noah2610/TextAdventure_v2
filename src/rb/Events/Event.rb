
## Events are Room specific Keywords

module Events
	class Event
		include Keywords
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

