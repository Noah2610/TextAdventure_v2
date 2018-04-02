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

		## Restore / load data from savefile
		def restore_savefile content
			known!                                            if (content['known'])
			restore_inventory content['Inventory']            if (content['Inventory'])
			open!                                             if (content['is_open'])
		end

		def restore_inventory content
			@inventory.restore_savefile content
		end
	end
end # END - MODULE Saves::Methods
