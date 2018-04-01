### This module should be included to classes that should be saved

module Saves
	## This Constant will be filled with Objects that should be saved
	OBJECTS_TO_SAVE = []

	## This module is supposed to be included to classes that should save data
	module Savable
		def initialize args = {}
			super  if (self.class.name =~ /\AInstances::.+?::.+\z/)
			Saves::OBJECTS_TO_SAVE << self
		end

		## Returns all values / attributes that should be saved
		## Method should be overwritten by class including this module
		def to_save
			log "WARNING: '#{self.class.name}' tried to save data, but '@to_save' is not set!"
			return nil
		end
	end # END - MODULE Savable
end # END - MODULE Saves
