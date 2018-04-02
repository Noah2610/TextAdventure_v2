## Require MenuItems
require File.join DIR[:menu_items],         'MenuItem'
require_files     DIR[:menu_items], except: 'MenuItem'

module Windows
	module Menus
		class Menu < Window
			include Color

			def initialize
				super
				@border = ['#', '#']
				@border_color = SETTINGS.menu['MainMenu']['border_color']
				@border_attr  = SETTINGS.menu['MainMenu']['border_attr']
				@menu_items = {}
			end

			def init_curses
				super
				@menu_items.values.each do |menu_item|
					menu_item.set_window @window
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

			def update_menu_items
				@menu_items.each do |menu_item_name, menu_item|
					try_to_call_method "update_menu_item_#{menu_item_name}"
					menu_item.update
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

			def get_menu_item menu_item_name
				return @menu_items[menu_item_name]  if (@menu_items[menu_item_name])
				return nil
			end

			def update
				redraw  unless (ENVT.debug? || ENVT.test?)
				update_menu_items
			end
		end # END - CLASS
	end # END - MODULE Menus
end # END - MODULE Windows
