module Saves::Methods
	module Person
		## Data to save
		def to_save
			return super.merge get_content_to_save
		end

		def get_content_to_save
			content = {}
			return content
		end
	end # END - MODULE Person
end # END - MODULE Saves::Methods
