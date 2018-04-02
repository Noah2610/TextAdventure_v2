module Saves::Methods
	module Inventory
		## Data to save to savefile
		def to_save
			return get_content_to_save
		end

		def get_content_to_save
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

		## Load data
		def load_data content
		end
	end # END - MODULE Inventory
end # END - MODULE Saves::Methods
