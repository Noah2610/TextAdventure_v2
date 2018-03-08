
### Currently this file only creates the Windows module.
### The curses windows themselves are defined in their own files in the windows directory.
##  ex.: Input Window, Main Output Window, Conversation Output Window, ...

module Windows
	module Colors
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
			Windows::Colors::PAIRS.each_with_index do |pair, index|
				if (pair == [fg,bg])
					return index
				end
			end
			return nil
		end

		## Set text foreground and background colors
		def set_color *colors
			colors.flatten!
			fg = colors[0].downcase.to_sym
			bg = colors[1] ? colors[1].downcase.to_sym : :black
			id = Windows::Colors.get_color_pair_id_by_colors fg, bg
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
		def set_attr *attrs
			attrs.flatten!
			attrs_binary = 0
			attrs.each do |a|
				attrs_binary |= Curses.const_get("A_#{a.upcase}")
			end
			return attrs_binary
		end

		## Handle semantic attributes and apply them to window
		def apply_attr attrs
			return nil  if (@window.nil?)
			binary = 0
			attrs.each do |att|
				# Reset
				if (att == :RESET)
					@window.attrset Curses::A_NORMAL
					next
				end
				case att[0]
				when :color
					binary |= set_color(att[1])
				when :attr
					binary |= set_attr(att[1])
				end
			end
			@window.attrset binary
		end
	end
end

