
module Windows
	module Menus
		class MainMenu < Menu
			def initialize
				super
				## Menu Items
				@menu_items = {
					start: Items::Start.new,
					quit:  Items::Quit.new
				}
			end

			def update_menu_item_start
				menu_item = get_menu_item :start
				# Width
				menu_item.set_width 0.5
				# Height
				menu_item.set_height 5, :absolute
				# Pos X
				menu_item.set_pos :x, 0.5
				# Pos Y
				menu_item.set_pos :y, 0.25
			end

			def update_menu_item_quit
				menu_item = get_menu_item :quit
				# Width
				# Height
				# Pos X
				# Pos Y
			end

			def update
				super
				Curses.getch
			end
		end # END - CLASS
	end # END - MODULE Menus
end # END - MODULE Windows
