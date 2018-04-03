## Menu Options are list entries in Menus

module Windows
	module Menus
		module Options
			SELECTED_ATTRIBUTES = [(
				SETTINGS.menu['selected_attributes'] || ['bold', 'underline']
			)].flatten.join(?,)

			#TODO:
			## Don't inherit from Windows::Window, instead write custom methods here
			## Windows::Window has some methods that we can use for Options
			class Option < Windows::Window
				attr_reader :coords
				include Color

				def initialize args = {}
					super
					@menu      = args[:menu]
					@coords    = args[:coords] || [0,0]
					@box_align = {
						horizontal: :left,
						vertical:   :top
					}
					@text_align = :left
					@text = '{ATTR:standout}<OPTION TEXT>{RESET}'
				end

				def set_window window
					@window = window
				end

				def pos target = :all
					ret = super
					case target
					when :x
						ret = get_aligned_x ret
					when :y
						ret = get_aligned_y ret
					when :all
						ret = get_aligned_all ret
					end
				end

				def get_aligned_x position
					case @box_align[:horizontal]
					when :left, nil
						return position
					when :right
						return (position - width)
					when :center
						return (position - (width * 0.5)).round
					end
				end

				def get_aligned_y position
					case @box_align[:vertical]
					when :top, nil
						return position
					when :bottom
						return (position - height)
					when :center
						return (position - (height * 0.5)).round
					end
				end

				def get_aligned_all position
					return {
						x: get_aligned_x(position[:x]),
						y: get_aligned_y(position[:y])
					}
				end

				def redraw
					# Set to proper position in window
					@window.setpos pos(:y), pos(:x)
					text = get_text
					lines, attr_stack = process_attribute_codes([text].flatten.join("\n").split("\n"))
					#@window.setpos pos(:y), pos(:x) - 1
					#@window.addch '|'
					lines.each_with_index do |line, index|
						padding_x = get_aligned_line_x_position line
						@window.setpos pos(:y) + index, pos(:x) + padding_x
						print_with_attributes line, attr_stack
					end
					#@window.setpos pos(:y), pos(:x) + width
					#@window.addch '|'
					@window.refresh
				end

				def get_text
					if (@menu.selected_option == self)
						return "{ATTR:#{SELECTED_ATTRIBUTES}}#{@text}{RESET}"
					else
						return @text
					end
				end

				def get_aligned_line_x_position line
					padding = 0
					case @text_align
					when :left, nil
						padding = 0
					when :right
						padding = width - line.size
					when :center
						padding = ((width - line.size) * 0.5).round
					end
					return padding
				end

				## Submit / "click" on Option
				def submit!
				end

				def update
					redraw  unless (ENVT.debug? || ENVT.test?)
				end
			end # END - CLASS Option
		end # END - MODULE Options
	end # END - MODULE Menus
end # END - MODULE Windows
