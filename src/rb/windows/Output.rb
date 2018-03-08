
class Windows::Output
	attr_reader :lines
	include Windows::Colors

	def initialize args = {}
		@padding      = SETTINGS.output['padding'] || 3
		@padding_h    = SETTINGS.output['padding_height'] || 1
		@indent       = SETTINGS.output['indent'] || 2
		@history_size = SETTINGS.output['history_size'] || 100
		@lines = []
		init args  if (defined? init)
	end

	## Return wanted width for window
	def width
		return screen_size(:w).floor
	end

	## Return wanted height for window
	def height
		return screen_size(:h).floor - 3
	end

	## Return wanted position in screen for window
	def pos target = :all
		ret = nil
		case target
		when :x, :y
			ret = 0
		when :all
			ret = {
				x: pos(:x),
				y: pos(:y)
			}
		end
		return ret
	end

	## Return actual size of window
	def size target = :all
		ret = nil
		case target
		when :width, :w
			ret = @window.maxx
		when :height, :h
			ret = @window.maxy
		when :all
			ret = {
				w: size(:w),
				h: size(:h)
			}
		end
		return ret
	end

	def print text, args = {}
		text.gsub(/\n/, "\n#{' ' * @indent}").split(/\n/).each do |ln|
			@lines << ln
		end
		## Clear early lines
		@lines = @lines[-@history_size .. -1]  if (@lines.size > @history_size)
		## Set Curses attributes if given
		redraw
	end

	def clear
		@lines.clear
	end

	## Process color-coded string.
	## Return string without color-codes and
	## color stack with indices for returned string
	def process_color_codes lines
		str = lines.join "\n"  if (lines.is_a? Array)
		regex = /{[A-z,;:=]+?}/

		## String without color-codes, will be returned
		str_new = str.dup
		## Will be filled with color-pair ids at appropriate indices, will be returned
		color_stack = []

		return lines, nil  unless (str.match regex)

		## Scan str for color-codes
		str.scan regex do |code|
			index = (str_new =~ /#{Regexp.quote code}/)
			str_new.sub! code, ''
			## Handle color-code
			codes = code.match(/{(.+?)}/m)[1].split(/[; ]/)
			codes.each do |c|
				# Color
				if (m = c.match(/\ACOLOR[:=]([A-z,]+?)\z/))
					colors = m[1].split(/[,]/)
					color_stack[index] = colors
				end
			end
		end

		return str_new.split("\n"), color_stack
	end

	def redraw
		@window.clear
		@window.move pos(:y), pos(:x)
		@window.resize height, width
		@window.box ?|, ?-

		## Process lines

		## Generate color stack for color-coded strings
		lines, color_stack = process_color_codes @lines

		unless (lines.nil? || lines.empty?)
			lines_final = []
			lines.each_with_index do |line, index|
				## Check if line is too long and has to be split
				max_width = size(:w) - (@padding * 2)
				if (line.size > max_width)

					## First line
					lines_final << line[0 ... max_width]

					## Split following lines, indented
					indented_max_width = max_width - @indent
					indented_lines = line[(max_width) .. -1]
					begin
						indented_lines_count = (((indented_lines.size / indented_max_width) + 1).floor)
					rescue ZeroDivisionError
						return
					end
					indented_lines_count.times do |n|
						lines_final << "{INDENT}#{indented_lines[(indented_max_width * n) ... (indented_max_width * (n + 1))]}"
					end

				else
					## Line fits in width
					lines_final << line
				end
			end

			## Index counter of all characters printed, necessary for color-coding
			char_index = 0

			## Remove lines that don't fit in window height
			max_height = size(:h) - (@padding_h * 2)
			if (lines_final.size > max_height)
				diff = lines_final.size - max_height
				char_index += (lines_final[0 ... diff].join(?X) + ?X).delete('{INDENT}').size - lines_final[0 ... diff].join.scan('{INDENT}').size
				lines_final = lines_final[diff .. -1]
			end

			## Print lines
			if (color_stack && c = color_stack[char_index])
				change_color c
			end
			return  if (lines_final.nil?)
			lines_final.each_with_index do |line, index|
				## Indent line if necessary (for split lines)
				if (line =~ /\A{INDENT}/)
					line.sub! '{INDENT}', ''
					@window.setpos index + @padding_h, @padding + @indent
					char_index -= 1
				else
					@window.setpos index + @padding_h, @padding
				end
				## Loop through chars and check for color-coding (according to color_stack)
				line.each_char.with_index do |char, i|
					if (color_stack && c = color_stack[char_index])
						change_color c
					end
					@window.addch char
					char_index += 1
				end
				if (color_stack && c = color_stack[char_index])
					change_color c
				end
				char_index += 1
			end
		end

		@window.refresh
	end
end

class Windows::PrimaryOut < Windows::Output
	def init args = {}
		@window = Curses::Window.new(
			height,  width,
			pos(:y), pos(:x)
		)
		redraw
	end

	## Return wanted width for window
	def width
		return screen_size(:w)
	end

	## Return wanted height for window
	def height
		return screen_size(:h) - 3
	end

	## Return wanted position in screen for window
	def pos target = :all
		ret = nil
		case target
		when :x, :y
			ret = 0
		when :all
			ret = {
				x: pos(:x),
				y: pos(:y)
			}
		end
		return ret
	end

	def update
		redraw
	end
end

