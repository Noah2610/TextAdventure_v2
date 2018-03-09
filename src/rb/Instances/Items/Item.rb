
module Instances
	module Items
		class Item < Instances::Instance
			def initialize args = {}
				super
			end

			def can_add_to_inventory?
				return !@data['cannot_add_to_inventory']
			end
			def cannot_add_to_inventory?
				return !!@data['cannot_add_to_inventory']
			end
		end
	end
end

