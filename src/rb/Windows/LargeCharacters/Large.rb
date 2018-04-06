
### This module is responsible for creating large AsciiArt versions of text

require_files File.join(DIR[:windows], 'LargeCharacters'), except: 'Large'

module Windows::Large
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

		@large_lines = []
		split_text.each do |type, text|
			case type
			when :normal
				@large_lines << text.split("\n")  unless (text.empty?)
			when :large
				text.split("\n").each do |txt|
					@large_lines << gen_large_character_line(txt)
				end
			end
		end
		#log @text_matrix_lines
		#gen_lines_to_draw_from_text_matrix_lines reverse_text_matrix_lines(@text_matrix_lines)

		if (@all_text_in_window)
			check_if_fits_counter = 0
			while (!large_lines_fit_in_window?)
				break  if (check_if_fits_counter >= 40)
				shrink_large_lines
				check_if_fits_counter += 1
			end
		end

		gen_lines_to_draw_from_large_lines
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

	def gen_large_character_line text
		@current_unlarge_text = text
		large_characters = text.each_char.map do |char|
			next gen_large_character char
		end .reject { |x| !x }
		return Line.new large_characters
	end

	def gen_large_character char
		set_fitting_character_size_for_text @current_unlarge_text
		return Character.new char, @current_character_size
	end

	def set_fitting_character_size_for_text unlarge_text
		@current_character_size_string = nil
		@current_character_size = nil
		unlarge_text_length = unlarge_text.size
		get_sorted_character_sizes.each do |character_size|
			size_width, size_height = character_size.split(?x).map &:to_i
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

	##TODO: DEPRECATED
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

	def large_lines_fit_in_window?
		highest_width = 0
		total_height  = 0
		@large_lines.each do |large_line|
			new_highest_width = 0
			unless (large_line.is_a? Line)
				large_line.each do |normal_text_line|
					normal_text_width = normal_text_line.size
					new_highest_width = normal_text_width  if (normal_text_width > new_highest_width)
					total_height += 1
				end
			else
				char_matrix_width = large_line.character_matrix_width
				char_matrix_height = large_line.character_matrix_height
				amount_of_chars = large_line.characters.size
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

	def shrink_large_lines
		#TODO
		return
		@large_lines.each do |large_line|
		end
	end

	def shrink_text_matrix_line text_matrix_line
		return text_matrix_line.map do |matrix_char|
			next matrix_char  if (matrix_char.is_a? String)
			next matrix_char.map do |matrix_char_line|
				next matrix_char_line
			end
		end
	end

	def gen_lines_to_draw_from_large_lines
		return @large_lines.each do |large_line|
			# Empty lines for padding between large text lines
			unless (large_line == @large_lines.first)
				PADDING_BETWEEN_LARGE_LINES.times do
					@lines_to_draw << ''
				end
			end
			next gen_line_to_draw_from_large_line large_line
		end
	end

	def gen_line_to_draw_from_large_line large_line
		unless (large_line.is_a? Line)
			large_line.each do |normal_text|
				@lines_to_draw << normal_text  unless (large_line.first.empty?)
			end
			return
		end
		return  unless (large_line.is_a?(Line))
		gen_large_characters_to_draw_from_large_line large_line
	end

	def gen_large_characters_to_draw_from_large_line large_line
		large_line.character_matrix_height.times do |char_index|
			@lines_to_draw << ''
			large_line.characters.each.with_index do |character, line_index|
				char_matrix_row = character.matrix[char_index]
				@lines_to_draw[-1] += char_matrix_row
				@lines_to_draw[-1] += ' ' * PADDING_BETWEEN_LARGE_CHARS  if (char_matrix_row.size > 1)
			end
		end
	end

	##TODO: DEPRECATED
	def reverse_text_matrix_lines text_matrix_lines
		return text_matrix_lines.map    do |text_matrix_line|
			next text_matrix_line  if (text_matrix_line.first.is_a?(Array))
			next text_matrix_line.map do |normal_text_line|
				next normal_text_line
			end                    if (text_matrix_line.first.is_a?(String))
		end .reverse
	end

end # END - MODULE
