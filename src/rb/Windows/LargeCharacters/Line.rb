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

		def character_size
			return 0  if (@characters.empty?)
			return characters.first.get_size
		end

		def character_width
			return 0  if (characters.empty?)
			return character_size[:width]
		end

		def character_height
			return 0  if (characters.empty?)
			return character_size[:height]
		end

		def shrink
			get_characters_sorted_by_size.each do |character|
				character.shrink
			end
		end

		def get_characters_sorted_by_size sort_direction = :descending
			return characters.sort do |char_a, char_b|
				size_val_a = Windows::Large.get_total_ascii_value_of_string char_a.get_size_string
				size_val_b = Windows::Large.get_total_ascii_value_of_string char_b.get_size_string
				next size_val_b - size_val_a  if (sort_direction == :descending)
				next size_val_a - size_val_b  if (sort_direction == :ascending)
			end
		end

		def is_normal?
			return false  if (characters.empty?)
			return characters.first.is_normal?
		end

		def is_large?
			return false  if (characters.empty?)
			return characters.first.is_large?
		end
	end # END - CLASS Line
end # END - MODULE Windows::Large
