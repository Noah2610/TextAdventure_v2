
module Windows
	module Outputs
		class MainTitle < Output
			include Large

			def initialize args = {}
				super
				@border = [?|, ?-]
				@lines = [
					'{LARGE_START}TEXT',
					'ADVENTURE{LARGE_END}'
				]
				@padding_h = 2
			end
		end # END - CLASS MainTitle
	end # END - MODULE Outputs
end # END - MODULE Windows
