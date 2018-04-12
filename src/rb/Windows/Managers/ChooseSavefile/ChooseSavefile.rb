require_files File.join(DIR[:window_managers], 'ChooseSavefile/Windows')

module Windows
	module Managers
		class ChooseSavefile < Manager
			WINDOW_UPDATE_ORDER = [
				:choose_savefile_text,
				:choose_savefile_menu
			]

			def initialize
				@windows = sort_hash({
					choose_savefile_menu: Menus::ChooseSavefileMenu.new
				}, by: WINDOW_UPDATE_ORDER)
			end

			def update_window_choose_savefile_text
				window = get_window :choose_savefile_text
			end

			def update_window_choose_savefile_menu
				window = get_window :choose_savefile_menu
				window.set_width 1.0
				window.set_height 1.0
				window.set_pos :x, 0.0
				window.set_pos :y, 0.0
			end
		end # END - CLASS
	end # END - MODULE Managers
end # END - MODULE Windows
