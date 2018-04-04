
module Saves
	class Savefile
		def initialize savefile_name
			create_savefile_directory
			savefile_name = "#{savefile_name}.json"  unless (savefile_name =~ /.+\.json\z/)
			@savefile = File.join get_saves_directory_for_envt, savefile_name
			## Load savefile contents
			@savefile_content = nil
			load_or_create_savefile
		end

		def create_savefile_directory
			Dir.mkdir get_saves_directory_for_envt  unless (File.directory? get_saves_directory_for_envt)
		end

		def get_saves_directory_for_envt
			dir = DIR[:saves]
			dir = DIR[:test][:saves]  if (ENVT.test?)
			return dir
		end

		def load_or_create_savefile
			if (savefile_exists? @savefile)
				@savefile_content = load_savefile_content
			else
				# New Savefile
				@savefile_content = {}
			end
		end

		def savefile_exists? savefile
			return true  if (File.exists? savefile)
			return false
		end

		def load_savefile_content
			content = load_json File.read(@savefile)
			return content
		end

		def load_json json
			begin
				return JSON.parse json
			rescue
				log "WARNING: Couldn't load savefile '#{@savefile}'; Is it JSON?"
				return nil
			end
		end

		## Save data to file
		def save!
			content_to_save = get_content_to_save
			write_content_to_savefile content_to_save
		end

		def get_content_to_save
			return OBJECTS_TO_SAVE.map do |object|
				[object.class.name, object.to_save]
			end .to_h
		end

		def write_content_to_savefile content
			json = content.to_json
			savefile = File.new @savefile, ?w
			savefile.write json
			savefile.close
		end

		## Load savefile
		def restore_savefile
			return  unless (@savefile_content)
			Saves::OBJECTS_TO_SAVE.each do |object|
				content = @savefile_content[object.class.name]
				unless (content)
					log "WARNING: Tried loading data for object '#{object.class.name}' from savefile, which doesn't exist! Outdated savefile?"
					next
				end
				object.restore_savefile content
			end
		end

		alias :restore :restore_savefile
	end # END - CLASS Savefile
end # END - MODULE Saves
