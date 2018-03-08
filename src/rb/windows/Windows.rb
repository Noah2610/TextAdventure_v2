
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
			## Init Curses color-pairs, defined above
			PAIRS.each_with_index do |pair, index|
				Curses.init_pair index, Curses.const_get("COLOR_#{pair[0].to_s.upcase}"), Curses.const_get("COLOR_#{pair[1].to_s.upcase}")
			end
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

