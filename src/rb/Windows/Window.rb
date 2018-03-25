
### Currently this file only creates the Windows module.
### The curses windows themselves are defined in their own files in the windows directory.
##  ex.: Input Window, Main Output Window, Conversation Output Window, ...

module Windows
	MIN_WIDTH  = SETTINGS.output['min_width']
	MIN_HEIGHT = SETTINGS.output['min_height']

	class Window
		def initialize args = {}
			@hidden = false
			@width  = args[:width]   || args[:w] || 1.0
			@height = args[:height]  || args[:h] || 1.0
			@pos    = ( args[:pos]   || (
				(args[:x] && args[:y]) ? { x: args[:x], y: args[:y] } : { x: 0.0, y: 0.0 }
			))
			@border = [?|, ?-]
		end

		def init_curses
			## Init Curses Window
			@window = Curses::Window.new(
				height,  width,
				pos(:y), pos(:x)
			)
		end

		## Set width, height, and position
		def set_width amount, type = :percent
			case type
			when :percent, :perc
				@width = (screen_size(:w) * amount).floor
			when :absolute, :abs
				@width = amount
			end
		end
		def set_height amount, type = :percent
			case type
			when :percent, :perc
				@height = [(screen_size(:h) * amount).floor, 3].max
			when :absolute, :abs
				@height = amount
			end
		end
		def set_pos target, amount, type = :percent
			return nil  unless (@pos.keys.include? target)
			screen_axis = :w  if (target == :x)
			screen_axis = :h  if (target == :y)
			case type
			when :percent, :perc
				@pos[target] = (screen_size(screen_axis) * amount).floor
			when :absolute, :abs
				@pos[target] = amount
			end
		end

		## Return wanted width for window
		def width
			return @width
		end

		## Return wanted height for window
		def height
			return @height
		end

		## Return wanted position in screen for window
		def pos target = :all
			ret = nil
			case target
			when :x
				return pos_x  if (defined? pos_x)
				ret = @pos[:x]
				if (ret + width > screen_size(:w))
					ret = screen_size(:w) - width
				end
			when :y
				return pos_y  if (defined? pos_y)
				ret = @pos[:y]
				if (ret + height > screen_size(:h))
					ret = screen_size(:h) - height
				end
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

		## Check if Window is hidden
		def hidden?
			return (!!@hidden || (width < MIN_WIDTH || height < MIN_HEIGHT))
		end
		## Check if Window is shown
		def shown?
			return !hidden?
		end

		## Hide Window
		def hide
			@hidden = true
			return hidden?
		end

		## Show Window
		def show
			@hidden = false
			return shown?
		end
	end # END - CLASS
end # END - MODULE Windows

