## Require MenuOptions
require File.join DIR[:menu_options],         'Option'
require_files File.join(DIR[:menu_options], 'MainMenu')

module Windows
	module Menus
		nav = SETTINGS.menu['navigation']
		NAVIGATION = {
			up:    [nav['up']].flatten    || ['KEY_UP',    ?k],
			down:  [nav['down']].flatten  || ['KEY_DOWN',  ?j],
			left:  [nav['left']].flatten  || ['KEY_LEFT',  ?h],
			right: [nav['right']].flatten || ['KEY_RIGHT', ?l]
		}

		class Menu < Window
			include Color

			def initialize
				super
				@border = ['#', '#']
				@border_color = SETTINGS.menu['MainMenu']['border_color']
				@border_attr  = SETTINGS.menu['MainMenu']['border_attr']
				# Options are list entries
				@options = {}
				@selected_option = nil
			end

			def init_curses
				super
				@options.values.each do |option|
					option.set_window @window
				end
			end

			def redraw
				## Clear window
				@window.clear
				## Move window to proper position on screen
				@window.move pos(:y), pos(:x)
				## Resize window in case of terminal resize
				@window.resize height, width
				## Set color for border
				attr_apply :color, @border_color, :attr, @border_attr  if (@border_color || @border_attr)
				## Create border for window
				@window.box @border[0], @border[1]
				attr_reset
				## Set position to proper cursor position
				@window.refresh
			end

			def update_options
				@options.each do |option_name, option|
					try_to_call_method "update_option_#{option_name}"
					option.update
				end
			end

			def try_to_call_method method_name
				begin
					method(method_name).call
				rescue NameError
					classname = self.class.name.match(/\AWindows::Menus::(.+)\z/)[1]
					log "WARNING: Menu '#{classname}' tried to call method '#{method_name}', which doesn't exist!"
				end
			end

			def get_option option_name
				return @options[option_name]  if (@options[option_name])
				return nil
			end

			## Return currently selected Option
			def selected_option
				return @options.to_a.first[1]  if (@selected_option.nil?)
				return @selected_option
			end

			## Check if char or charid is valid navigation key
			def navigate? direction, char
				charid = get_char_id char
				return NAVIGATION[direction].any? do |key|
					keyid = get_char_id key
					next charid == keyid
				end
			end

			def get_char_id char
				charid = nil
				if (char.is_a?(String) && char.size > 1)
					charname = char.to_sym
					charid = Curses.const_get charname  if (Curses.constants.include? charname)
				else
					charid = char.ord
				end
				return charid
			end

			def navigate_up? char
				return navigate? :up, char
			end

			def navigate_down? char
				return navigate? :down, char
			end

			def navigate_left? char
				return navigate? :left, char
			end

			def navigate_right? char
				return navigate? :right, char
			end

			def select_next_option_by_coords_diff coords_diff
				options_indexed_by_coords = get_options_indexed_by_coords
				next_coords = get_next_coords coords_diff
				next_option = get_option_by_coords next_coords
				@selected_option = next_option  if (next_option)
			end

			def select_option_above
				select_next_option_by_coords_diff [0, -1]
			end

			def select_option_below
				select_next_option_by_coords_diff [0, 1]
			end

			def select_option_left
				select_next_option_by_coords_diff [-1, 0]
			end

			def select_option_right
				select_next_option_by_coords_diff [1, 0]
			end

			def get_options_indexed_by_coords
				return @options.values.map do |option|
					next [option.coords, option]
				end .to_h
			end

			def get_next_coords coords_diff
				next_coords = [
					selected_option.coords[0] + coords_diff[0],
					selected_option.coords[1] + coords_diff[1]
				]
				# Loop X coord
				highest_x_cord = get_highest_x_coord_for_y_value next_coords[1]
				if    (next_coords[0] < 0)
					next_coords[0] = highest_x_cord
				elsif (next_coords[0] > highest_x_cord)
					next_coords[0] = 0
				end  if (highest_x_cord)
				# Loop Y coord
				highest_y_cord = get_highest_y_coord_for_x_value next_coords[0]
				if (next_coords[1] < 0)
					next_coords[1] = highest_y_cord
				elsif (next_coords[1] > highest_y_cord)
					next_coords[1] = 0
				end  if (highest_y_cord)
				return next_coords
			end

			def get_highest_coord_by_axis axis_index, other_axis_value
				other_axis_index = axis_index == 0 ? 1 : (axis_index == 1 ? 0 : nil)
				return @options.values.map do |option|
					next option.coords[axis_index]  if (option.coords[other_axis_index] == other_axis_value)
				end .reject { |x| !x } .max
			end

			def get_highest_x_coord_for_y_value y_value
				return get_highest_coord_by_axis 0, y_value
			end

			def get_highest_y_coord_for_x_value x_value
				return get_highest_coord_by_axis 1, x_value
			end

			def get_option_by_coords coords
				return @options.values.detect do |option|
					option.coords == coords
				end
			end

			## Read user input (one character)
			## For Option navigation
			def read
				charid = @window.getch.ord
				char = Curses.keyname charid
				if    (navigate_up?    char)
					select_option_above
				elsif (navigate_down?  char)
					select_option_below
				elsif (navigate_left?  char)
					select_option_left
				elsif (navigate_right? char)
					select_option_right
				end
			end

			def update
				redraw  unless (ENVT.debug? || ENVT.test?)
				update_options
				read
			end
		end # END - CLASS
	end # END - MODULE Menus
end # END - MODULE Windows
