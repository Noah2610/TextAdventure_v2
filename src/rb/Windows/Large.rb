
### This module is responsible for creating large AsciiArt versions of text

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

	CHARACTER_DIR = File.join DIR[:ascii_art], 'Characters'
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
	CHARACTERS = self.load_characters_as_matrixes
	PADDING_BETWEEN_LARGE_LINES = 1
	PADDING_BETWEEN_LARGE_CHARS = 1

	def initialize args = {}
		super
		@lines_to_draw = nil
	end

	def redraw
		@lines_to_draw = []
		process_large
		super
	end

	def get_lines_to_draw
		return @lines_to_draw || @lines
	end

	def process_large
		@full_normal_text = @lines.join("\n")

		split_text = split_text_into_normal_and_large_groups

		@text_matrix_lines = []
		split_text.each do |type, text|
			case type
			when :normal
				@text_matrix_lines << text.split("\n")  unless (text.empty?)
			when :large
				text.split("\n").each do |txt|
					@text_matrix_lines << gen_large_text_matrix(txt)
				end
			end
		end
		#log @text_matrix_lines
		#gen_lines_to_draw_from_text_matrix_lines reverse_text_matrix_lines(@text_matrix_lines)

		if (@all_text_in_window)
			check_if_fits_counter = 0
			while (!text_matrix_lines_fit_in_window?)
				break  if (check_if_fits_counter >= 40)
				shrink_text_matrix_lines
				check_if_fits_counter += 1
			end
		end

		gen_lines_to_draw_from_text_matrix_lines @text_matrix_lines
	end

	def split_text_into_normal_and_large_groups
		normal_text_dup = @full_normal_text.dup
		split_text = []
		regex_for_scan = /(#{'{LARGE_START}'}(.+?)#{'{LARGE_END}'})/m
		@full_normal_text.scan regex_for_scan do |large_text_arr|
			full_match = large_text_arr[0]
			large_text = large_text_arr[1]
			index = normal_text_dup.index full_match
			sliced = normal_text_dup.slice!(0 ... index)
			split_text << [:normal, sliced]     unless (sliced.empty?)
			split_text << [:large, large_text]  unless (large_text.empty?)
			normal_text_dup.slice!(0 ... full_match.size)
		end
		split_text << [:normal, normal_text_dup]
		split_text.map! do |type, part|
			next [type, part]
		end
		return split_text
	end

	def gen_large_text_matrix text
		@current_unlarge_text = text
		return text.each_char.map do |char|
			next gen_large_char_matrix char
		end .reject { |x| !x }
	end

	def gen_large_char_matrix char
		set_fitting_character_size_for_text @current_unlarge_text
		return [char]  if (@current_character_size_string.nil?)
		return get_char_matrix_for_current_size char
	end

	def set_fitting_character_size_for_text unlarge_text
		@current_character_size_string = nil
		@current_character_size = nil
		unlarge_text_length = unlarge_text.size
		get_sorted_character_sizes.each do |character_size|
			size_width, size_height = character_size.split(?x).map &:to_i
			processed_large_text_lines_height = get_total_height_of_processed_large_text
			total_size = [
				((size_width + PADDING_BETWEEN_LARGE_CHARS + 1) * unlarge_text_length),
				(size_height + PADDING_BETWEEN_LARGE_LINES)
			]
			if (size_fits_in_window? total_size)
				@current_character_size_string = character_size
				sizes = character_size.match(/\A([0-9])+x([0-9]+)\z/)[1 .. -1]
				sizes.map! &:to_i
				@current_character_size = {
					width:  sizes[0],
					height: sizes[1]
				}
				return
			end
		end
	end

	def get_sorted_character_sizes
		return CHARACTER_SIZES.sort do |size_a, size_b|
			val_a = get_total_ascii_value_of_string size_a
			val_b = get_total_ascii_value_of_string size_b
			next val_b - val_a
		end
	end

	def get_total_ascii_value_of_string string
		return string.each_char.reduce do |char_a, char_b|
			next char_a.ord + char_b.ord
		end + string[0].ord
	end

	def get_total_height_of_processed_large_text
		return @text_matrix_lines.map do |line|
			next line.map do |entry|
				next 1                     if (entry.is_a? String)
				next nil                   if (entry.is_a?(Array) && entry.empty?)
				next entry.first.size + 1  if (entry.is_a? Array)
				next nil
			end
		end .flatten .reject { |x| !x } .sum
	end

	def size_fits_in_window? size
		return (
			(width  >= (size[0] + (@padding * 2))) &&
			(height >= (size[1] + (@padding_h * 2)))
		)
	end

	def get_char_matrix_for_current_size char
		char_key = char.upcase
		char_key = 'SPACE'  if (char == ' ')
		if (CHARACTERS[@current_character_size_string])
			return CHARACTERS[@current_character_size_string][char_key]   if (CHARACTERS[@current_character_size_string][char_key])
			return CHARACTERS[@current_character_size_string]['UNKNOWN']
		end
		return get_truncated_version_of_char_for_current_size char
	end

	def get_truncated_version_of_char_for_current_size char
		char_key = char.upcase
		char_key = 'SPACE'  if (char == ' ')
		return ??  unless (@current_character_size[:width] > @current_character_size[:height])

		char_matrix = get_char_matrix_for_parent_size char
		return ??  unless (char_matrix)

		indices_to_truncate = get_indices_to_truncate

		new_char_matrix = char_matrix.dup
		indices_to_truncate.each do |index|
			new_char_matrix[index] = nil
		end
		new_char_matrix.reject! { |x| !x }
		return new_char_matrix
	end

	def get_char_matrix_for_parent_size char
		char_key = char.upcase
		char_key = 'SPACE'  if (char == ' ')
		char_matrix = nil
		parent_size = "#{@current_character_size[:width]}x#{@current_character_size[:width]}"
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

	def get_truncation_step
		return ((@current_character_size[:width] - @current_character_size[:height]) / 2.0).floor
	end

	def get_truncation_indices
		truncation_n = (@current_character_size[:width].to_f / 3.0).round - 1
		truncation_indices = {
			above: (truncation_n),
			below: ((@current_character_size[:width] - 1) - truncation_n)
		}
	end

	def get_indices_to_truncate_for_above_index truncation_index
		return get_truncation_step.times.map.with_index do |step, counter|
			if    (counter % 2 == 0)  # EVEN counter - go DOWN (because starts with 0)
				if (truncation_index + counter < @current_character_size[:width] - 1)
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
				if (truncation_index + counter < @current_character_size[:width] - 1)
					truncation_index += counter
				else
					truncation_index -= counter
				end
			end
			next truncation_index.dup
		end
	end

	def text_matrix_lines_fit_in_window?
		highest_width = 0
		total_height  = 0
		@text_matrix_lines.each do |matrix_line|
			new_highest_width = 0
			if    (matrix_line.first.is_a? String)
				matrix_line.each do |normal_text_line|
					normal_text_width = normal_text_line.size
					new_highest_width = normal_text_width  if (normal_text_width > new_highest_width)
					total_height += 1
				end
			elsif (matrix_line.first.is_a? Array)
				first_char = matrix_line.first
				char_matrix_width = first_char.first.size
				char_matrix_height = first_char.size
				amount_of_chars = matrix_line.size
				new_highest_width = (char_matrix_width * amount_of_chars) + (PADDING_BETWEEN_LARGE_CHARS * amount_of_chars)
				total_height += (char_matrix_height + PADDING_BETWEEN_LARGE_LINES)
			end
			highest_width = new_highest_width  if (new_highest_width > highest_width)
		end

		total_size = [
			highest_width,
			total_height
		]
		return size_fits_in_window? total_size
	end

	def shrink_text_matrix_lines
		log GAME.get_tick, 'SHRINK!!'
	end

	def gen_lines_to_draw_from_text_matrix_lines text_matrix_lines
		return text_matrix_lines.each do |text_matrix_line|
			# Empty lines for padding between large text lines
			unless (text_matrix_line == text_matrix_lines.first)
				PADDING_BETWEEN_LARGE_LINES.times do
					@lines_to_draw << ''
				end
			end
			next gen_line_to_draw_from_text_matrix_line text_matrix_line
		end
	end

	def gen_line_to_draw_from_text_matrix_line text_matrix_line
		if (text_matrix_line.first.is_a?(String))
			text_matrix_line.each do |normal_text|
				@lines_to_draw << normal_text  unless (text_matrix_line.first.empty?)
			end
			return
		end
		return  unless (text_matrix_line.is_a?(Array) && text_matrix_line.any?)
		text_matrix_line.first.size.times do |char_index|
			@lines_to_draw << ''
			text_matrix_line.each_with_index do |char_matrix, line_index|
				@lines_to_draw[-1] += char_matrix[char_index]
				@lines_to_draw[-1] += ' ' * PADDING_BETWEEN_LARGE_CHARS  if (char_matrix[char_index].size > 1)
			end
		end
	end

	def reverse_text_matrix_lines text_matrix_lines
		return text_matrix_lines.map    do |text_matrix_line|
			next text_matrix_line  if (text_matrix_line.first.is_a?(Array))
			next text_matrix_line.map do |normal_text_line|
				next normal_text_line
			end                    if (text_matrix_line.first.is_a?(String))
		end .reverse
	end

end # END - MODULE
