## Menu Items are list entries in Menus

module Windows::Menus
	module Items
		class Item < Windows::Window
			def initialize
				super
				@min_width = 16
				@max_width = 24
				@horizontal_align = :center
				@vertical_align   = :top
			end

			def set_window window
				@window = window
			end

			def set_width amount, type = :percent
				super
				@width = @min_width  if (@width < @min_width)
				@width = @max_width  if (@width > @max_width)
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
				case @horizontal_align
				when :center
					return (position - (width * 0.5)).round
				when :left, nil
					return position
				when :right
					return (position - width)
				end
			end

			def get_aligned_y position
				case @vertical_align
				when :center
					return (position - (height * 0.5)).round
				when :top, nil
					return position
				when :bottom
					return (position - height)
				end
			end

			def get_aligned_all position
				return {
					x: get_aligned_x(position[:x]),
					y: get_aligned_y(position[:y])
				}
			end

			def redraw
				#TODO
				# Set to proper position in window
				@window.setpos pos(:y), pos(:x)
				# Draw each line
				height.times do |line|
					@window.addstr "foo"
				end
				@window.refresh
			end

			def update
				redraw  unless (ENVT.debug? || ENVT.test?)
			end
		end # END - CLASS Item
	end # END - MODULE Items
end # END - MODULE Windows::Menus
