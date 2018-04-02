module Saves::Methods
	module Inventory
		## Data to save to savefile
		def to_save
			return {
				Items:    get_content_to_save_from_items,
				can_take: @can_take
			}
		end

		def get_content_to_save_from_items
			return items.map do |item|
				next item.to_save
			end
		end

		## Load data from savefile
		def restore_savefile content
			items_clear
			restore_items content['Items']
			if (content['can_take'])
				clear_can_take
				self.can_take = content['can_take']
			end
		end

		def restore_items items_content
			items_content.each do |item_content|
				restore_item item_content
			end
		end

		def restore_item content
			item = restore_get_item content['classname']
			return  unless (item)
			item.restore_savefile content
			item_add item
		end

		def restore_get_item itemname
			itemname = itemname.to_sym
			item = nil
			if (Instances::Items.constants.include? itemname)
				item = Instances::Items.const_get(itemname).new
			else
				log "WARNING: An Inventory tried loading Item '#{itemname.to_s}' which doesn't exist!"
			end
			return item
		end
	end # END - MODULE Inventory
end # END - MODULE Saves::Methods
