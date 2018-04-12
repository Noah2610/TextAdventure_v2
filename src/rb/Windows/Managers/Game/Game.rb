## Require Windows
require_files File.join(DIR[:window_managers], 'Game/Windows')

module Windows
	module Managers
		class Game < Manager
			## The order in which Windows' dimensions and positions should be updated
			WINDOW_UPDATE_ORDER = [
				:status,
				:primary,
				:conversation,
				:user,
				:input
			]

			def initialize
				## Initialize Windows
				@windows = sort_hash({
					input:        Input.new,
					primary:      Outputs::Primary.new,
					conversation: Outputs::Conversation.new,
					user:         Outputs::User.new,
					status:       Outputs::Status.new
				}, by: WINDOW_UPDATE_ORDER)
			end

			def update_window_input
				window = get_window :input
				window.set_width 0.75                                            if (get_window(:status).shown?)
				window.set_width 1.0                                             if (get_window(:status).hidden?)
				window.set_height 3, :absolute
				window.set_pos :x, 0, :absolute
				window.set_pos :y, (GAME.screen_size(:h) - 3), :absolute
			end

			def update_window_primary
				window = get_window :primary
				window.set_width 0.75                                            if (get_window(:status).shown?)
				window.set_width 1.0                                             if (get_window(:status).hidden?)
				window.set_height ((GAME.screen_size(:h) - 5) * 0.5), :absolute  if (get_window(:conversation).shown?)
				window.set_height (GAME.screen_size(:h) - 5), :absolute          if (get_window(:conversation).hidden?)
				window.set_pos :x, 0, :absolute
				window.set_pos :y, 0, :absolute
			end

			def update_window_conversation
				window = get_window :conversation
				y_pos_and_height = ((GAME.screen_size(:h) - 5).to_f * 0.5)
				window.set_width 0.75                                            if (get_window(:status).shown?)
				window.set_width 1.0                                             if (get_window(:status).hidden?)
				window.set_height y_pos_and_height, :absolute
				window.set_pos :x, 0, :absolute
				window.set_pos :y, y_pos_and_height, :absolute
			end

			def update_window_user
				window = get_window :user
				window.set_width 0.75                                            if (get_window(:status).shown?)
				window.set_width 1.0                                             if (get_window(:status).hidden?)
				window.set_height 3, :absolute
				window.set_pos :x, 0, :absolute
				window.set_pos :y, (GAME.screen_size(:h) - 5), :absolute
			end

			def update_window_status
				window = get_window :status
				window.set_width 0.25
				window.set_height 1.0
				window.set_pos :x, 0.75
				window.set_pos :y, 0, :absolute
			end
		end # END - CLASS
	end # END - MODULE Managers
end # END - MODULE Windows
