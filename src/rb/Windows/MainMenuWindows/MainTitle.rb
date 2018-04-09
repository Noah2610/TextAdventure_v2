
module Windows
	module Outputs
		class MainTitle < Output
			include Large

			def initialize args = {}
				super
				@border = [?|, ?-]
				@lines = [
					'{LARGE_START}',
					'{COLOR:red;ATTR:bold}T{COLOR:green;ATTR:bold}e{COLOR:blue;ATTR:bold}x{COLOR:cyan;ATTR:bold}t{RESET}',
					'{COLOR:yellow;ATTR:bold}A{COLOR:magenta;ATTR:bold}d{COLOR:red;ATTR:bold}v{COLOR:green;ATTR:bold}e{COLOR:blue;ATTR:bold}n{COLOR:cyan;ATTR:bold}t{COLOR:yellow;ATTR:bold}u{COLOR:magenta;ATTR:bold}r{COLOR:red;ATTR:bold}e{RESET}',
					'{LARGE_END}'
				]
				@padding   = 4
				@padding_h = 2
				@min_width = 16
			end
		end # END - CLASS MainTitle
	end # END - MODULE Outputs
end # END - MODULE Windows
