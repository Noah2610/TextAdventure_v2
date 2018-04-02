
module Saves
	class Savefile
		def initialize savefile_name
			savefile_name = "#{savefile_name}.json"  unless (savefile_name =~ /.+\.json\z/)
			@savefile = File.join DIR[:saves], savefile_name
			@savefile = nil  unless (savefile_exists? @savefile)
			## Load savefile contents
			@savefile_content = load_savefile
		end

		def savefile_exists? savefile
			unless (File.exists? savefile)
				log "WARNING: Tried loading savefile '#{savefile}' which doesn't exist!"
				return false
			end
			return true
		end

		def load_savefile
			return nil  unless (@savefile)
			content = load_json
			return content
		end

		def load_json
			begin
				return JSON.parse File.read(@savefile)
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
		def load_data
			return  unless (@savefile_content)
			Saves::OBJECTS_TO_SAVE.each do |object|
				content = @savefile_content[object.class.name]
				unless (content)
					log "WARNING: Tried loading data for object '#{object.class.name}' from savefile, which doesn't exist! Outdated savefile?"
					next
				end
				object.load_data content
			end
		end
	end # END - CLASS Savefile
end # END - MODULE Saves
