module Saves::Methods
	module Event
		## Data to save
		def to_save
			return {
				classname: get_classname
			}
		end

		## Restore data
		def restore_savefile content
		end
	end # END - MODULE Event
end # END - MODULE Saves::Methods
