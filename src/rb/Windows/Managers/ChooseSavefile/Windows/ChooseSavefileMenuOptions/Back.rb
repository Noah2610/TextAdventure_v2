module Windows::Menus::Options
	class ChooseSavefileMenuBack < Option
		def initialize args = {}
			super
			@text = 'Back'
		end

		def submit
			GAME.init_main_menu
		end
	end # END - CLASS
end # END - MODULE Windows::Menus::Options
