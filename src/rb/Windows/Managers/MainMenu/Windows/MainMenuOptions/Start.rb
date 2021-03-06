module Windows::Menus::Options
	class MainMenuStart < Option
		def initialize args = {}
			super
			@box_align = {
				horizontal: :right,
				vertical:   :top
			}
			@text_align = :right
			@text = '{COLOR:green}Start Game{RESET}'
		end

		def submit
			GAME.init_choose_savefile
		end
	end # END - CLASS Start
end # END - MODULE Windows::Menus::Options
