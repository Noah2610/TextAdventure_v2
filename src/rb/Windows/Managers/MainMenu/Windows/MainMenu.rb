## Require Menu Options for MainMenu
require_files File.join(DIR[:window_managers], 'MainMenu/Windows/MainMenuOptions')

module Windows
	module Menus
		class MainMenu < Menu
			def initialize
				super
				## Menu Options
				@options = {
					start: Options::MainMenuStart.new(
						menu:   self,
						coords: [0, 0]
					),
					quit:  Options::MainMenuQuit.new(
						menu:   self,
						coords: [1, 0]
					)
				}
			end

			def update_option_start
				option = get_option :start
				option.set_width 10, :absolute
				option.set_height 1, :absolute
				option.set_pos :x, 0.47
				option.set_pos :y, 0.5
			end

			def update_option_quit
				option = get_option :quit
				option.set_width 10, :absolute
				option.set_height 1, :absolute
				option.set_pos :x, 0.53
				option.set_pos :y, 0.5
			end
		end # END - CLASS
	end # END - MODULE Menus
end # END - MODULE Windows
