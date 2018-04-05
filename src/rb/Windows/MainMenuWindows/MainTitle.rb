
module Windows
	module Outputs
		class MainTitle < Output
			include Large

			def initialize args = {}
				super
				@border = [?|, ?-]
				@lines = [
					'{LARGE_START}TEXT{LARGE_END}',
					'{LARGE_START}ADVENTURE{LARGE_END}'
				]
			end
		end # END - CLASS MainTitle
	end # END - MODULE Outputs
end # END - MODULE Windows
