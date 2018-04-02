module Saves::Methods
	module Component
		## Save data
		def to_save
			return super.merge get_content_to_save
		end

		def get_content_to_save
			{}
		end
	end # END - MODULE Component
end # END - MODULE Saves::Methods
