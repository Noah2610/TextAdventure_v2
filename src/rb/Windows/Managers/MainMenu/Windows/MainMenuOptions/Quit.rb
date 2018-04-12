module Windows::Menus::Options
	class MainMenuQuit < Option
		def initialize args = {}
			super
			@box_align = {
				horizontal: :left,
				vertical:   :top
			}
			@text_align = :left
			@text = 'Quit Game'
		end

		def submit
			quit_game
		end
	end # END - CLASS Quit
end # END - MODULE Windows::Menus::Options
