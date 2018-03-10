
class Verbs::Take < Verbs::Verb
	def initialize args = {}
		super
	end

	def action args = {}
		line = args[:line]
		word = line.next_word pos: args[:word].position, priority: :item, ignore: ignore
		## Is ITEM
		if    (word.is? :item)
			## Check if Item is already in Player's Inventory
			unless (PLAYER.has_item? word.instance)
				PLAYER.item_add word.instance
				return Verbs::Verb.substitute text('took'), word
			else
				return Verbs::Verb.substitute text('in_inventory'), word
			end

		else

		end
	end
end

