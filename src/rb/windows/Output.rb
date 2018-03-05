
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
		regex = /(?<before>.*?)(?<code>{[A-z,;:=]+?})/m

		## String without color-codes, will be returned
		str_new = ''
		## Temporary string only for this method
		str_tmp = str.dup
		## Indices to be filled with indices of color-codes, adjusted to str_new
		indices = []
		## Will be filled with color-pair ids at appropriate indices, will be returned
		color_stack = []
		color_stack_tmp = []

		return lines, nil  unless (str.match regex)
		## Scan str for color-codes
		str.scan regex do |before, code|
			str_new += before
			indices << (str_tmp =~ /#{Regexp.quote code}/)
			#str_tmp.sub! /#{Regexp.quote(before + code)}/, ''
			str_tmp.sub! /#{regex}/, ''
			## Handle code
			codes = code.match(/{(.+?)}/m)[1].split(/[; ]/)
			codes.each do |c|
				# Color
				if (m = c.match(/\ACOLOR[:=]([A-z,]+?)\z/))
					colors = m[1].split(/[,]/)
					color_stack_tmp << colors
				end
			end
		end

		#str_new += str_tmp[indices.last .. -1]
		str_new += str_tmp

		## Create color_stack with indices and color_stack_tmp
		color_stack = Array.new(indices.max)
		indices.each_with_index do |index,i|
			color_stack[index] = color_stack_tmp[i]
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
		log $loop_counter, lines, color_stack

		unless (lines.nil?)
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
					indented_lines_count = (((indented_lines.size / indented_max_width) + 1).floor)
					indented_lines_count.times do |n|
						lines_final << "#{' ' * @indent}#{indented_lines[(indented_max_width * n) ... (indented_max_width * (n + 1))]}"
					end

				else
					## Line fits in width
					lines_final << line
				end
			end

			lines_index = 0

			## Remove lines that don't fit in window height
			max_height = size(:h) - (@padding_h * 2)
			if (lines_final.size > max_height)
				diff = lines_final.size - max_height
				diff_length = lines_final[0 .. diff].join('').size
				lines_index += diff_length
				lines_final = lines_final[diff .. -1]
			end

			## Print lines
			lines_final.each_with_index do |line, index|
				@window.setpos index + @padding_h, @padding
				## Loop through chars and check for color-coding (according to color_stack)
				line.each_char do |char|
					if (color_stack && c = color_stack[lines_index])
						change_color c
					end
					@window.addch char
					lines_index += 1
				end
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
		return (screen_size(:w) * 0.50).floor
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

=begin
class Windows::SecondaryOut < Windows::Output
	def init args = {}
		@window = Curses::Window.new(
			height,  width,
			pos(:y), pos(:x)
		)
		redraw
	end

	## Return wanted width for window
	def width
		return (screen_size(:w) * 0.65).floor
	end

	## Return wanted height for window
	def height
		return ((screen_size(:h) * 0.5) - 1).floor
	end

	## Return wanted position in screen for window
	def pos target = :all
		ret = nil
		case target
		when :x
			ret = (screen_size(:w) * 0.35).ceil
		when :y
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


class Windows::TertiaryOut < Windows::Output
	def init args = {}
		@window = Curses::Window.new(
			height,  width,
			pos(:y), pos(:x)
		)
		redraw
	end

	## Return wanted width for window
	def width
		return (screen_size(:w) * 0.65).floor
	end

	## Return wanted height for window
	def height
		return ((screen_size(:h) * 0.5) - 2).floor
	end

	## Return wanted position in screen for window
	def pos target = :all
		ret = nil
		case target
		when :x
			ret = (screen_size(:w) * 0.35).ceil
		when :y
			ret = ((screen_size(:h) * 0.5) - 1).ceil
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
=end

