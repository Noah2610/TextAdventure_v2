
module Windows
	module Menus
		class MainMenu < Menu
			def initialize
				super
				## Menu Options
				@options = {
					start: Options::Start.new(
						menu:   self,
						coords: [0, 0]
					),
					quit:  Options::Quit.new(
						menu:   self,
						coords: [1, 0]
					)
				}
			end

			def update_option_start
				option = get_option :start
				option.set_width 10, :absolute
				option.set_height 2, :absolute
				option.set_pos :x, 0.47
				option.set_pos :y, 0.85
			end

			def update_option_quit
				option = get_option :quit
				option.set_width 10, :absolute
				option.set_height 2, :absolute
				option.set_pos :x, 0.53
				option.set_pos :y, 0.85
			end
		end # END - CLASS
	end # END - MODULE Menus
end # END - MODULE Windows
