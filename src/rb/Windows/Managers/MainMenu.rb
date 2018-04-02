
## Require other Window files
require_files File.join(DIR[:windows], 'MainMenuWindows')

module Windows
	module Managers
		class MainMenu < Manager
			## The order in which Windows' dimensions and positions should be updated
			WINDOW_UPDATE_ORDER = [
				:menu
			]

			def initialize
				## Initialize Windows
				@windows = sort_hash({
					menu: Menus::MainMenu.new
				}, by: WINDOW_UPDATE_ORDER)
			end

			def update_window_menu
				window = get_window :menu
				# Width
				window.set_width 1.0
				# Height
				window.set_height 1.0
				# Pos X
				window.set_pos :x, 0
				# Pos Y
				window.set_pos :y, 0
			end
		end # END - CLASS
	end # END - MODULE Managers
end # END - MODULE Windows
