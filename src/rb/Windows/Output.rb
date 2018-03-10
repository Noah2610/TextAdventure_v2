
module Windows
	class Output < Window
		include Color

		def initialize args = {}
			super
			@padding      = SETTINGS.output['padding'] || 3
			@padding_h    = SETTINGS.output['padding_height'] || 1
			@indent       = SETTINGS.output['indent'] || 2
			@history_size = SETTINGS.output['history_size'] || 100
			@lines = []
			redraw
		end

		def print text, args = {}
			[text].flatten.each do |txt|
				txt.gsub(/\n/, "\n#{' ' * @indent}").split(/\n/).each do |ln|
					@lines << ln
				end
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

			## Don't draw if too small
			if (width < MIN_WIDTH || height < MIN_HEIGHT)
				return
			end

			@window.move pos(:y), pos(:x)
			@window.resize height, width
			@window.box @border[0], @border[1]

			## Process lines

			## Generate attribute stack for attribute-coded strings
			lines, attr_stack = process_attribute_codes @lines

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

				## Index counter of all characters printed, necessary for attribute-coding
				char_index = 0

				## Remove lines that don't fit in window height
				max_height = size(:h) - (@padding_h * 2)
				if (lines_final.size > max_height)
					diff = lines_final.size - max_height
					char_index += (lines_final[0 ... diff].join(?X) + ?X).delete('{INDENT}').size - lines_final[0 ... diff].join.scan('{INDENT}').size
					lines_final = lines_final[diff .. -1]
				end

				## Print lines
				if (attr_stack && attrs = attr_stack[char_index])
					attr_apply attrs
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

					## Print line with attributes
					print_with_attributes line, attr_stack, char_index do
						## This block is executed everytime after a character has been printed
						char_index += 1
					end

					if (attr_stack && attrs = attr_stack[char_index])
						attr_apply attrs
					end
					char_index += 1
				end
			end

			attr_reset
			@window.refresh
		end

		def update
			redraw
		end

	end
end

