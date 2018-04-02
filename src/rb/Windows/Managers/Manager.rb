
## Require Window files
require File.join DIR[:windows], 'Window'
require File.join DIR[:windows], 'Color'
require File.join DIR[:windows], 'Output'
require File.join DIR[:windows], 'Menu'

module Windows::Managers
	class Manager
		def initialize
			@windows = {}
		end

		def init_curses
			unless (ENVT.debug? || ENVT.test?)
				## Initialise Curses Windows
				@windows.values.each &:init_curses
			end
		end

		## Return Window
		def get_window target
			return @windows[target]  if (@windows[target])
			return nil
		end

		## Calculate and set proper relative Window sizes and positions
		def update_windows
			## Update Window positions, widths, and heights
			@windows.each do |window_name, window|
				try_to_call_method "update_window_#{window_name}"
				window.update
			end
		end

		def try_to_call_method method_name
			begin
				method(method_name).call
			rescue NameError
				classname = self.class.name.match(/\AWindows::Managers::(.+)\z/)[1]
				log "WARNING: Window Manager '#{classname}' tried to call method '#{method_name}', which doesn't exist!"
			end
		end

		## Update Windows
		def update
			update_windows
		end
	end
end # END - MODULE Windows::Managers

## Require Window Managers
require_files File.join(DIR[:window_managers]), except: 'Manager'

