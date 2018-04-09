
### This module is responsible for creating large AsciiArt versions of text

## Just set some constants before anything else
module Windows::Large
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
	PADDING_BETWEEN_LARGE_LINES = 1
	PADDING_BETWEEN_LARGE_CHARS = 1
end

require_files File.join(DIR[:windows], 'LargeCharacters'), except: 'Large'

module Windows::Large
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

		split_text = split_text_into_groups

		@large_lines = []
		split_text.each do |type, text, alignment|
			@current_alignment = alignment
			case type
			when :normal
				split = text.split("\n")
				@large_lines << split                  unless (split.empty?)
			when :large
				split = text.split("\n")
				split.each do |txt|
					@large_lines << gen_large_line(txt)  unless (txt.empty?)
				end  unless (split.empty?)
			end
		end

		check_if_fits_counter = 0
		while (!large_lines_fit_in_window?)
			break  if (check_if_fits_counter >= 40)
			shrink_large_lines
			check_if_fits_counter += 1
		end

		gen_lines_to_draw_from_large_lines
	end

	def split_text_into_groups
		normal_text_dup = @full_normal_text.dup
		split_text = []
		regex_for_scan = /({LARGE_START(:\w+?)?}(.+?){LARGE_END})/m
		@full_normal_text.scan regex_for_scan do |regex_match_arr|
			full_match = regex_match_arr[0]
			alignment  = regex_match_arr[1] ? regex_match_arr[1].sub(?:, '') : nil
			large_text = regex_match_arr[2]
			index = normal_text_dup.index full_match
			sliced = normal_text_dup.slice!(0 ... index)
			split_text << [:normal, sliced, alignment]     unless (sliced.empty?)
			split_text << [:large, large_text, alignment]  unless (large_text.empty?)
			normal_text_dup.slice!(0 ... full_match.size)
		end
		split_text << [:normal, normal_text_dup, nil]
		return split_text
	end

	def gen_large_line text
		@current_unlarge_text = text
		current_attr_code = nil
		full_attr_code = nil
		large_characters = text.each_char.map do |char|
			## Handle attribute codes
			if    (char == ?{)
				current_attr_code = ?{
				next nil
			elsif (current_attr_code && char != ?})
				current_attr_code += char
				next nil
			elsif (current_attr_code && char == ?})
				current_attr_code += char
				full_attr_code = current_attr_code
				current_attr_code = nil
				next nil
			end

			if (full_attr_code)
				large_char = gen_large_character char, attr_code: full_attr_code
				full_attr_code = nil
				next large_char
			else
				next gen_large_character char
			end
		end .reject { |x| !x }
		return Line.new large_characters, alignment: @current_alignment
	end

	def gen_large_character char, args = {}
		unlarge_text = @current_unlarge_text.gsub /{.+?}/, ''
		set_fitting_character_size_for_text unlarge_text
		return Character.new char, @current_character_size, args
	end

	##TODO:
	## Maybe remove this method and initially create characters at largest possible size?
	## They will ne resized after all have been created anyway
	def set_fitting_character_size_for_text unlarge_text
		@current_character_size_string = nil
		@current_character_size = nil
		unlarge_text_length = unlarge_text.size
		Windows::Large.get_sorted_character_sizes.each do |character_size|
			size_width, size_height = character_size.split(?x).map &:to_i
			total_size = [
				((size_width + PADDING_BETWEEN_LARGE_CHARS) * unlarge_text_length),
				(size_height + PADDING_BETWEEN_LARGE_LINES)
			]
			if (size_fits_in_window? total_size)
				@current_character_size_string = character_size
				sizes = character_size.match(/\A([0-9])+x([0-9]+)\z/)[1 .. -1].map &:to_i
				@current_character_size = {
					width:  sizes[0],
					height: sizes[1]
				}
				return
			end
		end
	end

	def self.get_sorted_character_sizes sort_direction = :descending
		return CHARACTER_SIZES.sort do |size_a, size_b|
			val_a = Windows::Large.get_total_ascii_value_of_string size_a
			val_b = Windows::Large.get_total_ascii_value_of_string size_b
			next val_b - val_a  if (sort_direction == :descending)
			next val_a - val_b  if (sort_direction == :ascending)
		end
	end

	def self.get_total_ascii_value_of_string string
		return 0  if (string.nil?)
		return string.each_char.reduce do |char_a, char_b|
			next char_a.ord + char_b.ord
		end + string[0].ord * 2
		# Adding the doubled value of the first char is a kinda hacky workaround
		# to prioritize the value of the first char (width axis)
	end

	def size_fits_in_window? size
		return (
			(width  >= (size[0] + (@padding   * 2))) &&
			(height >= (size[1] + (@padding_h * 2)))
		)
	end

	def get_large_lines_total_size
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
				char_width        = large_line.character_width
				char_height       = large_line.character_height
				amount_of_chars   = large_line.characters.size
				new_highest_width = (char_width * amount_of_chars) + (PADDING_BETWEEN_LARGE_CHARS * amount_of_chars)
				total_height     += (char_height + PADDING_BETWEEN_LARGE_LINES)
			end
			highest_width = new_highest_width  if (new_highest_width > highest_width)
		end
		total_height -= PADDING_BETWEEN_LARGE_LINES

		total_size = [
			highest_width,
			total_height
		]
		return total_size
	end

	def large_lines_fit_in_window?
		return size_fits_in_window? get_large_lines_total_size
	end

	def shrink_large_lines
		@large_lines.each do |large_line|
			next   unless (large_line.is_a? Line)
			large_line.shrink
			break  if (large_lines_fit_in_window?)
		end
	end

	def gen_lines_to_draw_from_large_lines
		return @large_lines.each do |large_line|
			# Empty lines for padding between large text lines
			PADDING_BETWEEN_LARGE_LINES.times do
				@lines_to_draw << ''
			end  unless (large_line == @large_lines.first || large_line.is_normal?)
			next gen_line_to_draw_from_large_line large_line
		end
	end

	def gen_line_to_draw_from_large_line large_line
		unless (large_line.is_a? Line)
			handle_line_to_draw_for_normal_line large_line
			return
		end
		return  unless (large_line.is_a?(Line))

		large_line_to_draw = gen_line_to_draw_with_alignment large_line
		@lines_to_draw.concat large_line_to_draw
	end

	def gen_line_to_draw_with_alignment large_line
		alignment = large_line.alignment ? large_line.alignment.to_sym : nil
		line_to_draw = large_line.gen_characters_to_draw
		aligned_line_to_draw = []
		case alignment
		when :center
			aligned_line_to_draw = line_to_draw.map do |row|
				plain_row_size = row.gsub(/{.+?}/, '').size
				padding_amount = ((width - plain_row_size - @padding * 2) * 0.5).floor
				padding = padding_amount > 0 ? ' ' * padding_amount : ''
				next "#{padding}#{row}"
			end
		when :right
			aligned_line_to_draw = line_to_draw.map do |row|
				plain_row_size = row.gsub(/{.+?}/, '').size
				padding_amount = (width - plain_row_size - @padding * 2).floor
				padding = padding_amount > 0 ? ' ' * padding_amount : ''
				next "#{padding}#{row}"
			end
		else
			aligned_line_to_draw = line_to_draw
		end
		return aligned_line_to_draw
	end

	def handle_line_to_draw_for_normal_line normal_line
		normal_line.each do |normal_text|
			@lines_to_draw << normal_text  unless (normal_line.first.empty?)
		end
	end

	def handle_alignment_for_large_line_to_draw line_to_draw
	end
end # END - MODULE
