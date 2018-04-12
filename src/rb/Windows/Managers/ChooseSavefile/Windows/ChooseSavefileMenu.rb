require_files File.join(DIR[:window_managers], 'ChooseSavefile/Windows/ChooseSavefileMenuOptions')

module Windows
	module Menus
		class ChooseSavefileMenu < Menu
			def initialize
				super
				## Menu Options
				@options = {
					back:     Options::ChooseSavefileMenuBack.new(
						menu:   self,
						coords: [0, 0]
					),
					new:      Options::ChooseSavefileMenuNew.new(
						menu:   self,
						coords: [1, 0]
					)
				}
				gen_savefile_options
			end

			def gen_savefile_options
				savefiles = get_savefiles
				savefiles.each.with_index do |savefile, index|
					@current_gen_savefile_option_index = index + 1
					gen_savefile_option_for savefile
					define_update_method_for_savefile_option savefile[:option_name]
				end
			end

			def get_savefiles
				saves_dir = DIR[:saves]
				return Dir.new(saves_dir).map do |file|
					filepath = File.join saves_dir, file
					next nil  unless (File.file? filepath)
					name        = file.sub /\.json\z/, ''
					option_name = "savefile_#{sanitize_string name}".to_sym
					next {
						name:        name,
						option_name: option_name,
						filepath:    filepath
					}
				end .reject { |x| !x }
			end

			def gen_savefile_option_for savefile
				coords = [
					1,
					@current_gen_savefile_option_index
				]
				@options[savefile[:option_name]] = Options::ChooseSavefileMenuSavefile.new(
					menu:     self,
					coords:   coords,
					name:     savefile[:name],
					filepath: savefile[:filepath]
				)
			end

			def define_update_method_for_savefile_option option_name
				method_name = "update_option_#{option_name}".to_sym
				current_index = @current_gen_savefile_option_index
				self.class.define_method method_name do
					option = get_option option_name
					option.set_width 0.33
					option.set_height 1, :absolute
					option.set_pos :x, 0.5
					option_new_pos_y = get_option(:new).pos(:y)
					option.set_pos :y, (option_new_pos_y + current_index).ceil, :absolute
				end
			end

			def update_option_back
				option = get_option :back
				option.set_width 10, :absolute
				option.set_height 1, :absolute
				option.set_pos :x, 0.1
				option.set_pos :y, 0.15
			end

			def update_option_new
				option = get_option :new
				option.set_width 0.33
				option.set_height 1, :absolute
				option.set_pos :x, 0.5
				option.set_pos :y, 0.15
			end
		end
	end # END - MODULE Menus
end # END - MODULE Windows
