
module Instances
	module Items
		class Item < Instances::Instance
			def initialize args = {}
				super
				@belongs_to = args[:belongs_to]
			end

			## The Instance the Item belongs to
			def belongs_to
				return @belongs_to
			end
			## Set the Instance the Item belongs to
			def belongs_to= instance
				return @belongs_to = instance
			end
			## Check if the Item belongs to Instance or has an owner
			def belongs_to? instance = nil
				return !!@belongs_to  if (instance.nil?)
				return @belongs_to == instance
			end
			## Set aliases for belongs_to methods
			alias :owner  :belongs_to
			alias :owner= :belongs_to=
			alias :owner? :belongs_to?
		end
	end
end

