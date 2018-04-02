module Saves::Methods
	module Instance
		## Return Data to save
		def to_save
			content_to_save = {
				classname: get_classname,
				known:     known?
			}
			content_to_save[:Inventory] = @inventory.to_save  if (has_inventory?)
			content_to_save[:is_open]   = is_open?            if (is_openable?)
			return content_to_save
		end
	end
end # END - MODULE Saves::Methods
