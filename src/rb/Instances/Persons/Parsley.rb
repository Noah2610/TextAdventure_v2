
class Instances::Persons::Parsley < Instances::Persons::Person
	include Inventory
	def initialize args = {}
		super
		self.can_take = :Apple
	end
end

