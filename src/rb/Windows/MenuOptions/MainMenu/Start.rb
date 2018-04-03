module Windows::Menus::Options
	class Start < Option
		def initialize args = {}
			super
			@box_align = {
				horizontal: :center,
				vertical:   :top
			}
			@text_align = :center
			@text = '{COLOR:green}Start Game{RESET}'
		end
	end # END - CLASS Start
end # END - MODULE Windows::Menus::Options
