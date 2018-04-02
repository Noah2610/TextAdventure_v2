class Instances::Components::GloveCompartment < Instances::Components::Component
	include Inventory
	include Openable

	def initialize args = {}
		super
		@open = false
	end

	## Include open state in description
	def description
		ret = [super]
		if    (is_open?)
			ret << text('is_open')
		elsif (is_closed?)
			ret << text('is_closed')
		end
		return ret.flatten.join("\n")
	end
end
