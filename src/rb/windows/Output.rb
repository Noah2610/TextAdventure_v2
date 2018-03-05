
class Windows::Output
	def initialize args = {}
		@padding      = SETTINGS.output['padding'] || 3
		@padding_h    = SETTINGS.output['padding_height'] || 1
		@indent       = SETTINGS.output['indent'] || 2
		@history_size = SETTINGS.output['history_size'] || 100
		@lines = []
		init args  if (defined? init)
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

	def redraw
		@window.clear
		@window.move pos(:y), pos(:x)
		@window.resize height, width
		@window.box ?|, ?-

		## Process lines
		lines_final = []
		@lines.each_with_index do |line, index|
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

		## Remove lines that don't fit in window height
		max_height = size(:h) - (@padding_h * 2)
		if (lines_final.size > max_height)
			diff = lines_final.size - max_height
			lines_final = lines_final[diff .. -1]
		end

		## Print lines
		lines_final.each_with_index do |line, index|
			@window.setpos index + @padding_h, @padding
			@window.addstr line
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
		return (screen_size(:w) * 0.35).floor
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

