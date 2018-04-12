module Windows::Menus::Options
	class ChooseSavefileMenuSavefile < Option
		def initialize args = {}
			super
			@box_align = {
				horizontal: :center,
				vertical:   :top
			}
			@text_align  = :center
			@name     = args[:name]
			@filepath = args[:filepath]
			@text     = @name
		end

		def submit
			log "SUBMIT: #{@name}"
		end
	end # END - CLASS
end # END - MODULE Windows::Menus::Options
