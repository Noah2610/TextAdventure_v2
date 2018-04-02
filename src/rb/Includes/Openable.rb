## By default Openable means:
#   Instance can be opened or closed,
#   Items are only accessible when open

module Openable
	def is_openable?
		return true
	end

	## This Instance is open- and close-able
	def can_open?
		return true
	end
	def can_close?
		return true
	end

	## Check if GloveCompartment is open or closed
	def is_open?
		return !!@open
	end
	def is_closed?
		return !@open
	end

	## Open / Close
	def open!
		@open = true
		return is_open?
	end
	def close!
		@open = false
		return is_closed?
	end

	## Overwrite items method to check if is open
	def items
		return super  if (is_open?)
		return nil    if (is_closed?)
	end
end
