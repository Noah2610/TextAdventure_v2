
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
		'9x9'
	]
	CHARACTERS = self.load_characters_as_matrixes

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

		@processed_large_text_lines = []
		split_text.reverse.each do |type, text|
			case type
			when :normal
				@processed_large_text_lines << text.split("\n")  unless (text.empty?)
			when :large
				text.split("\n").each do |txt|
					@processed_large_text_lines << [gen_large_text_matrix(txt)]
				end
			end
		end
		gen_lines_to_draw_from_text_matrix_lines reverse_text_matrix_lines(@processed_large_text_lines)
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
			next [type, part.reverse]
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
		@current_character_size = get_fitting_character_size_for_text @current_unlarge_text
		return char  if (@current_character_size.nil?)
		return get_char_matrix_for_current_size char
	end

	def get_fitting_character_size_for_text unlarge_text
		return nil  unless (@window)
		unlarge_text_length = unlarge_text.size
		get_sorted_character_sizes.each do |character_size|
			size_width, size_height = character_size.split(?x).map &:to_i
			processed_large_text_lines_height = get_total_height_of_processed_large_text
			total_size = [
				(((size_width + 1) * unlarge_text_length) + (@padding * 2)),
				((size_height + 1) + processed_large_text_lines_height + (@padding_h * 2))
			]
			return character_size  if (size_fits_in_window? total_size)
		end
		return nil
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
		return @processed_large_text_lines.map do |line|
			next line.map do |entry|
				next 1                     if (entry.is_a? String)
				next entry.first.size + 1  if (entry.is_a? Array)
				next nil
			end
		end .flatten .reject { |x| !x } .sum
	end

	def size_fits_in_window? size
		return (
			(width  >= size[0]) &&
			(height >= size[1])
		)
	end

	def get_char_matrix_for_current_size char
		char_key = char.upcase
		char_key = 'SPACE'  if (char == ' ')
		return CHARACTERS[@current_character_size][char_key]  if (CHARACTERS[@current_character_size] && CHARACTERS[@current_character_size][char_key])
		return CHARACTERS[@current_character_size]['UNKNOWN']
	end

	def gen_lines_to_draw_from_text_matrix_lines text_matrix_lines
		return text_matrix_lines.each do |text_matrix_line|
			@lines_to_draw << ''  unless (text_matrix_line == text_matrix_lines.first)
			next gen_line_to_draw_from_text_matrix_line text_matrix_line
		end
	end

	def gen_line_to_draw_from_text_matrix_line text_matrix_line
		text_matrix_line.each_with_index do |text_matrix_entry, line_index|
			if (text_matrix_entry.is_a?(String) && !text_matrix_entry.empty?)
				@lines_to_draw << text_matrix_entry
				next
			end
			next  unless (text_matrix_entry.is_a?(Array) && text_matrix_entry.any?)
			text_matrix_entry.first.size.times do |char_index|
				@lines_to_draw << ''
				text_matrix_entry.each do |char_matrix|
					@lines_to_draw[-1] += char_matrix[char_index]
					@lines_to_draw[-1] += ' '  if (char_matrix[char_index].size > 1)
				end
			end
		end
	end

	def reverse_text_matrix_lines text_matrix_lines
		return text_matrix_lines.map    do |text_matrix_line|
			next text_matrix_line.map     do |text_matrix_entry|
				next text_matrix_entry.reverse
			end .reverse
		end .reverse
	end

end # END - MODULE
