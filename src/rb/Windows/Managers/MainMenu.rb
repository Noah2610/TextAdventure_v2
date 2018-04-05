
## Require other Window files
require_files File.join(DIR[:windows], 'MainMenuWindows')

module Windows
	module Managers
		class MainMenu < Manager
			## The order in which Windows' dimensions and positions should be updated
			WINDOW_UPDATE_ORDER = [
				:main_title,
				:menu
			]
			MENU_HEIGHT = 3

			def initialize
				## Initialize Windows
				@windows = sort_hash({
					menu:       Menus::MainMenu.new,
					main_title: Outputs::MainTitle.new
				}, by: WINDOW_UPDATE_ORDER)
			end

			def update_window_menu
				window = get_window :menu
				# Width
				window.set_width 1.0
				# Height
				window.set_height MENU_HEIGHT, :absolute
				# Pos X
				window.set_pos :x, 0
				# Pos Y
				window.set_pos :y, GAME.screen_size(:h) - MENU_HEIGHT, :absolute
			end

			def update_window_main_title
				window = get_window :main_title
				# Width
				window.set_width 1.0
				# Height
				window.set_height GAME.screen_size(:h) - MENU_HEIGHT, :absolute
				# Pos X
				window.set_pos :x, 0
				# Pos Y
				window.set_pos :y, 0
			end
		end # END - CLASS
	end # END - MODULE Managers
end # END - MODULE Windows
