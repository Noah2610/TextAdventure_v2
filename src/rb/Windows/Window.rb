
### Currently this file only creates the Windows module.
### The curses windows themselves are defined in their own files in the windows directory.
##  ex.: Input Window, Main Output Window, Conversation Output Window, ...

module Windows
	MIN_WIDTH  = SETTINGS.output['min_width']
	MIN_HEIGHT = SETTINGS.output['min_height']

	class Window
		def initialize args = {}
			@width  = args[:width]   || args[:w] || 0.0
			@height = args[:height]  || args[:h] || 0.0
			@pos    = ( args[:pos]   || (
				(args[:x] && args[:y]) ? { x: args[:x], y: args[:y] } : { x: 0.0, y: 0.0 }
			))
			## Init Curses Window
			@window = Curses::Window.new(
				height,  width,
				pos(:y), pos(:x)
			)
			@border = [?|, ?-]
		end

		## Return wanted width for window
		def width
			return (screen_size(:w) * @width).round
		end

		## Return wanted height for window
		def height
			return [(screen_size(:h) * @height).round, 3].max
		end

		## Return wanted position in screen for window
		def pos target = :all
			ret = nil
			case target
			when :x
				return pos_x  if (defined? pos_x)
				ret = (screen_size(:w) * @pos[:x]).round
				if (ret + width > screen_size(:w))
					ret = screen_size(:w) - width
				end
			when :y
				return pos_y  if (defined? pos_y)
				ret = (screen_size(:h) * @pos[:y]).round
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
	end


	module Color
		## Color manipulation methods for Curses Windows

		## Generate color-pairs array
		COLORS = [
			:black, :white,
			:red,   :green,  :blue,
			:cyan,  :yellow, :magenta
		]
		PAIRS = COLORS.map do |bg|
			next COLORS.map do |fg|
				next [fg,bg]
			end
		end .flatten 1

		## Init Curses color-pairs, defined above
		def self.init
			PAIRS.each_with_index do |pair, index|
				Curses.init_pair index, Curses.const_get("COLOR_#{pair[0].to_s.upcase}"), Curses.const_get("COLOR_#{pair[1].to_s.upcase}")
			end
		end

		## Get the color-pair id by fg and bg color names
		def self.get_color_pair_id_by_colors fg, bg
			Windows::Color::PAIRS.each_with_index do |pair, index|
				if (pair == [fg,bg])
					return index
				end
			end
			return nil
		end

		## Process color/style-coded string.
		## Return string without color/style-codes and
		## color stack with indices for returned string
		def self.process_attribute_codes lines, opts = {}
			if    (lines.is_a? Array)
				type_given = :array
				str = lines.join "\n"
			elsif (lines.is_a? String)
				type_given = :string
				str = lines
			else
				return nil
			end
			regex = /{[A-z,;:= ]+?}/

			## String without attribute-codes, will be returned
			str_new = str.dup
			## Will be filled with attribute-pair ids at appropriate indices, will be returned
			attr_stack = {}

			return lines, nil  unless (str.match regex)

			## Scan str for attribute-codes
			str.scan regex do |code|
				index = (str_new =~ /#{Regexp.quote code}/)
				str_new.sub! code, ''  unless (opts[:show_codes] || opts[:show])
				## Handle attribute-code
				codes = code.match(/{(.+?)}/m)[1].split(/[; ]/)
				codes.each do |c|
					# RESET
					if    (c.match(/\A\s*RESET\s*\z/))
						if (attr_stack[index])
							attr_stack[index] << :RESET
						else
							attr_stack[index] = [:RESET]
						end
						# COLOR
					elsif (m = c.match(/\A\s*COLOR[:=]([A-z,]+?)\s*\z/))
						colors = m[1].split /[,]/
						if (attr_stack[index])
							attr_stack[index] << [:color, colors]
						else
							attr_stack[index] = [[:color, colors]]
						end
						# ATTRIBUTE / STYLE
					elsif (m = c.match(/\A\s*ATTR[:=]([A-z,]+?)\s*\z/))
						attrs = m[1].split /[,]/
						if (attr_stack[index])
							attr_stack[index] << [:attr, attrs]
						else
							attr_stack[index] = [[:attr, attrs]]
						end
					end
				end
			end

			ret = str_new.split("\n")  if (type_given == :array)
			ret = str_new              if (type_given == :string)
			return ret, attr_stack
		end
		def process_attribute_codes lines, opts = {}
			return Windows::Color.process_attribute_codes(lines, opts)
		end

		## Print text with attr_stack, get_color when necessary
		def print_with_attributes text, attr_stack, index_offset = 0
			text.each_char.with_index do |char, index|
				if (attr_stack && attrs = attr_stack[index + index_offset])
					attr_apply attrs
				end
				@window.addch char
				yield  if (block_given?)
			end
			## Apply attribute again, in case last index was an attribute
			if (attr_stack && attrs = attr_stack[text.size + index_offset])
				attr_apply attrs
			end
		end

		## Set text foreground and background colors
		def get_color *colors
			colors.flatten!
			fg = colors[0].downcase.to_sym
			bg = colors[1] ? colors[1].downcase.to_sym : :black
			id = Windows::Color.get_color_pair_id_by_colors fg, bg
			return Curses.color_pair(id)  unless (id.nil?)
		end

		## Possible attributes:
		# BLINK
		# BOLD
		# DIM
		# INVISIBLE
		# NORMAL
		# REVERSE
		# UNDERLINE
		# TOP
		# STANDOUT
		## Set text attribute / style
		def attr_set *attrs
			attrs.flatten!
			attrs_binary = 0
			attrs.each do |a|
				attrs_binary |= Curses.const_get "A_#{a.upcase}"  if (Curses.const_defined? "A_#{a.upcase}")
			end
			return attrs_binary
		end

		## Handle semantic attributes and apply them to window
		def attr_apply *attrs
			return nil  if (@window.nil?)
			attrs = attrs.flatten(2).each_slice(2).to_a
			binary = 0
			attrs.each do |att|
				next  if (att[1].nil?)
				# Reset
				if (att == :RESET)
					attr_reset
					next
				end
				case att[0]
				when :color
					c = get_color(att[1])
					binary |= c  unless (c.nil?)
				when :attr
					a = attr_set(att[1])
					binary |= a  unless (a.nil?)
				end
			end
			@window.attrset binary
		end

		def attr_reset
			@window.attrset Curses::A_NORMAL
		end
	end
end

