
### Currently this file only creates the Windows module.
### The curses windows themselves are defined in their own files in the windows directory.
##  ex.: Input Window, Main Output Window, Conversation Output Window, ...

module Windows
	module Colors
		## Color manipulation methods for Curses Windows

		PAIRS = [
			[:black, :black],
			[:white, :black],
			[:red,   :black],
			[:green, :black],
			[:blue,  :black]
		]

		def self.init
			## Init some Curses color-pairs
			# WHITE on BLACK
			Curses.init_pair 1, Curses::COLOR_WHITE, Curses::COLOR_BLACK
			# RED on BLACK
			Curses.init_pair 2, Curses::COLOR_RED, Curses::COLOR_BLACK
			# GREEN on BLACK
			Curses.init_pair 3, Curses::COLOR_GREEN, Curses::COLOR_BLACK
			# BLUE on BLACK
			Curses.init_pair 4, Curses::COLOR_BLUE, Curses::COLOR_BLACK
		end

		def self.get_color_pair_id_by_colors fg, bg
			Windows::Colors::PAIRS.each_with_index do |pair, index|
				if (pair == [fg,bg])
					return index
				end
			end
		end

		def change_color *colors
			return nil  if (@window.nil?)
			colors.flatten!
			fg = colors[0].downcase.to_sym
			bg = colors[1] ? colors[1].downcase.to_sym : :black
			id = Windows::Colors.get_color_pair_id_by_colors fg, bg
			@window.attrset Curses.color_pair(id)
		end
	end
end

