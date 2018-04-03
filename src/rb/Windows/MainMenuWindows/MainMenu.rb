
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
						coords: [0, 1]
					)
				}
			end

			def update_option_start
				option = get_option :start
				option.set_width 0.5
				option.set_height 3, :absolute
				option.set_pos :x, 0.5
				option.set_pos :y, 0.25
			end

			def update_option_quit
				option = get_option :quit
				option.set_width 0.5
				option.set_height 3, :absolute
				option.set_pos :x, 0.5
				option.set_pos :y, 0.75
			end
		end # END - CLASS
	end # END - MODULE Menus
end # END - MODULE Windows
