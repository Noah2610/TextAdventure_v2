
module Windows
	module Outputs
		class MainTitle < Output
			include Large

			def initialize args = {}
				super
				@border = [?|, ?-]
				@lines = [
					"{LARGE_START}FOO{LARGE_END}foo",
					"fafaskfhasflkashflkash",
					"bar{LARGE_START}BAR{LARGE_END}"
				]
				@padding_h = 2
				@all_text_in_window = true
			end
		end # END - CLASS MainTitle
	end # END - MODULE Outputs
end # END - MODULE Windows
