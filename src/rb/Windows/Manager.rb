
## Require other Window files
require File.join DIR[:windows], 'Window'
require File.join DIR[:windows], 'Color'
require File.join DIR[:windows], 'Input'
require File.join DIR[:windows], 'Outputs/Output'
require_files File.join(DIR[:windows], 'Outputs'), except: 'Output'

class Windows::Manager
	## The order in which Windows' dimenstions and positions should be updated
	WINDOW_UPDATE_ORDER = [
		:status,
		:primary,
		:conversation,
		:user,
		:input
	]

	def initialize
		## Initialize Windows
		@windows = {
			input:          Windows::Input.new,
			outputs: {
				primary:      Windows::Outputs::Primary.new,
				conversation: Windows::Outputs::Conversation.new,
				user:         Windows::Outputs::User.new,
				status:       Windows::Outputs::Status.new
			}
		}
	end

	def init_curses
		unless (ENVT.debug? || ENVT.test?)
			## Initialise Curses Windows
			@windows[:input].init_curses
			@windows[:outputs].values.each &:init_curses
		end
	end

	## Return Window
	def get_window target
		return @windows[target]            if (@windows[target])
		return @windows[:outputs][target]  if (@windows[:outputs][target])
		return nil
	end

	## Calculate and set proper relative Window sizes and positions
	def update_windows
		all_windows = sort_hash({}.merge(@windows[:outputs]).merge({input: @windows[:input]}), by: WINDOW_UPDATE_ORDER)
		all_windows.each do |name, window|
			case name
			when :input
				# Width
				window.set_width 0.75                                            if (get_window(:status).shown?)
				window.set_width 1.0                                             if (get_window(:status).hidden?)
				# Height
				window.set_height 3, :absolute
				# Pos X
				window.set_pos :x, 0, :absolute
				# Pos Y
				window.set_pos :y, (screen_size(:h) - 3), :absolute

			when :primary
				# Width
				window.set_width 0.75                                            if (get_window(:status).shown?)
				window.set_width 1.0                                             if (get_window(:status).hidden?)
				# Height
				window.set_height ((screen_size(:h) - 5).to_f * 0.5), :absolute  if (get_window(:conversation).shown?)
				window.set_height screen_size(:h) - 5, :absolute                 if (get_window(:conversation).hidden?)
				# Pos X
				window.set_pos :x, 0, :absolute
				# Pos Y
				window.set_pos :y, 0, :absolute

			when :conversation
				y_pos_and_height = ((screen_size(:h) - 5).to_f * 0.5)
				# Width
				window.set_width 0.75                                            if (get_window(:status).shown?)
				window.set_width 1.0                                             if (get_window(:status).hidden?)
				# Height
				window.set_height y_pos_and_height, :absolute
				# Pos X
				window.set_pos :x, 0, :absolute
				# Pos Y
				window.set_pos :y, y_pos_and_height, :absolute

			when :user
				# Width
				window.set_width 0.75                                            if (get_window(:status).shown?)
				window.set_width 1.0                                             if (get_window(:status).hidden?)
				# Height
				window.set_height 3, :absolute
				# Pos X
				window.set_pos :x, 0, :absolute
				# Pos Y
				window.set_pos :y, (screen_size(:h) - 5), :absolute

			when :status
				# Width
				window.set_width 0.25
				# Height
				window.set_height 1.0
				# Pos X
				window.set_pos :x, 0.75
				# Pos Y
				window.set_pos :y, 0, :absolute
			end
		end

	end

	## Redraw all Windows
	def update
		# Update sizes and positions of Windows
		update_windows
		# Update / Redraw Windows
		@windows[:outputs].values.each &:update
		@windows[:input].update
	end
end

