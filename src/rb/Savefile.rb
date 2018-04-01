
module Saves
	## This Constant will be filled with Objects that should be saved
	TO_SAVE = []

	## This module is supposed to be included to classes that should save data
	module Savable
		def initialize args = {}
			super  if (self.class.name =~ /\AInstances::.+?::.+\z/)
			Saves::TO_SAVE << self
		end

		## Returns all values / attributes that should be saved
		## Method should be overwritten by class including this module
		def to_save
			log "WARNING: '#{self.class.name}' tried to save data, but '@to_save' is not set!"
			return nil
		end
	end # END - MODULE Savable

	class Savefile
		def initialize savefile_name
			savefile_name = "#{savefile_name}.json"  unless (savefile_name =~ /.+\.json\z/)
			savefile = File.join DIR[:saves], savefile_name
			## Load savefile contents
			@savefile = load_savefile savefile
		end

		def load_savefile savefile
			return nil  unless (savefile_exists? savefile)
			content = load_json savefile
			return content
		end

		def savefile_exists? savefile
			unless (File.exists? savefile)
				log "WARNING: Tried loading savefile '#{savefile}' which doesn't exist!"
				return false
			end
			return true
		end

		def load_json savefile
			begin
				return JSON.parse File.read(savefile)
			rescue
				log ["WARNING: Couldn't load savefile '#{savefile}'; Is it JSON?"].join("\n")
				return nil
			end
		end
	end # END - CLASS Savefile
end # END - MODULE Saves

