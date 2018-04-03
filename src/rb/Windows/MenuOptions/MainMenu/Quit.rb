module Windows::Menus::Options
	class Quit < Option
		def initialize args = {}
			super
			@box_align = {
				horizontal: :center,
				vertical:   :top
			}
			@text_align = :center
			@text = 'Quit Game'
		end

		def submit!
			quit_game
		end
	end # END - CLASS Quit
end # END - MODULE Windows::Menus::Options
