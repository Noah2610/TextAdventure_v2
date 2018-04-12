module Windows::Large
	def self.load_characters_as_matrixes
		return Dir.new(CHARACTER_DIR).map do |dir|
			dirpath = File.join CHARACTER_DIR, dir
			next nil  if (invalid_dir?(dir) || File.file?(dirpath) || !CHARACTER_SIZES.include?(dir))
			next [dir, self.load_characters_in_dir_as_matrixes(dirpath)]
		end .reject { |x| !x } .to_h
	end

	def self.load_characters_in_dir_as_matrixes dir
		return Dir.new(dir).map do |charfile|
			next nil  if (invalid_dir? charfile)
			charfile_path    = File.join dir, charfile
			charfile_content = File.read charfile_path
			next [charfile, charfile_content.split("\n")]
		end .reject { |x| !x } .to_h
	end

	CHARACTER_MATRIXES = self.load_characters_as_matrixes

	class Character
		def initialize char, size, args = {}
			size = get_size_hash_from_string size
			@char = char
			@attr_code = args[:attr_code]
			resize_to size
		end

		def resize_to size
			@size = size
			@char_matrix = gen_char_matrix
			@char_matrix_to_draw = gen_char_matrix_to_draw
		end

		def gen_char_matrix
			return [@char]                                       if (is_normal?)
			size_string = get_size_string
			char_key = get_char_key
			if (CHARACTER_MATRIXES[size_string])
				if (CHARACTER_MATRIXES[size_string][char_key])
					return CHARACTER_MATRIXES[size_string][char_key]
				else
					return CHARACTER_MATRIXES[size_string]['UNKNOWN']
				end
			end
			return gen_truncated_char_matrix
		end

		def is_normal?
			return !is_large?
		end

		def is_large?
			return !!@size
		end

		def get_size
			return @size  if (!!@size)
			return {
				width:  1,
				height: 1
			}
		end

		def get_size_string
			return nil  if (@size.nil?)
			return "#{@size[:width]}x#{@size[:height]}"
		end

		def get_char_key
			return @char.upcase  unless (@char == ' ')
			return 'SPACE'
		end

		def gen_truncated_char_matrix
			char_key = get_char_key
			return ??  unless (@size[:width] > @size[:height])

			parent_char_matrix = get_char_matrix_for_parent_size
			return ??  unless (parent_char_matrix)

			indices_to_truncate = get_indices_to_truncate

			new_char_matrix = parent_char_matrix.dup
			indices_to_truncate.each do |index|
				new_char_matrix[index] = nil
			end
			new_char_matrix.reject! { |x| !x }
			return new_char_matrix
		end

		def get_char_matrix_for_parent_size
			char_key = get_char_key
			char_matrix = nil
			parent_size = "#{@size[:width]}x#{@size[:width]}"
			if (CHARACTER_MATRIXES[parent_size])
				char_matrix   = CHARACTER_MATRIXES[parent_size][char_key]
				char_matrix ||= CHARACTER_MATRIXES[parent_size]['UNKNOWN']
			end
			return char_matrix
		end

		def get_indices_to_truncate
			truncation_indices = get_truncation_indices
			indices_to_truncate = []
			indices_to_truncate << get_indices_to_truncate_for_above_index(truncation_indices[:above])
			indices_to_truncate << get_indices_to_truncate_for_below_index(truncation_indices[:below])
			indices_to_truncate.flatten!

			return indices_to_truncate
		end

		def get_truncation_indices
			truncation_n = (@size[:width].to_f / 3.0).round - 1
			truncation_indices = {
				above: (truncation_n),
				below: ((@size[:width] - 1) - truncation_n)
			}
		end

		def get_truncation_step
			return ((@size[:width] - @size[:height]) / 2.0).floor
		end

		def get_indices_to_truncate_for_above_index truncation_index
			return get_truncation_step.times.map.with_index do |step, counter|
				if    (counter % 2 == 0)  # EVEN counter - go DOWN (because starts with 0)
					if (truncation_index + counter < @size[:width] - 1)
						truncation_index += counter
					else
						truncation_index -= counter
					end
				elsif (counter % 2 == 1)  # ODD  counter - go UP
					if (truncation_index - counter > 0)
						truncation_index -= counter
					else
						truncation_index += counter
					end
				end
				next truncation_index.dup
			end
		end

		def get_indices_to_truncate_for_below_index truncation_index
			return get_truncation_step.times.map.with_index do |step, counter|
				if    (counter % 2 == 0)  # EVEN counter - go UP (because starts with 0)
					if (truncation_index - counter > 0)
						truncation_index -= counter
					else
						truncation_index += counter
					end
				elsif (counter % 2 == 1)  # ODD  counter - go DOWN
					if (truncation_index + counter < @size[:width] - 1)
						truncation_index += counter
					else
						truncation_index -= counter
					end
				end
				next truncation_index.dup
			end
		end

		def gen_char_matrix_to_draw char_matrix = @char_matrix
			return char_matrix  unless (@attr_code)
			return char_matrix.map do |matrix_line|
				next "#{@attr_code}#{matrix_line}"
			end
		end

		def matrix
			return @char_matrix
		end

		def matrix_to_draw
			return @char_matrix_to_draw
		end

		def get_size_hash_from_string size_string
			return size_string  unless (size_string.is_a? String)
			return size_string.match(/\A([0-9]+?)x([0-9]+)\z/)[1 .. -1].map &:to_i
		end

		def shrink
			sorted_character_sizes = Windows::Large.get_sorted_character_sizes :ascending
			current_size_index = sorted_character_sizes.index get_size_string
			return  if (current_size_index.nil?)
			smaller_size = nil
			if (current_size_index > 1)
				smaller_size_string = sorted_character_sizes[current_size_index - 1]
				sizes = get_size_hash_from_string smaller_size_string
				smaller_size = {
					width:  sizes[0],
					height: sizes[1]
				}
			end
			resize_to smaller_size
		end
	end # END - CLASS Character
end # END - MODULE Windows::Large
