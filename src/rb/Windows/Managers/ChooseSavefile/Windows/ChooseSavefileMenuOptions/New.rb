module Windows::Menus::Options
	class ChooseSavefileMenuNew < Option
		def initialize args = {}
			super
			@box_align = {
				horizontal: :center,
				vertical:   :top
			}
			@text_align  = :center
			@text_new    = 'New Savefile'
			@text_choose = 'Choose Savefile:'
		end

		def get_text
			if (@menu.selected_option == self)
				return "{ATTR:#{SELECTED_ATTRIBUTES}}#{@text_new}{RESET}"
			else
				return @text_choose
			end
		end
	end # END - CLASS
end # END - MODULE Windows::Menus::Options
