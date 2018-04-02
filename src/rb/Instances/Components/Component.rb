## A Component is an Instance that sits inside a Room
## It can include an Inventory

module Instances
	module Components
		class Component < Instance
			include Saves::Methods::Component

			def initialize args = {}
				super
			end

			## Default items method
			def items
				return nil
			end
		end # END - CLASS
	end # END - MODULE Components
end # END - MODULE Instances
