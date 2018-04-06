module Windows::Large
	class Line
		def initialize characters = []
			@characters = characters
		end

		def new_character *args
			@characters << Character.new(*args)
		end

		def characters
			return @characters
		end

		def character_matrix_width
			return 0  if (@characters.empty?)
			return @characters.first.matrix.first.size
		end

		def character_matrix_height
			return 0  if (@characters.empty?)
			return @characters.first.matrix.size
		end
	end # END - CLASS Line
end # END - MODULE Windows::Large
