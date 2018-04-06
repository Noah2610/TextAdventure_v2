module Windows::Large
	def self.load_characters_as_matrixes
		return Dir.new(CHARACTER_DIR).map do |dir|
			dirpath = File.join CHARACTER_DIR, dir
			next nil  if (self.is_invalid_dir?(dir) || File.file?(dirpath) || !CHARACTER_SIZES.include?(dir))
			next [dir, self.load_characters_in_dir_as_matrixes(dirpath)]
		end .reject { |x| !x } .to_h
	end

	def self.is_invalid_dir? dir
		return dir.match? /\A\.{1,2}\z/
	end

	def self.load_characters_in_dir_as_matrixes dir
		return Dir.new(dir).map do |charfile|
			next nil  if (self.is_invalid_dir? charfile)
			charfile_path    = File.join dir, charfile
			charfile_content = File.read charfile_path
			next [charfile, charfile_content.split("\n")]
		end .reject { |x| !x } .to_h
	end

	CHARACTER_SIZES = [
		'3x3',
		'5x5',
		'7x7',
		'9x9',
		'5x3',
		'7x5',
		'7x3',
		'9x7',
		'9x5',
		'9x3',
	]
	CHARACTER_DIR = File.join DIR[:ascii_art], 'Characters'
	CHARACTERS = self.load_characters_as_matrixes

	class Character
		def initialize char, size
			@char = char
			@size = size
			@char_matrix = gen_char_matrix
		end

		def gen_char_matrix
			return [@char]                               if (is_normal?)
			size_string = get_size_string
			char_key = get_char_key
			if (CHARACTERS[size_string])
				return CHARACTERS[size_string][char_key]   if (CHARACTERS[size_string][char_key])
				return CHARACTERS[size_string]['UNKNOWN']
			end
			return gen_truncated_char_matrix
		end

		def is_normal?
			return !is_large?
		end

		def is_large?
			return !!@size
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
			if (CHARACTERS[parent_size])
				char_matrix   = CHARACTERS[parent_size][char_key]
				char_matrix ||= CHARACTERS[parent_size]['UNKNOWN']
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

		def matrix
			return @char_matrix
		end
	end # END - CLASS Character
end # END - MODULE Windows::Large
